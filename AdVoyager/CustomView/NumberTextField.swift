//
//  NumberTextField.swift
//  AdVoyager
//
//  Created by Minho on 4/16/24.
//

import UIKit

class NumberTextField: UITextField {

    init(placeholderText: String) {
        super.init(frame: .zero)
        
        textColor = .text
        placeholder = placeholderText
        textAlignment = .center
        borderStyle = .none
        layer.cornerRadius = 16
        keyboardType = .numberPad
        backgroundColor = .systemGray6
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
