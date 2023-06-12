//
//  UserCell.swift
//  iMessenger
//
//  Created by jopootrivatel on 17.04.2023.
//

import UIKit
import SDWebImage

class UserCell: UICollectionViewCell {
    
    let userImageView = UIImageView()
    let userName = UILabel(text: "text", font: .laoSangamMN20())
    let containerView = UIView()
    
    static var reuseId = "UserCell"

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 4
        
        layer.shadowColor = UIColor(named: "shadowColor")?.cgColor
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 4)

        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.containerView.layer.cornerRadius = 4
        self.containerView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        userImageView.image = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Setup Constraints
extension UserCell {
    
    private func setupConstraints() {
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userName.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.addSubview(userImageView)
        containerView.addSubview(userName)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            userImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            userImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            userImageView.heightAnchor.constraint(equalTo: containerView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            userName.topAnchor.constraint(equalTo: userImageView.bottomAnchor),
            userName.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            userName.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -8),
            userName.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
}

// MARK: - Setup Constraints
extension UserCell: SelfConfiguringCell {
    
    func configure<U>(with value: U) where U : Hashable {
        guard let user: MUser = value as? MUser else { return }
        userName.text = user.userName
        guard let url = URL(string: user.avatarStringURL) else { return }
        userImageView.sd_setImage(with: url)
    }
    
}

// MARK: - SwiftUI

import SwiftUI

struct UserCellProvider: PreviewProvider {
    static var previews: some View {
        ConteinerView()
            .ignoresSafeArea()
    }
    
    struct ConteinerView: UIViewControllerRepresentable {
        
        let tabBarVC = MainTabBarController()
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<UserCellProvider.ConteinerView>) -> MainTabBarController {
            return tabBarVC
        }
        
        func updateUIViewController(_ uiViewController: UserCellProvider.ConteinerView.UIViewControllerType, context: UIViewControllerRepresentableContext<UserCellProvider.ConteinerView>) {
            
        }
    }
}
