//
//  ContentTextView.swift
//  AdVoyager
//
//  Created by Minho on 4/22/24.
//

import UIKit

class ContentTextView: UITextView {

    init(placeholderText: String?) {
        super.init(frame: .zero, textContainer: .none)
        
        font = .systemFont(ofSize: 16)
        if let placeholderText {
            text = placeholderText
            textColor = UIColor.lightGray
        } else {
            textColor = .black
        }
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray3.cgColor
        textContainer.lineFragmentPadding = 0
        textContainerInset = .init(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
