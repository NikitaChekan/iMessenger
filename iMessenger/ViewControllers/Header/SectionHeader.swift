//
//  SectionHeader.swift
//  iMessenger
//
//  Created by jopootrivatel on 14.04.2023.
//

import UIKit

final class SectionHeader: UICollectionReusableView {
    
    // MARK: - Properties
    static let reuseId = "SectionHeader"
    let title = UILabel()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupConstraints()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    func configure(text: String, font: UIFont?, textColor: UIColor) {
        title.text = text
        title.font = font
        title.textColor = textColor
    }
    
}

// MARK: - Setup Constraints
extension SectionHeader {
    
    private func setupConstraints() {
        title.translatesAutoresizingMaskIntoConstraints = false
                
        addSubview(title)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: self.topAnchor),
            title.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            title.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
}
