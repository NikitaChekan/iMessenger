//
//  ProfileViewController.swift
//  iMessenger
//
//  Created by jopootrivatel on 17.04.2023.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController {
    
    // MARK: Properties
    let containerView = UIView()
    let imageView = UIImageView(image: UIImage(named: "human11"), contentMode: .scaleAspectFill)
    let nameLabel = UILabel(
        text: "Dasha Logina",
        font: .systemFont(ofSize: 20, weight: .bold)
    )
    let aboutMeLabel = UILabel(
        text: "You have the opportunity to chat with the best girl in the world!",
        font: .systemFont(ofSize: 16, weight: .light)
    )
    let myTextField = InsertableTextField()
    
    private let user: MUser
    
    // MARK: Init
    init(user: MUser) {
        self.user = user
        self.nameLabel.text = user.userName
        self.aboutMeLabel.text = user.description
        self.imageView.sd_setImage(with: URL(string: user.avatarStringURL))
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .secondarySystemBackground
        
        customiseElements()
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
        
        let difference = -keyboardSize.height + 30
        
        UIView.animate(withDuration: 0.015) {
            self.containerView.transform = CGAffineTransform(translationX: self.containerView.frame.origin.x, y: difference)
        }
    }
    
    @objc private func keyboardDisappear() {
        UIView.animate(withDuration: 2.0) {
            self.containerView.transform = CGAffineTransform.identity
        }
    }
    
    private func customiseElements() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutMeLabel.translatesAutoresizingMaskIntoConstraints = false
        myTextField.translatesAutoresizingMaskIntoConstraints = false
        
        aboutMeLabel.numberOfLines = 0
        
        containerView.backgroundColor = UIColor(named: "mainWhiteColor")
        containerView.layer.cornerRadius = 30
        
        if let button = myTextField.rightView as? UIButton {
            button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        }
    }
    
    @objc private func sendMessage() {
        
        guard let message = myTextField.text, message != "" else { return }
        
        self.dismiss(animated: true) {
            FirestoreService.shared.createWaitingChat(message: message, receiver: self.user) { result in
                switch result {
                case .success:
                    UIApplication.getTopViewController()?.showAlert(
                        with: "Успешно!",
                        and: "Ваше сообщение для \(self.user.userName) было отправлено!"
                    )
                case .failure(let error):
                    UIApplication.getTopViewController()?.showAlert(with: "Ошибка!", and: error.localizedDescription)
                }
            }
            
        }
    }
    
}

extension ProfileViewController {
    
    private func setupConstraints() {
        
        view.addSubview(imageView)
        view.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(aboutMeLabel)
        containerView.addSubview(myTextField)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: 30)
        ])
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 206)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 35),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24)
        ])
        
        NSLayoutConstraint.activate([
            aboutMeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            aboutMeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            aboutMeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24)
        ])
        
        NSLayoutConstraint.activate([
            myTextField.topAnchor.constraint(equalTo: aboutMeLabel.bottomAnchor, constant: 8),
            myTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            myTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            myTextField.heightAnchor.constraint(equalToConstant: 48)
        ])
        
    }
}

// MARK: - SwiftUI

//import SwiftUI
//
//struct ProfileVCProvider: PreviewProvider {
//    static var previews: some View {
//        ConteinerView()
//            .ignoresSafeArea()
//    }
//
//    struct ConteinerView: UIViewControllerRepresentable {
//
//        let profileVC = ProfileViewController()
//
//        func makeUIViewController(context: UIViewControllerRepresentableContext<ProfileVCProvider.ConteinerView>) -> ProfileViewController {
//            return profileVC
//        }
//
//        func updateUIViewController(_ uiViewController: ProfileVCProvider.ConteinerView.UIViewControllerType, context: UIViewControllerRepresentableContext<ProfileVCProvider.ConteinerView>) {
//
//        }
//    }
//}

