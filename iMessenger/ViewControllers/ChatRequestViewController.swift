//
//  ChatRequestViewController.swift
//  iMessenger
//
//  Created by jopootrivatel on 18.04.2023.
//

import UIKit

class ChatRequestViewController: UIViewController {
    
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
    let acceptButton = UIButton(
        title: "ACCEPT",
        titleColor: .white,
        backgroundColor: .black,
        isShadow: true
    )
    let denyButton = UIButton(
        title: "Deny",
        titleColor: .red,
        backgroundColor: .white,
        isShadow: true
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customiseElements()
        setupConstraints()
    }
    
    private func customiseElements() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutMeLabel.translatesAutoresizingMaskIntoConstraints = false
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        denyButton.translatesAutoresizingMaskIntoConstraints = false
        
        aboutMeLabel.numberOfLines = 0
        
        containerView.backgroundColor = UIColor(named: "mainWhiteColor")
        containerView.layer.cornerRadius = 30
    }
}

extension ChatRequestViewController {
    
    private func setupConstraints() {
        
        view.addSubview(imageView)
        view.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(aboutMeLabel)
        containerView.addSubview(acceptButton)
        containerView.addSubview(denyButton)

        
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
            acceptButton.topAnchor.constraint(equalTo: aboutMeLabel.bottomAnchor, constant: 8),
            acceptButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            acceptButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -200),
            acceptButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        NSLayoutConstraint.activate([
            denyButton.topAnchor.constraint(equalTo: aboutMeLabel.bottomAnchor, constant: 8),
            denyButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 200),
            denyButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            denyButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}

// MARK: - SwiftUI

import SwiftUI

struct ChatRequestVCProvider: PreviewProvider {
    static var previews: some View {
        ConteinerView()
            .ignoresSafeArea()
    }
    
    struct ConteinerView: UIViewControllerRepresentable {
        
        let chatRequestVC = ChatRequestViewController()
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<ChatRequestVCProvider.ConteinerView>) -> ChatRequestViewController {
            return chatRequestVC
        }
        
        func updateUIViewController(_ uiViewController: ChatRequestVCProvider.ConteinerView.UIViewControllerType, context: UIViewControllerRepresentableContext<ChatRequestVCProvider.ConteinerView>) {
            
        }
    }
}

