//
//  TravelScheduleViewModel.swift
//  AdVoyager
//
//  Created by Minho on 4/24/24.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

final class TravelScheduleViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    var planId: ObjectId?
    var order: Int?
    var date: Date?
    
    private let repository = Repository()
    private var dataSource: [TravelSchedule] = []
    
    struct Input {
        let reloadDataTrigger: Observable<Void>
        let travelSchedule: Observable<TravelSchedule>
        let tableViewIndexPath: Observable<IndexPath>
    }
    
    struct Output {
        let dataSource: Driver<[TravelSchedule]>
        let indexPath: Driver<IndexPath?>
    }
    
    func transform(input: Input) -> Output {
        
        let selectedTableViewItem = BehaviorSubject<TravelSchedule?>(value: nil)
        let selectedIndexPath = PublishRelay<IndexPath?>()
        let dataSource = BehaviorRelay<[TravelSchedule]>(value: [])
        
        input.reloadDataTrigger
            .subscribe(with: self) { owner, _ in
                guard let planId = owner.planId else { return }
                guard let date = owner.date else { return }
                
                let scheduleArray = Array(owner.repository.fetchSchedule(planId: planId).filter { date.isSameWith($0.date) == true }).sorted { $0.date < $1.date }
                
                dataSource.accept(scheduleArray)
            }
            .disposed(by: disposeBag)
        
        input.travelSchedule
            .subscribe(with: self) { owner, item in
                selectedTableViewItem.onNext(item)
            }
            .disposed(by: disposeBag)
        
        input.tableViewIndexPath
            .subscribe(with: self) { owner, indexPath in
                selectedIndexPath.accept(indexPath)
            }
            .disposed(by: disposeBag)
        
        return Output(dataSource: dataSource.asDriver(),
                      indexPath: selectedIndexPath.asDriver(onErrorJustReturn: nil))
    }
}
