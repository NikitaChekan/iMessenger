//
//  SettingsProfileViewController.swift
//  iMessenger
//
//  Created by jopootrivatel on 26.06.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SDWebImage
import SPAlert
import SPIndicator

final class SettingsProfileViewController: UIViewController {
    
    // MARK: Properties
    
    private let scrollView = UIScrollView()
    private var stackView = UIStackView()
    
    private let fullImageView = AddPhotoForSettingsView()
    
    private let mailLabel = UILabel(text: "test1@mail.ru", font: .avenir20())
    
    private let fullNameLabel = UILabel(text: "Full name")
    private let aboutMeLabel = UILabel(text: "About me")
    private let sexLabel = UILabel(text: "Sex")
    
    private let fullNameTextField = OneLineTextField(font: .avenir20())
    private let aboutMeTextField = OneLineTextField(font: .avenir20())
    
    private let sexSegmentedControl = UISegmentedControl(first: "Male", second: "Female")
    
    private let saveSettingButton = UIButton(
        title: "Save changes",
        titleColor: .white,
        backgroundColor: UIColor(named: "buttonBlack") ?? .black,
        cornerRadius: 4
    )
    
    private let currentUser: MUser
    private var usersListener: ListenerRegistration?
    
    // MARK: - Init
    init(currentUser: MUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        
        title = currentUser.userName
        mailLabel.text = currentUser.email
        fullNameTextField.text = currentUser.userName
        aboutMeTextField.text = currentUser.description
        fullImageView.circleImageView.sd_setImage(with: URL(string: currentUser.avatarStringURL))

    }
    
    deinit {
        usersListener?.remove()
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(signOut))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "tabBarColor")
        
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
        let difference = keyboardSize.height - (self.view.frame.height - stackView.frame.origin.y - stackView.frame.size.height) + 3
        
        let scrollPoint = CGPointMake(0, difference)
        self.scrollView.setContentOffset(scrollPoint, animated: true)
    }
    
    @objc private func keyboardDisappear() {
        scrollView.setContentOffset(CGPoint(x: 0, y: -98), animated: true)
    }
    
    @objc private func signOut() {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
                
                self.appDelegate.activeChatsListener?.remove()
                self.appDelegate.activeChatsListener = nil
                
                self.appDelegate.waitingChatsListener?.remove()
                self.appDelegate.waitingChatsListener = nil
                
                let keyWindow = UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .map({$0 as? UIWindowScene})
                    .compactMap({$0})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first
                
                keyWindow?.rootViewController = AuthViewController()
                
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }))
        
        present(alertController, animated: true)
    }
    
    @objc private func plusButtonTapped() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }
    
    @objc private func saveSettingButtonTapped() {
        FirestoreService.shared.saveProfileWith(
            id: currentUser.id,
            email: currentUser.email,
            userName: fullNameTextField.text,
            avatarImage: fullImageView.circleImageView.image,
            description: aboutMeTextField.text,
            sex: sexSegmentedControl.titleForSegment(at: sexSegmentedControl.selectedSegmentIndex)) { (result) in
                switch result {
                case .success(let mUser):
                    let alertView = SPAlertView(title: "Successful", message: "Сhanges saved!", preset: .done)
                    alertView.duration = 3
                    alertView.present() {
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
            fullImageView.plusButton.tintColor = UIColor(named: "buttonBlack")
        case .dark:
            fullImageView.plusButton.tintColor = .white
        @unknown default:
            break
        }
        
    }
    
    // MARK: Methods
    
    private func configureView() {
        view.backgroundColor = .secondarySystemBackground
        
        let tintColor = traitCollection.userInterfaceStyle == .light ? UIColor(named: "buttonBlack") : UIColor.white
        
        fullImageView.plusButton.tintColor = tintColor
    }
    
    private func configureElements() {
        
        // Configure scrollView
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        
        // Configure fullImageView
        fullImageView.plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        
        // Configure welcomeLabel
        mailLabel.textAlignment = .center

        // Configure fullImageView
        fullNameTextField.delegate = self
        fullNameTextField.returnKeyType = .go
        fullNameTextField.tintColor = UIColor(named: "tabBarColor")
        
        // Configure fullImageView
        aboutMeTextField.delegate = self
        aboutMeTextField.tintColor = UIColor(named: "tabBarColor")
        
        // Configure goToChatsButton
        saveSettingButton.addTarget(self, action: #selector(saveSettingButtonTapped), for: .touchUpInside)
    }
    
}
        

// MARK: - Setup Constraints
extension SettingsProfileViewController {
    
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
            saveSettingButton.heightAnchor.constraint(equalToConstant: 60),
            fullImageView.widthAnchor.constraint(equalToConstant: 201)
        ])
        
        // Stack view for welcomeLabel and fullImageView
        let topStackView = UIStackView(arrangedSubviews: [fullImageView, mailLabel], axis: .vertical, spacing: 0)

        // Configure topStackView
        topStackView.alignment = .center
        topStackView.distribution = .fillProportionally
        
        // Stack view for fullNameStackView, aboutMeStackView, sexStackView, goToChatsButton
        let bottomStackView = UIStackView(
            arrangedSubviews: [fullNameStackView, aboutMeStackView, sexStackView, saveSettingButton],
            axis: .vertical,
            spacing: 30
        )
        
        // Configure bottomStackView
        bottomStackView.distribution = .fillProportionally
        
        // Stack view for topStackView and bottomsStackView
        let stackView = UIStackView(
            arrangedSubviews: [topStackView, bottomStackView],
            axis: .vertical,
            spacing: 0
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
            stackView.topAnchor.constraint(greaterThanOrEqualTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stackView.centerXAnchor.constraint(lessThanOrEqualTo: scrollView.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, multiplier: 0.8),
            stackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, multiplier: 0.75)
        ])
        
        self.stackView = stackView
        
    }
}

// MARK: - UIImagePickerControllerDelegate
extension SettingsProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        fullImageView.circleImageView.image = image
    }
    
}

// MARK: - UITextFieldDelegate
extension SettingsProfileViewController: UITextFieldDelegate {
    
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

//import SwiftUI
//
//struct SetupProfileVCProvider: PreviewProvider {
//    static var previews: some View {
//        ConteinerView()
//            .ignoresSafeArea()
//    }
//
//    struct ConteinerView: UIViewControllerRepresentable {
//
//        let viewController = SetupProfileViewController(currentUser: Auth.auth().currentUser!)
//
//        func makeUIViewController(context: UIViewControllerRepresentableContext<SetupProfileVCProvider.ConteinerView>) -> SetupProfileViewController {
//            return viewController
//        }
//
//        func updateUIViewController(_ uiViewController: SetupProfileVCProvider.ConteinerView.UIViewControllerType, context: UIViewControllerRepresentableContext<SetupProfileVCProvider.ConteinerView>) {
//
//        }
//    }
//}
