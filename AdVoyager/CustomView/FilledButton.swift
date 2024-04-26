//
//  FilledButton.swift
//  AdVoyager
//
//  Created by Minho on 4/12/24.
//

import UIKit

final class FilledButton: UIButton {
    
    init(title: String? = nil, image: UIImage? = nil, fillColor: UIColor? = .systemBlue) {
        super.init(frame: .zero)
        
        print("버튼 초기화됐다~")
        
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        setImage(image, for: .normal)
        tintColor = .white
        contentMode = .scaleAspectFill
        backgroundColor = fillColor
        clipsToBounds = true
        layer.cornerRadius = 16
    }
    
    func circle() {
        layer.cornerRadius = frame.height / 2
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
