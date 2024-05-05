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
    var selectedTravelPlan: TravelPlan?
    
    private let repository = Repository()
    
    struct Input {
        let closeButtonTap: Observable<Void>
        let addScheduleButtonTap: Observable<Void>
        let scheduleDate: Observable<Date>
        let scheduleTime: Observable<Date>
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
            input.scheduleTime,
            input.scheduleTitle,
            input.scheduleDescription
        ).map { date, time, title, description in
            
            let combinedDate = combineDateAndTime(date: date, time: time)
            
            return TravelSchedule(planId: self.selectedTravelPlan!.id, order: 0, date: combinedDate, scheduleTitle: title, scheduleDescription: description)
        }
        
        input.addScheduleButtonTap
            .withLatestFrom(travelScheduleObservable)
            .subscribe(with: self) { owner, travelSchedule in
                owner.repository.addSchedule(travelSchedule)
                successTrigger.accept(())
            }
            .disposed(by: disposeBag)
        
        return Output(closeTrigger: closeTrigger.asDriver(onErrorJustReturn: ()),
                      successTrigger: successTrigger.asDriver(onErrorJustReturn: ()))
    }
}

private func combineDateAndTime(date: Date, time: Date) -> Date {
    
    let calendar = Calendar.current

    let year = calendar.component(.year, from: date)
    let month = calendar.component(.month, from: date)
    let day = calendar.component(.day, from: date)
    
    let hour = calendar.component(.hour, from: time)
    let minute = calendar.component(.minute, from: time)
    let second = calendar.component(.second, from: time)
    
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = month
    dateComponents.day = day
    dateComponents.hour = hour
    dateComponents.minute = minute
    dateComponents.second = second
    
    let combinedDate = calendar.date(from: dateComponents)
    
    return combinedDate!
}
