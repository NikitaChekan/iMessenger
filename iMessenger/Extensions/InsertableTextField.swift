//
//  InsertableTextField.swift
//  iMessenger
//
//  Created by jopootrivatel on 17.04.2023.
//

import UIKit

class InsertableTextField: UITextField {
    
    private var isEmoji: Bool = false
    
    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if isEmoji {
                if mode.primaryLanguage == "emoji" {
                    self.isEmoji = false
                    return mode
                }
            }
        }
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(named: "textFieldLight")
        placeholder = "Write something here..."
        font = UIFont.systemFont(ofSize: 14)
        clearButtonMode = .whileEditing
        borderStyle = .none
        layer.cornerRadius = 18
        layer.masksToBounds = true
        
        let leftButton = UIButton(type: .system)
        leftButton.setImage(UIImage(systemName: "smiley"), for: .normal)
        leftButton.tintColor = .lightGray
        leftButton.addTarget(self, action: #selector(showEmoji), for: .touchUpInside)
        
        leftView = leftButton
        leftView?.frame = CGRect(x: 0, y: 0, width: 19, height: 19)
        leftViewMode = .always
        
//        let image = UIImage(systemName: "smiley")
//        let imageView = UIImageView(image: image)
//        imageView.setupColor(color: .lightGray)
//        leftView = imageView
//        leftViewMode = .always
        
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "Sent"), for: .normal)
        button.applyGradients(cornerRadius: 10)
        
        rightView = button
        rightView?.frame = CGRect(x: 0, y: 0, width: 19, height: 19)
        rightViewMode = .always
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func showEmoji() {
        self.isEmoji = true
        self.becomeFirstResponder()
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += 12
        return rect
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x -= 12
        return rect
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 42, dy: 0)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 42, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 42, dy: 0)
    }
    
}

// MARK: - SwiftUI

//import SwiftUI
//
//struct TextFieldProvider: PreviewProvider {
//    static var previews: some View {
//        ConteinerView()
//            .ignoresSafeArea()
//    }
//    
//    struct ConteinerView: UIViewControllerRepresentable {
//        
//        let profileVC = ProfileViewController()
//        
//        func makeUIViewController(context: UIViewControllerRepresentableContext<TextFieldProvider.ConteinerView>) -> ProfileViewController {
//            return profileVC
//        }
//        
//        func updateUIViewController(_ uiViewController: TextFieldProvider.ConteinerView.UIViewControllerType, context: UIViewControllerRepresentableContext<TextFieldProvider.ConteinerView>) {
//            
//        }
//    }
//}
