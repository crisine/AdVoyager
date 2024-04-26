//
//  SignTextField.swift
//  LSLPBasic
//
//  Created by jack on 2024/04/09.
//

import UIKit
import RxSwift
import RxCocoa

final class SignTextField: UITextField {
    
    let disposeBag = DisposeBag()
    
    init(placeholderText: String, isSecured: Bool = false) {
        super.init(frame: .zero)
        
        textColor = .text
        placeholder = placeholderText
        isSecureTextEntry = isSecured
        textAlignment = .center
        borderStyle = .none
        layer.cornerRadius = 16
        backgroundColor = .systemGray6
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        
        leftView = paddingView
        leftViewMode = .always
        
        rightView = paddingView
        rightViewMode = .always
        
        rx.editingDidBegin
            .subscribe(with: self) { owner, _ in
                UIView.animate(withDuration: 0.3) {
                    owner.layer.borderWidth = 1.5
                    owner.layer.borderColor = UIColor.systemBlue.cgColor
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
