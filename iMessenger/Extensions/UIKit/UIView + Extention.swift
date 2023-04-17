//
//  UIView + Extention.swift
//  iMessenger
//
//  Created by jopootrivatel on 17.04.2023.
//

import UIKit

extension UIView {
    
    func applyGradients(cornerRadius: CGFloat) {
        self.backgroundColor = nil
        self.layoutIfNeeded()
        
        let gradientView = GradientView(
            from: .topTrailing,
            to: .bottomLeading,
            startColor: UIColor(named: "firstGradientColor"),
            endColor: UIColor(named: "secondGradientColor")
        )
        
        if let gradientLayer = gradientView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = self.bounds
            gradientLayer.cornerRadius = cornerRadius
            
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
}
