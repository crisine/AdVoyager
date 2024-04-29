//
//  TravelPlanOverviewViewModel.swift
//  AdVoyager
//
//  Created by Minho on 4/28/24.
//

import Foundation
import RxSwift
import RxCocoa

final class TravelPlanOverviewViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    private let repository = Repository()
    
    struct Input {
        let travelPlan: Observable<TravelPlanModel>
        let tableViewIndexPath: Observable<IndexPath>
        let addTravelPlanButtonTap: Observable<Void>
        let dataReloadTrigger: Observable<Void>
    }
    
    struct Output {
        let dataSource: Driver<[TravelPlanModel]>
        let moveToAddTravelPlanViewTrigger: Driver<Void>
        let travelPlan: Driver<TravelPlanModel?>
        let indexPath: Driver<IndexPath?>
    }
    
    func transform(input: Input) -> Output {
        
        let selectedIndexPath = PublishRelay<IndexPath?>()
        
        let plans = Array(repository.fetchTravelPlan())
        let dataSource = BehaviorRelay(value: plans)
        let moveToAddTravelPlanViewTrigger = PublishRelay<Void>()
        let selectedTravelPlan = PublishRelay<TravelPlanModel?>()
        
        input.addTravelPlanButtonTap
            .subscribe(with: self) { owner, _ in
                moveToAddTravelPlanViewTrigger.accept(())
            }
            .disposed(by: disposeBag)
        
        input.tableViewIndexPath
            .subscribe { indexPath in
                selectedIndexPath.accept(indexPath)
            }
            .disposed(by: disposeBag)
        
        input.travelPlan
            .subscribe(with: self) { owner, travelPlan in
                selectedTravelPlan.accept(travelPlan)
            }
            .disposed(by: disposeBag)
        
        input.dataReloadTrigger
            .subscribe(with: self) { owner, _ in
                dataSource.accept( Array(owner.repository.fetchTravelPlan()))
            }
            .disposed(by: disposeBag)
        
        return Output(dataSource: dataSource.asDriver(),
                      moveToAddTravelPlanViewTrigger: moveToAddTravelPlanViewTrigger.asDriver(onErrorJustReturn: ()),
                      travelPlan: selectedTravelPlan.asDriver(onErrorJustReturn: nil),
                      indexPath: selectedIndexPath.asDriver(onErrorJustReturn: nil))
    }
}
