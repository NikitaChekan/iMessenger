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
        text: "You have the opportunity to start a new chat!",
        font: .systemFont(ofSize: 16, weight: .light)
    )
    let acceptButton = UIButton(
        title: "ACCEPT",
        titleColor: .white,
        backgroundColor: .black,
        font: .laoSangamMN20(),
        isShadow: false,
        cornerRadius: 10
    )
    let denyButton = UIButton(
        title: "Deny",
        titleColor: UIColor(named: "buttonRed") ?? .red,
        backgroundColor: UIColor(named: "mainWhiteColor") ?? .white,
        font: .laoSangamMN20(),
        isShadow: false,
        cornerRadius: 10
    )
    
    weak var delegate: WaitingChatNavigation?
    
    private var chat: MChat
    
    init(chat: MChat) {
        self.chat = chat
        nameLabel.text = chat.friendUserName
        imageView.sd_setImage(with: URL(string: chat.friendAvatarStringURL))
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customiseElements()
        setupConstraints()
        
        denyButton.addTarget(self, action: #selector(denyButtonTapped), for: .touchUpInside)
        acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
    }
    
    @objc private func denyButtonTapped() {
        self.dismiss(animated: true) {
            self.delegate?.removeWaitingChat(chat: self.chat)
        }
    }
    
    @objc private func acceptButtonTapped() {
        self.dismiss(animated: true) {
            self.delegate?.chatToActive(chat: self.chat)
        }
    }
    
    private func customiseElements() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutMeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        aboutMeLabel.numberOfLines = 0
                
        denyButton.layer.borderWidth = 1.2
        denyButton.layer.borderColor = UIColor(named: "buttonRed")?.cgColor
        
        containerView.backgroundColor = UIColor(named: "mainWhiteColor")
        containerView.layer.cornerRadius = 30
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        acceptButton.applyGradients(cornerRadius: 10)
    }
}

extension ChatRequestViewController {
    
    private func setupConstraints() {
        
        view.addSubview(imageView)
        view.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(aboutMeLabel)
        
        let buttonsStackView = UIStackView(
            arrangedSubviews: [acceptButton, denyButton],
            axis: .horizontal,
            spacing: 7
        )
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.distribution = .fillEqually
        containerView.addSubview(buttonsStackView)
        
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
            buttonsStackView.topAnchor.constraint(equalTo: aboutMeLabel.bottomAnchor, constant: 24),
            buttonsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            buttonsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
}

// MARK: - SwiftUI

//import SwiftUI
//
//struct ChatRequestVCProvider: PreviewProvider {
//    static var previews: some View {
//        ConteinerView()
//            .ignoresSafeArea()
//    }
//    
//    struct ConteinerView: UIViewControllerRepresentable {
//        
//        let chatRequestVC = ChatRequestViewController()
//        
//        func makeUIViewController(context: UIViewControllerRepresentableContext<ChatRequestVCProvider.ConteinerView>) -> ChatRequestViewController {
//            return chatRequestVC
//        }
//        
//        func updateUIViewController(_ uiViewController: ChatRequestVCProvider.ConteinerView.UIViewControllerType, context: UIViewControllerRepresentableContext<ChatRequestVCProvider.ConteinerView>) {
//            
//        }
//    }
//}

