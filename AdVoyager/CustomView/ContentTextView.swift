//
//  ContentTextView.swift
//  AdVoyager
//
//  Created by Minho on 4/22/24.
//

import UIKit
import RxSwift

final class ContentTextView: UITextView {
    
    let disposeBag = DisposeBag()
    
    private var isEdited = false

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
        textContainer.lineFragmentPadding = 0
        textContainerInset = .init(top: 8, left: 8, bottom: 8, right: 8)
        
        backgroundColor = .systemGray6
        
        rx.didBeginEditing
            .subscribe(with: self) { owner, _ in
                UIView.animate(withDuration: 0.3) {
                    owner.layer.borderWidth = 1.5
                    owner.layer.borderColor = UIColor.systemBlue.cgColor
                }
                
                if owner.isEdited == false {
                    owner.isEdited.toggle()
                    owner.text = ""
                    owner.textColor = .black
                }
            }
            .disposed(by: disposeBag)
        
        rx.didEndEditing
            .subscribe(with: self) { owner, _ in
                UIView.animate(withDuration: 0.3) {
                    owner.layer.borderWidth = 0
                }
                
                if owner.isEdited == true && owner.text == "" {
                    owner.isEdited.toggle()
                    owner.text = placeholderText
                    owner.textColor = .lightGray
                }
            }
            .disposed(by: disposeBag)
    }
    
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
