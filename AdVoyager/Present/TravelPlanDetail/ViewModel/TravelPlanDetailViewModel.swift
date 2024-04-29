//
//  TravelPlanDetailViewModel.swift
//  AdVoyager
//
//  Created by Minho on 4/27/24.
//

import UIKit
import RxSwift
import RxCocoa

final class TravelPlanDetailViewModel: ViewModelType {
    
    var viewControllers: Array<TravelScheduleViewController> = []
    var selectedTravelPlan: TravelPlanModel?
    var disposeBag = DisposeBag()
    
    struct Input {
        let reloadDataTrigger: Observable<Void>
        let addTravelScheduleButtonTap: Observable<Void>
    }
    
    struct Output {
        let addTravelScheduleTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let addTravelScheduleTrigger = PublishRelay<Void>()
        
        input.reloadDataTrigger
            .subscribe(with: self) { owner, _ in
                // MARK: 모든 VC에 대해 갱신이 일어나게 됨
                owner.viewControllers.forEach { vc in
                    vc.reloadDataTrigger.onNext(())
                }
            }
            .disposed(by: disposeBag)
        
        input.addTravelScheduleButtonTap
            .bind(onNext: addTravelScheduleTrigger.accept(_:))
            .disposed(by: disposeBag)
        
        return Output(addTravelScheduleTrigger: addTravelScheduleTrigger.asDriver(onErrorJustReturn: ()))
    }
    
    func setViewControllers() {
        if let selectedTravelPlan {
            let calendar = Calendar.current
            let dayDifference = calendar.dateComponents([.day], from: selectedTravelPlan.firstDate, to: selectedTravelPlan.lastDate).day
            
            guard let dayDifference else { return }
            
            for order in 0...dayDifference {
                let vc = TravelScheduleViewController()
                
                let calendar = Calendar.current
                let date = calendar.date(byAdding: .day, value: order + 1, to: selectedTravelPlan.firstDate)
                
                vc.viewModel.order = order
                vc.viewModel.planId = selectedTravelPlan.id
                vc.viewModel.date = date
                
                viewControllers.append(vc)
            }
        }
    }
}
