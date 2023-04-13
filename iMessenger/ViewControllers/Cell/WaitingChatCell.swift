//
//  WaitingChatCell.swift
//  iMessenger
//
//  Created by jopootrivatel on 13.04.2023.
//

import UIKit

class WaitingChatCell: UICollectionViewCell, SelfConfiguringCell {
    
    static var reuseId = "WaitingChatCell"
    
    let friendImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        
        setupConstraints()
    }
    
    func configure(with value: MChat) {
        friendImageView.image = UIImage(named: value.userImageString)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup Constraints
extension WaitingChatCell {
    
    private func setupConstraints() {
        friendImageView.translatesAutoresizingMaskIntoConstraints = false
        
        friendImageView.backgroundColor = .orange
        
        addSubview(friendImageView)

        NSLayoutConstraint.activate([
            friendImageView.topAnchor.constraint(equalTo: self.topAnchor),
            friendImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            friendImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            friendImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        
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
