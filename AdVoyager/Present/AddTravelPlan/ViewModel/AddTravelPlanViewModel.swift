//
//  AddTravelPlanViewModel.swift
//  AdVoyager
//
//  Created by Minho on 4/28/24.
//

import Foundation
import RxSwift
import RxCocoa

final class AddTravelPlanViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let firstDate: Observable<Date?>
        let lastDate: Observable<Date?>
    }
    
    struct Output {
        let firstDateString: Driver<String>
        let lastDateString: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        
        let firstDateString = PublishSubject<String>()
        let lastDateString = PublishSubject<String>()
        
        Observable
            .combineLatest(input.firstDate, input.lastDate)
            .subscribe(with: self) { owner, dates in
                firstDateString.onNext(dates.0?.toString(format: "yy.MM.dd") ?? "")
                
                lastDateString.onNext(dates.1?.toString(format: "yy.MM.dd") ?? "")
            }
            .disposed(by: disposeBag)
        
        return Output(firstDateString: firstDateString.asDriver(onErrorJustReturn: ""),
                      lastDateString: lastDateString.asDriver(onErrorJustReturn: ""))
    }
}
