//
//  EyeButton.swift
//  iMessenger
//
//  Created by jopootrivatel on 19.05.2023.
//

import UIKit

final class EyeButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupEyeButton()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not benn implement")
    }
    
    private func setupEyeButton() {
        setImage(UIImage(systemName: "eye.slash"), for: .normal)
        tintColor = .label
        isEnabled = false
        
        widthAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
}
