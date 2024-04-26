//
//  Reactive+Extension.swift
//  AdVoyager
//
//  Created by Minho on 4/27/24.
//

import UIKit

import RxCocoa
import RxSwift

// MARK: UITextField 확장
extension Reactive where Base: UITextField {
    var editingDidBegin: Observable<Void> {
        return controlEvent(.editingDidBegin)
            .map { _ in () }
    }
    
    var editingDidEnd: Observable<Void> {
        return controlEvent(.editingDidEnd)
            .map { _ in () }
    }
}
