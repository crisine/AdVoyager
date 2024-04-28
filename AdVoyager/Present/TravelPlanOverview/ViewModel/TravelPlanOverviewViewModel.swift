//
//  TravelPlanOverviewViewModel.swift
//  AdVoyager
//
//  Created by Minho on 4/28/24.
//

import RxSwift
import RxCocoa

final class TravelPlanOverviewViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let addTravelPlanButtonTap: Observable<Void>
    }
    
    struct Output {
        let moveToAddTravelPlanViewTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let moveToAddTravelPlanViewTrigger = PublishRelay<Void>()
        
        input.addTravelPlanButtonTap
            .subscribe(with: self) { owner, _ in
                moveToAddTravelPlanViewTrigger.accept(())
            }
            .disposed(by: disposeBag)
        
        return Output(moveToAddTravelPlanViewTrigger: moveToAddTravelPlanViewTrigger.asDriver(onErrorJustReturn: ()))
    }
}
