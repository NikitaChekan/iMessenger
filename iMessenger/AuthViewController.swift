//
//  ViewController.swift
//  iMessenger
//
//  Created by jopootrivatel on 08.04.2023.
//

import UIKit

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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink
        
    }


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

