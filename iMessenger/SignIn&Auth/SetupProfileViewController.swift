//
//  SetupProfileViewController.swift
//  iMessenger
//
//  Created by jopootrivatel on 09.04.2023.
//

import UIKit
import FirebaseAuth
import SDWebImage
import SPAlert
import SPIndicator

class SetupProfileViewController: UIViewController {
    
    // MARK: Properties
    private let scrollView = UIScrollView()
    private var stackView = UIStackView()
    
    let welcomeLabel = UILabel(text: "Set up profile!", font: .avenir26())
    
    let fullImageView = AddPhotoView()
    
    let fullNameLabel = UILabel(text: "Full name")
    let aboutMeLabel = UILabel(text: "About me")
    let sexLabel = UILabel(text: "Sex")
    
    let fullNameTextField = OneLineTextField(font: .avenir20())
    let aboutMeTextField = OneLineTextField(font: .avenir20())
    
    let sexSegmentedControl = UISegmentedControl(first: "Male", second: "Female")
    
    let goToChatsButton = UIButton(
        title: "Go to chats!",
        titleColor: .white,
        backgroundColor: UIColor(named: "buttonBlack") ?? .black,
        cornerRadius: 4
    )
    
    private let currentUser: User
    
    // MARK: Init
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        
        if let userName = currentUser.displayName {
            fullNameTextField.text = userName
        }
        
        if let photoURL = currentUser.photoURL {
            fullImageView.circleImageView.sd_setImage(with: photoURL)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        configureElements()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    // MARK: Actions
    @objc private func keyboardWillAppear(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let difference = keyboardSize.height - (self.view.frame.height - stackView.frame.origin.y - stackView.frame.size.height)
        
        let scrollPoint = CGPointMake(0, difference)
        
        self.scrollView.setContentOffset(scrollPoint, animated: true)
    }
    
    @objc private func keyboardDisappear() {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }

    @objc private func plusButtonTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }
    
    @objc private func goToChatsButtonTapped() {
        FirestoreService.shared.saveProfileWith(
            id: currentUser.uid,
            email: currentUser.email!,
            userName: fullNameTextField.text,
            avatarImage: fullImageView.circleImageView.image,
            description: aboutMeTextField.text,
            sex: sexSegmentedControl.titleForSegment(at: sexSegmentedControl.selectedSegmentIndex)) { (result) in
                switch result {
                case .success(let mUser):
                    let indicatorView = SPIndicatorView(title: "Successful", message: "It's nice to talk!", preset: .done)
                    indicatorView.present(duration: 3) {
                        let mainTabBar = MainTabBarController(currentUser: mUser)
                        mainTabBar.modalPresentationStyle = .fullScreen
                        self.present(mainTabBar, animated: true)
                    }
                case .failure(let error):
                    let alertView = SPAlertView(title: "Error!", message: error.localizedDescription, preset: .error)
                    alertView.duration = 4
                    alertView.present()
                }
            }
    }
    
    // MARK: Override Methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        switch traitCollection.userInterfaceStyle {
        case .unspecified:
            break
        case .light:
            fullImageView.circleImageView.image = UIImage(named: "avatar")
            fullImageView.plusButton.tintColor = UIColor(named: "buttonBlack")
        case .dark:
            fullImageView.circleImageView.image = UIImage(named: "avatar-white")
            fullImageView.plusButton.tintColor = .white
        @unknown default:
            break
        }
        
    }
    
    // MARK: Methods
    
    private func configureView() {
        view.backgroundColor = .secondarySystemBackground
        
        let avatar = traitCollection.userInterfaceStyle == .light ? UIImage(named: "avatar") : UIImage(named: "avatar-white")
        let tintColor = traitCollection.userInterfaceStyle == .light ? UIColor(named: "buttonBlack") : UIColor.white
        
        fullImageView.circleImageView.image = avatar
        fullImageView.plusButton.tintColor = tintColor
    }
    
    private func configureElements() {
    
        // Configure scrollView
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
    
        // Configure welcomeLabel
        welcomeLabel.textAlignment = .center
        
        // Configure fullImageView
        fullImageView.plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)

        // Configure fullImageView
        fullNameTextField.delegate = self
        fullNameTextField.returnKeyType = .go
        fullNameTextField.tintColor = UIColor(named: "tabBarColor")
        
        // Configure fullImageView
        aboutMeTextField.delegate = self
        aboutMeTextField.tintColor = UIColor(named: "tabBarColor")
        
        // Configure goToChatsButton
        goToChatsButton.addTarget(self, action: #selector(goToChatsButtonTapped), for: .touchUpInside)
    }
    
}
        

// MARK: - Setup Constraints
extension SetupProfileViewController {
    
    private func setupConstraints() {
        
        // Stack view for fullNameLabel and fullNameTextField
        let fullNameStackView = UIStackView(
            arrangedSubviews: [fullNameLabel, fullNameTextField],
            axis: .vertical,
            spacing: 0
        )
        
        // Stack view for aboutMeLabel and aboutMeTextField
        let aboutMeStackView = UIStackView(
            arrangedSubviews: [aboutMeLabel, aboutMeTextField],
            axis: .vertical,
            spacing: 0
        )
        
        // Stack view for sexLabel and sexSegmentedControl
        let sexStackView = UIStackView(
            arrangedSubviews: [sexLabel, sexSegmentedControl],
            axis: .vertical,
            spacing: 0
        )
        
        // Configure sexStackView
        sexStackView.distribution = .fillEqually
        
        // Constraint for goToChatsButton and fullImageView
        NSLayoutConstraint.activate([
            goToChatsButton.heightAnchor.constraint(equalToConstant: 60),
            fullImageView.widthAnchor.constraint(equalToConstant: 146)
        ])
        
        // Stack view for welcomeLabel and fullImageView
        let topStackView = UIStackView(arrangedSubviews: [welcomeLabel, fullImageView], axis: .vertical, spacing: 30)

        // Configure topStackView
        topStackView.alignment = .center
        topStackView.distribution = .fillProportionally
        
        // Stack view for fullNameStackView, aboutMeStackView, sexStackView, goToChatsButton
        let bottomStackView = UIStackView(
            arrangedSubviews: [fullNameStackView, aboutMeStackView, sexStackView, goToChatsButton],
            axis: .vertical,
            spacing: 30
        )
        
        // Configure bottomStackView
        bottomStackView.distribution = .fillProportionally
        
        // Stack view for topStackView and bottomsStackView
        let stackView = UIStackView(
            arrangedSubviews: [topStackView, bottomStackView],
            axis: .vertical,
            spacing: 40
        )
        
        // Configure stackView
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        
        // Adding subviews
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        // Setup scrollView and stackView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(greaterThanOrEqualTo: scrollView.contentLayoutGuide.topAnchor, constant: 70),
            stackView.centerXAnchor.constraint(lessThanOrEqualTo: scrollView.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, multiplier: 0.8),
            stackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, multiplier: 0.82)
        ])
        
        self.stackView = stackView
        
    }
}

// MARK: - UIImagePickerControllerDelegate
extension SetupProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        fullImageView.circleImageView.image = image
    }
    
}

// MARK: - UITextFieldDelegate
extension SetupProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == fullNameTextField {
            aboutMeTextField.becomeFirstResponder()
        } else if textField == aboutMeTextField {
            aboutMeTextField.resignFirstResponder()
        }
        
        return true
    }
    
}

// MARK: - SwiftUI

import SwiftUI

struct SetupProfileVCProvider: PreviewProvider {
    static var previews: some View {
        ConteinerView()
            .ignoresSafeArea()
    }
    
    struct ConteinerView: UIViewControllerRepresentable {
        
        let viewController = SetupProfileViewController(currentUser: Auth.auth().currentUser!)
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<SetupProfileVCProvider.ConteinerView>) -> SetupProfileViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: SetupProfileVCProvider.ConteinerView.UIViewControllerType, context: UIViewControllerRepresentableContext<SetupProfileVCProvider.ConteinerView>) {
            
        }
    }
}
