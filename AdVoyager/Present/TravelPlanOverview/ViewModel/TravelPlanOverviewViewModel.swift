//
//  TravelPlanOverviewViewModel.swift
//  AdVoyager
//
//  Created by Minho on 4/27/24.
//

import RxSwift
import RxCocoa

final class TravelPlanOverviewViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let addTravelPlanButtonTap: Observable<Void>
        let newTravelPlan: Observable<TravelScheduleModel>
    }
    
    struct Output {
        let addTravelPlanTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let addTravelPlanTrigger = PublishRelay<Void>()
        
        input.addTravelPlanButtonTap
            .bind(onNext: addTravelPlanTrigger.accept(_:))
            .disposed(by: disposeBag)
        
        input.newTravelPlan
            .subscribe(with: self) { owner, newTravelPlan in
//                owner.dataSource.append(newTravelPlan)
//                dataSource.accept(owner.dataSource)
            }
            .disposed(by: disposeBag)
        
        return Output(addTravelPlanTrigger: addTravelPlanTrigger.asDriver(onErrorJustReturn: ()))
    }
}
