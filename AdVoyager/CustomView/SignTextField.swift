//
//  SignTextField.swift
//  LSLPBasic
//
//  Created by jack on 2024/04/09.
//

import UIKit

class SignTextField: UITextField {
    
    init(placeholderText: String, isSecured: Bool = false) {
        super.init(frame: .zero)
        
        textColor = .text
        placeholder = placeholderText
        isSecureTextEntry = isSecured
        textAlignment = .center
        borderStyle = .none
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray3.cgColor
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}
