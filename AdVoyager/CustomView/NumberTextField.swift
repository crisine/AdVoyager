//
//  NumberTextField.swift
//  AdVoyager
//
//  Created by Minho on 4/16/24.
//

import UIKit
import RxSwift

class NumberTextField: UITextField {
    
    let disposeBag = DisposeBag()

    init(placeholderText: String) {
        super.init(frame: .zero)
        
        textColor = .text
        placeholder = placeholderText
        textAlignment = .center
        borderStyle = .none
        layer.cornerRadius = 16
        keyboardType = .numberPad
        backgroundColor = .systemGray6
        
        rx.editingDidBegin
            .subscribe(with: self) { owner, _ in
                UIView.animate(withDuration: 0.3) {
                    owner.layer.borderWidth = 1.5
                    owner.layer.borderColor = UIColor.lightpurple.cgColor
                }
            }
            .disposed(by: disposeBag)
        
        rx.editingDidEnd
            .subscribe(with: self) { owner, _ in
                UIView.animate(withDuration: 0.3) {
                    owner.layer.borderWidth = 0
                }
            }
            .disposed(by: disposeBag)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
