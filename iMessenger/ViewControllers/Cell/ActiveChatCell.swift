//
//  ActiveChatCell.swift
//  iMessenger
//
//  Created by jopootrivatel on 13.04.2023.
//

import UIKit
import SDWebImage

class ActiveChatCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseId = "ActiveChatCell"
    
    let friendImageView = UIImageView()
    let friendName = UILabel(text: "User name", font: .laoSangamMN20())
    let lastMessage = UILabel(text: "How are you Nick?", font: .laoSangamMN18())
    let gradientView = GradientView(
        from: .topTrailing,
        to: .bottomLeading,
        startColor: UIColor(named: "firstGradientColor"),
        endColor: UIColor(named: "secondGradientColor")
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        
        setupConstraints()
        
    }
    
    func configure<U>(with value: U) where U : Hashable {
        guard let chat: MChat = value as? MChat else { return }
        friendName.text = chat.friendUserName
        lastMessage.text = chat.lastMessageContent
        friendImageView.sd_setImage(with: URL(string: chat.friendAvatarStringURL))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Constraints
extension ActiveChatCell {
    
    private func setupConstraints() {
        friendImageView.translatesAutoresizingMaskIntoConstraints = false
        friendName.translatesAutoresizingMaskIntoConstraints = false
        lastMessage.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        friendImageView.backgroundColor = .orange
        gradientView.backgroundColor = .black
        
        addSubview(friendImageView)
        addSubview(friendName)
        addSubview(lastMessage)
        addSubview(gradientView)

        NSLayoutConstraint.activate([
            friendImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            friendImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            friendImageView.heightAnchor.constraint(equalToConstant: 78),
            friendImageView.widthAnchor.constraint(equalToConstant: 78)
        ])
        
        NSLayoutConstraint.activate([
            friendName.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            friendName.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 16),
            friendName.trailingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 16)
        ])
        
        NSLayoutConstraint.activate([
            lastMessage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -14),
            lastMessage.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 16),
            lastMessage.trailingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 16)
        ])
        
        NSLayoutConstraint.activate([
            gradientView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            gradientView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 78),
            gradientView.widthAnchor.constraint(equalToConstant: 10)
        ])
        
    }
}

// MARK: - SwiftUI

import SwiftUI

struct ActiveChatProvider: PreviewProvider {
    static var previews: some View {
        ConteinerView()
            .ignoresSafeArea()
    }
    
    struct ConteinerView: UIViewControllerRepresentable {
        
        let tabBarVC = MainTabBarController()
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<ActiveChatProvider.ConteinerView>) -> MainTabBarController {
            return tabBarVC
        }
        
        func updateUIViewController(_ uiViewController: ActiveChatProvider.ConteinerView.UIViewControllerType, context: UIViewControllerRepresentableContext<ActiveChatProvider.ConteinerView>) {
            
        }
    }
}

