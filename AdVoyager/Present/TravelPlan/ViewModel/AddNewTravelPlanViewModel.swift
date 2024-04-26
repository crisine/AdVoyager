//
//  AddNewTravelPlanViewModel.swift
//  AdVoyager
//
//  Created by Minho on 4/27/24.
//

import RxSwift
import RxCocoa

final class AddNewTravelPlanViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let closeButtonTap: Observable<Void>
    }
    
    struct Output {
        let closeTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let closeTrigger = PublishRelay<Void>()
        
        input.closeButtonTap
            .bind(onNext: closeTrigger.accept(_:))
            .disposed(by: disposeBag)
        
        return Output(closeTrigger: closeTrigger.asDriver(onErrorJustReturn: ()))
    }
}
