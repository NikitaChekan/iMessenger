//
//  SignUpViewController.swift
//  iMessenger
//
//  Created by jopootrivatel on 08.04.2023.
//

import UIKit
import SPAlert
import SPIndicator

final class SignUpViewController: UIViewController {
    
    // MARK: Properties
    private let scrollView = UIScrollView()
    private var stackView = UIStackView()
    
    private let welcomeLabel = UILabel(text: "Good to see you!", font: .avenir26())
    
    private let emailLabel = UILabel(text: "Email")
    private let passwordLabel = UILabel(text: "Password")
    private let confirmPasswordLabel = UILabel(text: "Confirm password")
    private let alreadyOnboardLabel = UILabel(text: "Already onboard?")
    
    private let emailTextField = OneLineTextField(font: .avenir20())
    private let passwordTextField = OneLineTextField(font: .avenir20(), isSecure: true)
    private let confirmPasswordTextField = OneLineTextField(font: .avenir20(), isSecure: true)
    
    private let signUpButton = UIButton(
        title: "Sign Up",
        titleColor: .white,
        backgroundColor: UIColor(named: "buttonBlack") ?? .black
    )
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(UIColor(named: "buttonRed"), for: .normal)
        button.titleLabel?.font = .avenir20()
        button.contentHorizontalAlignment = .leading
        return button
    }()
    
    weak var delegate: AuthNavigationDelegate?
    
    private var isPrivatePasswordTextField = true
    private var eyeButtonForPasswordTextField = EyeButton()
    
    private var isPrivateConfirmTextField = true
    private var eyeButtonForConfirmTextField = EyeButton()

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .secondarySystemBackground

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
    
    @objc private func eyeButtonForPasswordTapped() {
        let imageName = isPrivatePasswordTextField ? "eye" : "eye.slash"
        
        passwordTextField.isSecureTextEntry.toggle()
        eyeButtonForPasswordTextField.setImage(UIImage(systemName: imageName), for: .normal)
        isPrivatePasswordTextField.toggle()
    }
    
    @objc private func eyeButtonForConfirmTapped() {
        let imageName = isPrivateConfirmTextField ? "eye" : "eye.slash"
        
        confirmPasswordTextField.isSecureTextEntry.toggle()
        eyeButtonForConfirmTextField.setImage(UIImage(systemName: imageName), for: .normal)
        isPrivateConfirmTextField.toggle()
        
    }
    
    @objc private func signUpButtonTapped() {
        AuthService.shared.register(
            email: emailTextField.text,
            password: passwordTextField.text,
            confirmPassword: confirmPasswordTextField.text
        ) { (result) in
            switch result {
            case .success(let user):
                let indicatorView = SPIndicatorView(title: "Successful", message: "You are registered!", preset: .done)
                indicatorView.present(duration: 3) {
                    self.present(SetupProfileViewController(currentUser: user), animated: true)
                }
            case .failure(let error):
                let alertView = SPAlertView(title: "Error!", message: error.localizedDescription, preset: .error)
                alertView.duration = 4
                alertView.present()
            }
        }
    }
    
    @objc private func loginButtonTapped() {
        self.dismiss(animated: true) {
            self.delegate?.toLoginVC()
        }
    }
    
    // MARK: Methods
    private func configureElements() {
        
        // Configure scrollView
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        
        // Configure welcomeLabel
        welcomeLabel.textAlignment = .center
        
        // Configure emailTextField
        emailTextField.delegate = self
        emailTextField.returnKeyType = .go
        emailTextField.keyboardType = .emailAddress
        emailTextField.tintColor = UIColor(named: "tabBarColor")
        
        // Configure passwordTextField
        passwordTextField.delegate = self
        passwordTextField.returnKeyType = .go
        eyeButtonForPasswordTextField.addTarget(self, action: #selector(eyeButtonForPasswordTapped), for: .touchUpInside)
        passwordTextField.rightView = eyeButtonForPasswordTextField
        passwordTextField.rightViewMode = .always
        passwordTextField.tintColor = UIColor(named: "tabBarColor")
        
        // Configure confirmPasswordTextField
        confirmPasswordTextField.delegate = self
        eyeButtonForConfirmTextField.addTarget(self, action: #selector(eyeButtonForConfirmTapped), for: .touchUpInside)
        confirmPasswordTextField.rightView = eyeButtonForConfirmTextField
        confirmPasswordTextField.rightViewMode = .always
        confirmPasswordTextField.tintColor = UIColor(named: "tabBarColor")
        
        // Configure signUpButton
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        
        // Configure loginButton
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
    }
    
}

// MARK: - Setup Constraints
extension SignUpViewController {
    
    private func setupConstraints() {
        
        // Stack view for emailLabel and emailTextField
        let emailStackView = UIStackView(arrangedSubviews: [emailLabel, emailTextField], axis: .vertical, spacing: 0)
        
        // Stack view for passwordLabel and passwordTextField
        let passwordStackView = UIStackView(arrangedSubviews: [passwordLabel, passwordTextField], axis: .vertical, spacing: 0)
        
        // Stack view for confirmPasswordLabel and confirmPasswordTextField
        let confirmPasswordStackView = UIStackView(arrangedSubviews: [confirmPasswordLabel, confirmPasswordTextField], axis: .vertical, spacing: 0)
        
        // Constrain for signUpButton
        signUpButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // Stack view for emailStackView, passwordStackView, confirmPasswordStackView and signUpButton
        let inputStackView = UIStackView(
            arrangedSubviews: [emailStackView, passwordStackView, confirmPasswordStackView, signUpButton],
            axis: .vertical,
            spacing: 40
        )
        
        // Stack view for welcomeLabel and inputStackView
        let topStackView = UIStackView(arrangedSubviews: [welcomeLabel, inputStackView], axis: .vertical, spacing: 55)
        
        // Stack view for alreadyOnboardLabel and loginButton
        let bottomStackView = UIStackView(arrangedSubviews: [alreadyOnboardLabel, loginButton], axis: .horizontal, spacing: 10)
        bottomStackView.alignment = .firstBaseline
        
        // Stack view for topStackView and bottomStackView
        let stackView = UIStackView(arrangedSubviews: [topStackView, bottomStackView], axis: .vertical, spacing: 20)
        
        
        // Setup stackView
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        
        // Adding subviews
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        // Setup scrollView and StackView
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
            stackView.topAnchor.constraint(greaterThanOrEqualTo: scrollView.contentLayoutGuide.topAnchor, constant: 100),
            stackView.centerXAnchor.constraint(lessThanOrEqualTo: scrollView.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, multiplier: 0.8),
            stackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, multiplier: 0.77)
        ])
        
        self.stackView = stackView
        
    }
}

// MARK: - UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == passwordTextField {
            guard let text = textField.text else { return }
            eyeButtonForPasswordTextField.isEnabled = !text.isEmpty
        } else if textField == confirmPasswordTextField {
            guard let text = textField.text else { return }
            eyeButtonForConfirmTextField.isEnabled = !text.isEmpty
        }
    }
    
}

// MARK: - SwiftUI

import SwiftUI

struct SignUpVCProvider: PreviewProvider {
    static var previews: some View {
        ConteinerView()
            .ignoresSafeArea()
    }
    
    struct ConteinerView: UIViewControllerRepresentable {
        
        let viewController = SignUpViewController()
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<SignUpVCProvider.ConteinerView>) -> SignUpViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: SignUpVCProvider.ConteinerView.UIViewControllerType, context: UIViewControllerRepresentableContext<SignUpVCProvider.ConteinerView>) {
            
        }
    }
}

//extension UIViewController {
//    func showAlert(with title: String, and message: String, completion: @escaping () -> Void = { }) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
//            completion()
//        }
//        alertController.addAction(okAction)
//        present(alertController, animated: true)
//    }
//}
