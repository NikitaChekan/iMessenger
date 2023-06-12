//
//  ActivePlugCell.swift
//  iMessenger
//
//  Created by jopootrivatel on 12.06.2023.
//

import UIKit

final class ActivePlugCell: UICollectionViewCell {
    
    // MARK: Properties
    static var reuseId = "ActivePlugCell"
    let imageView = UIImageView()
    let label = UILabel()
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(named: "backgroundAppColor")
        self.clipsToBounds = true
        
        customizeElements()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    private func customizeElements() {
        imageView.tintColor = UIColor(named: "plugGrayColor")
        
        label.textColor = UIColor(named: "plugGrayColor")
        label.textAlignment = .center
    }
}

// MARK: - Setup constraints
extension ActivePlugCell {
    private func setupConstraints() {
        // Configure imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        // Configure label
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Adding subview
        addSubview(imageView)
        addSubview(label)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 90),
            imageView.widthAnchor.constraint(equalToConstant: 90)
        ])
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5)
        ])
    }
}


// MARK: - Self configuring cell
extension ActivePlugCell: SelfConfiguringCell {
    func configure<U>(with value: U) where U: Hashable {
        guard let text: String = value as? String else {
            fatalError("Unknown model object")
        }
        
        self.imageView.image = UIImage(systemName: "message.badge.filled.fill")
        self.label.text = text
    }
}
