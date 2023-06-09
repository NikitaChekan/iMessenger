//
//  ViewController.swift
//  iMessenger
//
//  Created by jopootrivatel on 08.04.2023.
//

import UIKit
import SPConfetti
import SPAlert

final class AuthViewController: UIViewController {
    
    // MARK: Properties
    private let logoImageView = UIImageView(image: UIImage(named: "Logo-White"), contentMode: .scaleAspectFit)
    
    private let googleLabel = UILabel(text: "Get started with")
    private let emailLabel = UILabel(text: "Or sign up with")
    private let alreadyOnboardLabel = UILabel(text: "Already onboard?")
    
    private let googleButton = UIButton(
        title: "Google",
        titleColor: .black,
        backgroundColor: .white,
        isShadow: true
    )
    
    private let emailButton = UIButton(
        title: "Email",
        titleColor: .white,
        backgroundColor: UIColor(named: "buttonBlack") ?? .black
    )
    
    private let loginButton = UIButton(
        title: "Login",
        titleColor: UIColor(named: "buttonRed") ?? .red,
        backgroundColor: .white,
        isShadow: true
    )
    
    let signUpVC = SignUpViewController()
    let loginVC = LoginViewController()

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        googleButton.customizeGoogleButton()
        
        configureView()
        configureButtons()
        setupConstraints()
    }
    
    // MARK: Actions
    
    @objc private func logoImageTapped() {
        SPConfetti.startAnimating(.fullWidthToDown, particles: [.triangle, .arc], duration: 3)
    }
    
    @objc private func emailButtonTapped() {
        present(signUpVC, animated: true)
    }
    
    @objc private func loginButtonTapped() {
        present(loginVC, animated: true)
    }
    
    @objc private func googleButtonTapped() {
        AuthService.shared.signInGoogle(self) { result in
            switch result {
            case .success(let user):
                FirestoreService.shared.getUserData(user: user) { result in
                    switch result {
                    case .success(let mUser):
                        let mainTabBarController = MainTabBarController(currentUser: mUser)
                        mainTabBarController.modalPresentationStyle = .fullScreen
                        self.present(mainTabBarController, animated: true)
                    case .failure(_):
                        self.present(SetupProfileViewController(currentUser: user), animated: true)
                    }
                }
            case .failure(let error):
                let alertView = SPAlertView(title: "Error!", message: error.localizedDescription, preset: .error)
                alertView.duration = 4
                alertView.present()             }
        }
    }
    
    // MARK: Override Methods
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        switch traitCollection.userInterfaceStyle {
        case .unspecified:
            break
        case .light:
            logoImageView.image = UIImage(named: "Logo-White")
        case .dark:
            logoImageView.image = UIImage(named: "Logo-Black")
        @unknown default:
            break
        }
        
    }
    
    // MARK: Methods
    private func configureView() {
        view.backgroundColor = .secondarySystemBackground
        
        let image = traitCollection.userInterfaceStyle == .light ? UIImage(named: "Logo-White") : UIImage(named: "Logo-Black")
        logoImageView.image = image
        
        // Configure delegate for signUpVC and loginVC
        signUpVC.delegate = self
        loginVC.delegate = self
        
        // Configure logoImageView
        logoImageView.layer.shadowColor = UIColor.black.cgColor
        logoImageView.layer.shadowRadius = 4
        logoImageView.layer.shadowOpacity = 0.5
        logoImageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        
    }
    
    private func configureButtons() {
        
        // Configure logoImageView
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(logoImageTapped))
        logoImageView.isUserInteractionEnabled = true
        logoImageView.addGestureRecognizer(tapGestureRecognizer)
        
        // Configure emailButton
        emailButton.addTarget(self, action: #selector(emailButtonTapped), for: .touchUpInside)
        
        // Configure loginButton
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        // Configure googleButton
        googleButton.addTarget(self, action: #selector(googleButtonTapped), for: .touchUpInside)
            
    }
    
}

// MARK: - Setup Constraints
extension AuthViewController {
    
    private func setupConstraints() {
        
        // Logo Image View
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // View for googleLabel and googleButton
        let googleView = ButtonFormView(label: googleLabel, button: googleButton)
        
        // View for emailLabel and emailButton
        let emailView = ButtonFormView(label: emailLabel, button: emailButton)
        
        // View for alreadyOnboardLabel and loginButton
        let loginView = ButtonFormView(label: alreadyOnboardLabel, button: loginButton)
        
        // Stack view for googleView, emailView and loginView
        let stackView = UIStackView(
            arrangedSubviews: [googleView, emailView, loginView],
            axis: .vertical,
            spacing: 40
        )
        
        // Configure stackView
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Adding subviews
        view.addSubview(logoImageView)
        view.addSubview(stackView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor, constant: 160),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(greaterThanOrEqualTo: logoImageView.bottomAnchor, constant: 0),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -70)
        ])
    }
    
}

// MARK: - AuthNavigationDelegate
extension AuthViewController: AuthNavigationDelegate {
    func toLoginVC() {
        present(loginVC, animated: true)
    }
    
    func toSignUpVC() {
        present(signUpVC, animated: true)
    }
    
}

// MARK: - SwiftUI

//import SwiftUI
//
//struct AuthVCProvider: PreviewProvider {
//    static var previews: some View {
//        ConteinerView()
//            .ignoresSafeArea()
//    }
//    
//    struct ConteinerView: UIViewControllerRepresentable {
//        
//        let viewController = AuthViewController()
//        
//        func makeUIViewController(context: UIViewControllerRepresentableContext<AuthVCProvider.ConteinerView>) -> AuthViewController {
//            return viewController
//        }
//        
//        func updateUIViewController(_ uiViewController: AuthVCProvider.ConteinerView.UIViewControllerType, context: UIViewControllerRepresentableContext<AuthVCProvider.ConteinerView>) {
//            
//        }
//    }
//}

