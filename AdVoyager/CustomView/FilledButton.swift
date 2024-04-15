//
//  FilledButton.swift
//  AdVoyager
//
//  Created by Minho on 4/12/24.
//

import UIKit

final class FilledButton: UIButton {
    
    init(title: String, fillColor: UIColor) {
        super.init(frame: .zero)
        
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        backgroundColor = fillColor
        clipsToBounds = true
        layer.cornerRadius = 16
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
