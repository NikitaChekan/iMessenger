//
//  ViewController.swift
//  iMessenger
//
//  Created by jopootrivatel on 08.04.2023.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

class AuthViewController: UIViewController {
    
    let logoImageView = UIImageView(image: UIImage(named: "Logo"), contentMode: .scaleAspectFit)
    
    let googleLabel = UILabel(text: "Get started with")
    let emailLabel = UILabel(text: "Or sign up with")
    let alreadyOnboardLabel = UILabel(text: "Already onboard?")
    
    let googleButton = UIButton(
        title: "Google",
        titleColor: .black,
        backgroundColor: .white,
        isShadow: true
    )
    
    let emailButton = UIButton(
        title: "Email",
        titleColor: .white,
        backgroundColor: UIColor(named: "buttonBlack") ?? .black
    )
    
    let loginButton = UIButton(
        title: "Login",
        titleColor: UIColor(named: "buttonRed") ?? .red,
        backgroundColor: .white,
        isShadow: true
    )
    
    let signUpVC = SignUpViewController()
    let loginVC = LoginViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        googleButton.customizeGoogleButton()
        setupConstraints()
        
        emailButton.addTarget(self, action: #selector(emailButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        googleButton.addTarget(self, action: #selector(googleButtonTapped), for: .touchUpInside)

        signUpVC.delegate = self
        loginVC.delegate = self
    }
    
    @objc private func emailButtonTapped() {
        present(signUpVC, animated: true)
    }
    
    @objc private func loginButtonTapped() {
        present(loginVC, animated: true)
    }
    
    @objc private func googleButtonTapped() async {
        await AuthService.shared.googleLogin()
    }
    
}

// MARK: - Setup Constraints
extension AuthViewController {
    
    private func setupConstraints() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let googleView = ButtonFormView(label: googleLabel, button: googleButton)
        let emailView = ButtonFormView(label: emailLabel, button: emailButton)
        let loginView = ButtonFormView(label: alreadyOnboardLabel, button: loginButton)
        
        let stackView = UIStackView(
            arrangedSubviews: [googleView, emailView, loginView],
            axis: .vertical,
            spacing: 40
        )
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(logoImageView)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 160),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 160),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
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

//// MARK: - GIDSignInDelegate
//extension AuthViewController: GIDSignInDelegate {
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        AuthService.shared.googleLogin(user: user, error: error) { (result) in
//            switch result {
//            case .success(let user):
//                FirestoreService.shared.getUserData(user: user) { (result) in
//                    switch result {
//                    case .success(let muser):
//                        UIApplication.getTopViewController()?.showAlert(with: "Успешно", and: "Вы авторизованы") {
//                            let mainTabBar = MainTabBarController(currentUser: muser)
//                            mainTabBar.modalPresentationStyle = .fullScreen
//                            UIApplication.getTopViewController()?.present(mainTabBar, animated: true, completion: nil)
//                        }
//                    case .failure(_):
//                        UIApplication.getTopViewController()?.showAlert(with: "Успешно", and: "Вы зарегистрированны") {
//                            UIApplication.getTopViewController()?.present(SetupProfileViewController(currentUser: user), animated: true, completion: nil)
//                        }
//                    } // result
//                }
//            case .failure(let error):
//                self.showAlert(with: "Ошибка", and: error.localizedDescription)
//            }
//        }
//    }
//}

// 35 урок 5 минута

// MARK: - Google Sign-In
extension AuthViewController {
    
}

// MARK: - SwiftUI

import SwiftUI

struct AuthVCProvider: PreviewProvider {
    static var previews: some View {
        ConteinerView()
            .ignoresSafeArea()
    }
    
    struct ConteinerView: UIViewControllerRepresentable {
        
        let viewController = AuthViewController()
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<AuthVCProvider.ConteinerView>) -> AuthViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: AuthVCProvider.ConteinerView.UIViewControllerType, context: UIViewControllerRepresentableContext<AuthVCProvider.ConteinerView>) {
            
        }
    }
}

