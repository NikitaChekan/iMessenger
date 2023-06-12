//
//  WaitingPlugCell.swift
//  iMessenger
//
//  Created by jopootrivatel on 12.06.2023.
//

import UIKit

final class WaitingPlugCell: UICollectionViewCell {
    // MARK: Properties
    
    static var reuseId = "WaitingPlugCell"
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
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
    }
}

// MARK: - Setup constraints

extension WaitingPlugCell {
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
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            imageView.heightAnchor.constraint(equalToConstant: 65),
            imageView.widthAnchor.constraint(equalToConstant: 65)
        ])
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 3)
        ])
    }
}

// MARK: - Self configuring cell

extension WaitingPlugCell: SelfConfiguringCell {
    func configure<U>(with value: U) where U : Hashable {
        guard let text: String = value as? String else {
            fatalError("Unknown model object")
        }
        
        self.imageView.image = UIImage(systemName: "message.badge")
        self.label.text = text
    }
}
