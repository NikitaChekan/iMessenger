//
//  OneLineTextField.swift
//  iMessenger
//
//  Created by jopootrivatel on 08.04.2023.
//

import UIKit

final class OneLineTextField: UITextField {
    
    // MARK: - Init
    convenience init(font: UIFont? = .avenir20(), isSecure: Bool = false) {
        self.init()
        
        self.font = font
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.borderStyle = .none
        
        var bottomView = UIView()
        bottomView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        bottomView.backgroundColor = UIColor(named: "textFieldLight")
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(bottomView)
        
        NSLayoutConstraint.activate([
            bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        isSecureTextEntry = isSecure
    }
}
