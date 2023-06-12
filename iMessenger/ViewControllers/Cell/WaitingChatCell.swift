//
//  WaitingChatCell.swift
//  iMessenger
//
//  Created by jopootrivatel on 13.04.2023.
//

import UIKit
import SDWebImage

class WaitingChatCell: UICollectionViewCell {
    
    static var reuseId = "WaitingChatCell"
    
    let friendImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .yellow
        
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Constraints
extension WaitingChatCell {
    
    private func setupConstraints() {
        friendImageView.translatesAutoresizingMaskIntoConstraints = false
                
        addSubview(friendImageView)

        NSLayoutConstraint.activate([
            friendImageView.topAnchor.constraint(equalTo: self.topAnchor),
            friendImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            friendImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            friendImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}

// MARK: - Setup Constraints
extension WaitingChatCell: SelfConfiguringCell {
    
    func configure<U>(with value: U) where U : Hashable {
        guard let chat: MChat = value as? MChat else { return }
        friendImageView.sd_setImage(with: URL(string: chat.friendAvatarStringURL))
    }
    
}

// MARK: - SwiftUI

import SwiftUI

struct WaitingChatProvider: PreviewProvider {
    static var previews: some View {
        ConteinerView()
            .ignoresSafeArea()
    }
    
    struct ConteinerView: UIViewControllerRepresentable {
        
        let tabBarVC = MainTabBarController()
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<WaitingChatProvider.ConteinerView>) -> MainTabBarController {
            return tabBarVC
        }
        
        func updateUIViewController(_ uiViewController: WaitingChatProvider.ConteinerView.UIViewControllerType, context: UIViewControllerRepresentableContext<WaitingChatProvider.ConteinerView>) {
            
        }
    }
}
