//
//  ViewModelType.swift
//  AdVoyager
//
//  Created by Minho on 4/12/24.
//

import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get set }
    func transform(input: Input) -> Output
}
