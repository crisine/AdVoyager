//
//  TravelScheduleViewModel.swift
//  AdVoyager
//
//  Created by Minho on 4/24/24.
//

import RxSwift
import RxCocoa
import Foundation

final class TravelScheduleViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    private var dataSource: [TravelScheduleModel] = []
    
    struct Input {
        let travelPlanItem: Observable<TravelScheduleModel>
        let tableViewIndexPath: Observable<IndexPath>
    }
    
    struct Output {
        let dataSource: Driver<[TravelScheduleModel]>
        let indexPath: Driver<IndexPath?>
    }
    
    func transform(input: Input) -> Output {
        
        let selectedTableViewItem = BehaviorSubject<TravelScheduleModel?>(value: nil)
        let selectedIndexPath = PublishRelay<IndexPath?>()
        
        // TODO: 더미데이터 넣는 부분이 빠졌으므로, Realm에서 실제 데이터를 가져올 수 있어야 함
        
        let dataSource = BehaviorRelay<[TravelScheduleModel]>(value: dataSource)
        
        input.travelPlanItem
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
