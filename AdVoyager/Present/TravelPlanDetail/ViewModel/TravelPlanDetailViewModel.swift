//
//  TravelPlanDetailViewModel.swift
//  AdVoyager
//
//  Created by Minho on 4/27/24.
//

import RxSwift
import RxCocoa

final class TravelPlanDetailViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let addTravelScheduleButtonTap: Observable<Void>
        let newTravelPlan: Observable<TravelScheduleModel>
    }
    
    struct Output {
        let addTravelScheduleTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let addTravelScheduleTrigger = PublishRelay<Void>()
        
        input.addTravelScheduleButtonTap
            .bind(onNext: addTravelScheduleTrigger.accept(_:))
            .disposed(by: disposeBag)
        
        input.newTravelPlan
            .subscribe(with: self) { owner, newTravelPlan in
//                owner.dataSource.append(newTravelPlan)
//                dataSource.accept(owner.dataSource)
            }
            .disposed(by: disposeBag)
        
        return Output(addTravelScheduleTrigger: addTravelScheduleTrigger.asDriver(onErrorJustReturn: ()))
    }
}
