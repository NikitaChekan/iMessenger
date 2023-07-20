//
//  ActiveChatCell.swift
//  iMessenger
//
//  Created by jopootrivatel on 13.04.2023.
//

import UIKit
import SDWebImage

class ActiveChatCell: UICollectionViewCell {
    
    // MARK: - Property
    static var reuseId = "ActiveChatCell"
    
    let friendImageView = UIImageView()
    let friendName = UILabel(text: "User name", font: .laoSangamMN20())
    let dateLabel = UILabel(text: "01.01.2021", font: .systemFont(ofSize: 14))
    let countLabel = BadgeLabel(backgroundColor: .darkGray, text: "1")
    let lastMessage = UILabel(text: "How are you Nick?", font: .laoSangamMN17())
    let gradientView = GradientView(
        from: .topTrailing,
        to: .bottomLeading,
        startColor: #colorLiteral(red: 0.7882352941, green: 0.631372549, blue: 0.9411764706, alpha: 1),
        endColor: #colorLiteral(red: 0.4784313725, green: 0.6980392157, blue: 0.9215686275, alpha: 1),
        animate: true
    )
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        
        customizeElements()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    private func customizeElements() {
        
        // Configure friendImageView
        friendImageView.translatesAutoresizingMaskIntoConstraints = false
        friendImageView.contentMode = .scaleAspectFill
        friendImageView.clipsToBounds = true
        
        // Configure friendName
        friendName.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure dateLabel
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textColor = .darkGray
        dateLabel.textAlignment = .right
        
        // Configure lastMessage
        lastMessage.translatesAutoresizingMaskIntoConstraints = false
        lastMessage.textColor = .darkGray
        
        // Configure conunLabel
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure gradientView
        gradientView.translatesAutoresizingMaskIntoConstraints = false
    }
    
}

// MARK: - Setup Constraints
extension ActiveChatCell {
    
    private func setupConstraints() {
        // Configure content hugging priority
        friendName.setContentHuggingPriority(UILayoutPriority(rawValue: 250), for: .horizontal)
        dateLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
        
        lastMessage.setContentHuggingPriority(UILayoutPriority(rawValue: 250), for: .horizontal)
        countLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
        
        // Adding subviews
        addSubview(friendImageView)
        addSubview(friendName)
        addSubview(dateLabel)
        addSubview(lastMessage)
        addSubview(countLabel)
        addSubview(gradientView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            friendImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            friendImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            friendImageView.heightAnchor.constraint(equalToConstant: 78),
            friendImageView.widthAnchor.constraint(equalToConstant: 78)
        ])
        
        NSLayoutConstraint.activate([
            friendName.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            friendName.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 16),
            friendName.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor, multiplier: 0.53)
        ])
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: friendName.trailingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: -8),
            dateLabel.heightAnchor.constraint(equalTo: friendName.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            lastMessage.bottomAnchor.constraint(equalTo: bottomAnchor, constant:  -14),
            lastMessage.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 16),
            lastMessage.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.53)
        ])
        
        NSLayoutConstraint.activate([
            countLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant:  -12),
            countLabel.leadingAnchor.constraint(greaterThanOrEqualTo: lastMessage.trailingAnchor, constant: 8),
            countLabel.trailingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: -8),
            countLabel.heightAnchor.constraint(equalTo: lastMessage.heightAnchor, constant: 4),
        ])
        
        NSLayoutConstraint.activate([
            gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gradientView.centerYAnchor.constraint(equalTo: centerYAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 78),
            gradientView.widthAnchor.constraint(equalToConstant: 8)
        ])
    }
}

// MARK: - Setup Constraints
extension ActiveChatCell: SelfConfiguringCell {
    func configure<U>(with value: U) where U : Hashable {
        guard let chat: MChat = value as? MChat else { return }
        friendName.text = chat.friendUserName
        lastMessage.text = chat.lastMessageContent
        dateLabel.text = DateHelper.format(for: chat.lastMessageDate)
        countLabel.isHidden = true
        friendImageView.sd_setImage(with: URL(string: chat.friendAvatarStringURL))
    }
}

// MARK: - SwiftUI

//import SwiftUI
//
//struct ActiveChatProvider: PreviewProvider {
//    static var previews: some View {
//        ConteinerView()
//            .ignoresSafeArea()
//    }
//
//    struct ConteinerView: UIViewControllerRepresentable {
//
//        let tabBarVC = MainTabBarController()
//
//        func makeUIViewController(context: UIViewControllerRepresentableContext<ActiveChatProvider.ConteinerView>) -> MainTabBarController {
//            return tabBarVC
//        }
//
//        func updateUIViewController(_ uiViewController: ActiveChatProvider.ConteinerView.UIViewControllerType, context: UIViewControllerRepresentableContext<ActiveChatProvider.ConteinerView>) {
//
//        }
//    }
//}
