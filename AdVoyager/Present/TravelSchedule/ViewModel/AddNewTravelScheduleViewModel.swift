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
    
    struct Input {
        let closeButtonTap: Observable<Void>
        let addScheduleButtonTap: Observable<Void>
        let scheduleDate: Observable<Date>
        let scheduleTitle: Observable<String>
        let scheduleDescription: Observable<String>
    }
    
    struct Output {
        let closeTrigger: Driver<Void>
        let successTrigger: Driver<TravelScheduleModel?>
    }
    
    func transform(input: Input) -> Output {
        
        let closeTrigger = PublishRelay<Void>()
        let successTrigger = PublishSubject<TravelScheduleModel?>()
        
        input.closeButtonTap
            .bind(onNext: closeTrigger.accept(_:))
            .disposed(by: disposeBag)
        
        let travelPlanObservable = Observable.combineLatest(
            input.scheduleDate,
            input.scheduleTitle,
            input.scheduleDescription
        ).map { date, title, description in
            // TODO: Order 부분을 어떻게 해야될거같은데, 고민해볼 것 (예를 들면 이 뷰 진입 시 마지막 일정의 order를 갖고 들어온다던지 (그러면 생기는 문제는 새로 추가하는 일정이 가장 마지막 일정이 아닐 경우에 문제가 됨)
            return TravelScheduleModel(post_id: "", id: UUID(), order: 999, date: date, placeTitle: title, description: description, latitude: nil, longitude: nil)
        }
        
        input.addScheduleButtonTap
            .withLatestFrom(travelPlanObservable)
            .subscribe(with: self) { owner, travelPlan in
                successTrigger.onNext(travelPlan)
            }
            .disposed(by: disposeBag)
        
        return Output(closeTrigger: closeTrigger.asDriver(onErrorJustReturn: ()),
                      successTrigger: successTrigger.asDriver(onErrorJustReturn: nil))
    }
}
