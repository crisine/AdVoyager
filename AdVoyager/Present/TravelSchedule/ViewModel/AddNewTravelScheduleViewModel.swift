//
//  AddNewTravelScheduleViewModel.swift
//  AdVoyager
//
//  Created by Minho on 4/27/24.
//

import Foundation
import RxSwift
import RxCocoa

final class AddNewTravelScheduleViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    private let repository = Repository()
    
    struct Input {
        let closeButtonTap: Observable<Void>
        let addScheduleButtonTap: Observable<Void>
        let scheduleDate: Observable<Date>
        let scheduleTitle: Observable<String>
        let scheduleDescription: Observable<String>
    }
    
    struct Output {
        let closeTrigger: Driver<Void>
        let successTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let closeTrigger = PublishRelay<Void>()
        let successTrigger = PublishRelay<Void>()
        
        input.closeButtonTap
            .bind(onNext: closeTrigger.accept(_:))
            .disposed(by: disposeBag)
        
        let travelScheduleObservable = Observable.combineLatest(
            input.scheduleDate,
            input.scheduleTitle,
            input.scheduleDescription
        )
        
        // TODO: 여기에 planId를 넣으려면 Plan 을 선택한 후 이 화면에 진입해야 함
        input.addScheduleButtonTap
            .withLatestFrom(travelScheduleObservable)
            .subscribe(with: self) { owner, schedule in
//                let newSchedule = TravelSchedule(planId: <#ObjectId#>, order: 0, date: schedule.0, scheduleTitle: schedule.1, scheduleDescription: schedule.2)
//                owner.repository.addSchedule(newSchedule)
//                
//                successTrigger.accept(())
            }
            .disposed(by: disposeBag)
        
        return Output(closeTrigger: closeTrigger.asDriver(onErrorJustReturn: ()),
                      successTrigger: successTrigger.asDriver(onErrorJustReturn: ()))
    }
}
