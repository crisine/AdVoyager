//
//  FilledButton.swift
//  AdVoyager
//
//  Created by Minho on 4/12/24.
//

import UIKit

final class FilledButton: UIButton {
    
    init(title: String? = nil, image: UIImage? = nil, fillColor: UIColor? = .lightpurple) {
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
        
        addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
            addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
    }
    
    @objc private func touchDown(_ sender: UIButton) {
        // 눌렸을때
        backgroundColor = .darkPurple
    }

    @objc private func touchUpInside(_ sender: UIButton) {
        // 뗐을 때
        backgroundColor = .lightpurple
    }
    
    func circle() {
        layer.cornerRadius = frame.height / 2
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
