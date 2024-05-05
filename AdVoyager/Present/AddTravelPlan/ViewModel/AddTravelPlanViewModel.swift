//
//  AddTravelPlanViewModel.swift
//  AdVoyager
//
//  Created by Minho on 4/28/24.
//

import Foundation
import RxSwift
import RxCocoa

enum AddTravelPlanError: CustomStringConvertible, Error {
    
    case notitle
    case nodates
    case none
    
    var description: String {
        switch self {
        case .notitle:
            return "제목을 입력해주세요."
        case .nodates:
            return "날짜를 선택해주세요."
        case .none:
            return "에러 없음"
        }
    }
}

final class AddTravelPlanViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    private let repository = Repository()
    
    struct Input {
        let closeButtonTap: Observable<Void>
        let planTitle: Observable<String>
        let firstDate: Observable<Date?>
        let lastDate: Observable<Date?>
        let addTravelPlanButtonTap: Observable<Void>
    }
    
    struct Output {
        let closeTrigger: Driver<Void>
        let firstDateString: Driver<String>
        let lastDateString: Driver<String>
        let saveSuccessTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let closeTrigger = PublishRelay<Void>()
        let firstDateString = PublishSubject<String>()
        let lastDateString = PublishSubject<String>()
        let saveSuccessTrigger = PublishSubject<Void>()
        let error = PublishSubject<AddTravelPlanError>()
        
        input.closeButtonTap
            .bind(onNext: closeTrigger.accept(_:))
            .disposed(by: disposeBag)
        
        input.firstDate
            .bind { firstDate in
                firstDateString.onNext(firstDate?.toString(format: "yy.MM.dd") ?? "")
            }
            .disposed(by: disposeBag)
        
        input.lastDate
            .bind { lastDate in
                lastDateString.onNext(lastDate?.toString(format: "yy.MM.dd") ?? "")
            }
            .disposed(by: disposeBag)
        
        let travelPlanObservable = Observable
                                    .combineLatest(
                                        input.planTitle,
                                        input.firstDate,
                                        input.lastDate
                                    )
                                    .map { planTitle, firstDate, lastDate in
                                        if let firstDate, let lastDate {
                                            return TravelPlan(planTitle: planTitle, firstDate: firstDate, lastDate: lastDate)
                                        } else {
                                            return nil
                                        }
                                    }
                                    .compactMap { $0 }

        input.addTravelPlanButtonTap
            .withLatestFrom(travelPlanObservable)
            .subscribe(with: self) { owner, travelPlan in
                owner.repository.addTravelPlan(travelPlan)
                saveSuccessTrigger.onNext(())
            }
            .disposed(by: disposeBag)
        
        return Output(closeTrigger: closeTrigger.asDriver(onErrorJustReturn: ()),
                      firstDateString: firstDateString.asDriver(onErrorJustReturn: ""),
                      lastDateString: lastDateString.asDriver(onErrorJustReturn: ""),
                      saveSuccessTrigger: saveSuccessTrigger.asDriver(onErrorJustReturn: ()))
    }
}
