//
//  LoginViewController.swift
//  iMessenger
//
//  Created by jopootrivatel on 09.04.2023.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    let welcomeLabel = UILabel(text: "Welcome back!", font: .avenir26())
    
    let loginWithLabel = UILabel(text: "Login with")
    let orLabel = UILabel(text: "or")
    let emailLabel = UILabel(text: "Email")
    let passwordLabel = UILabel(text: "Password")
    let needAnAccountLabel = UILabel(text: "Need an account?")
    
    let googleButton = UIButton(
        title: "Google",
        titleColor: .black,
        backgroundColor: .white,
        isShadow: true
    )
    
    
    let loginButton = UIButton(
        title: "Login",
        titleColor: .white,
        backgroundColor: UIColor(named: "buttonBlack") ?? .black
    )
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(UIColor(named: "buttonRed"), for: .normal)
        button.titleLabel?.font = .avenir20()
        return button
    }()
    
    let emailTextField = OneLineTextField(font: .avenir20())
    let passwordTextField = OneLineTextField(font: .avenir20(), isSecure: true)
    
    weak var delegate: AuthNavigationDelegate?
    
    private var isPrivate = true
    private var eyeButton = EyeButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        googleButton.customizeGoogleButton()
        setupConstraints()
        
        configureElements()
        
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
    
    @objc private func eyeButtonTapped() {
        let imageName = isPrivate ? "eye" : "eye.slash"
        
        passwordTextField.isSecureTextEntry.toggle()
        eyeButton.setImage(UIImage(systemName: imageName), for: .normal)
        isPrivate.toggle()
        
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
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
            }
        }
    }
    
    @objc private func loginButtonTapped() {
        AuthService.shared.login(
            email: emailTextField.text!,
            password: passwordTextField.text!
        ) { (result) in
            switch result {
            case .success(let user):
                self.showAlert(with: "Успешно!", and: "Вы авторизованы!") {
                    FirestoreService.shared.getUserData(user: user) { (result) in
                        switch result {
                        case .success(let mUser):
                            let mainTabBar = MainTabBarController(currentUser: mUser)
                            mainTabBar.modalPresentationStyle = .fullScreen
                            self.present(mainTabBar, animated: true)
                        case .failure(_):
                            self.present(SetupProfileViewController(currentUser: user), animated: true)
                        }
                    }
                }
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
            }
        }
    }
    
    @objc private func signUpButtonTapped() {
        dismiss(animated: true) {
            self.delegate?.toSignUpVC()
        }
        present(SignUpViewController(), animated: true)
    }
    
// MARK: Methods
    private func configureElements() {
        
        // Configure scrollView
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        
        // Configure welcomeLabel
        welcomeLabel.textAlignment = .center
        
        // Configure googleButton
        googleButton.addTarget(self, action: #selector(googleButtonTapped), for: .touchUpInside)

        // Configure emailTextField
        emailTextField.delegate = self
        emailTextField.returnKeyType = .go
        emailTextField.keyboardType = .emailAddress
        
        // Configure passwordTextField
        passwordTextField.delegate = self
        eyeButton.addTarget(self, action: #selector(eyeButtonTapped), for: .touchUpInside)
        passwordTextField.rightView = eyeButton
        passwordTextField.rightViewMode = .always
        
        // Configure loginButton
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        // Configure signInButton
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        
    }
    
}

// MARK: - Setup Constraints
extension LoginViewController {
    
    private func setupConstraints() {
        
        let loginWithView = ButtonFormView(label: loginWithLabel, button: googleButton)
        let emailStackView = UIStackView(
            arrangedSubviews: [emailLabel, emailTextField],
            axis: .vertical,
            spacing: 0
        )
        let passwordStackView = UIStackView(
            arrangedSubviews: [passwordLabel, passwordTextField],
            axis: .vertical,
            spacing: 0
        )
    
        loginButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        let stackView = UIStackView(
            arrangedSubviews: [loginWithView, orLabel, emailStackView, passwordStackView, loginButton],
            axis: .vertical,
            spacing: 40
        )
        
        signUpButton.contentHorizontalAlignment = .leading
        let bottomStackView = UIStackView(arrangedSubviews: [needAnAccountLabel, signUpButton], axis: .horizontal, spacing: 10)
        bottomStackView.alignment = .firstBaseline
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(welcomeLabel)
        view.addSubview(stackView)
        view.addSubview(bottomStackView)
        
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 120),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 90),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate([
            bottomStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            bottomStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            bottomStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])

    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == passwordTextField {
            guard let text = textField.text else { return }
            eyeButton.isEnabled = !text.isEmpty
        }
    }
    
}

// MARK: - SwiftUI

import SwiftUI

struct LoginVCProvider: PreviewProvider {
    static var previews: some View {
        ConteinerView()
            .ignoresSafeArea()
    }
    
    struct ConteinerView: UIViewControllerRepresentable {
        
        let viewController = LoginViewController()
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<LoginVCProvider.ConteinerView>) -> LoginViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: LoginVCProvider.ConteinerView.UIViewControllerType, context: UIViewControllerRepresentableContext<LoginVCProvider.ConteinerView>) {
            
        }
    }
}
