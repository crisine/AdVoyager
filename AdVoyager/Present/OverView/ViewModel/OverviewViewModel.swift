//
//  OverviewViewModel.swift
//  AdVoyager
//
//  Created by Minho on 4/20/24.
//

import Foundation
import RxSwift
import RxCocoa

final class OverviewViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    var dummyDataArray = ["1", "2", "3"]
    
    struct Input {
        let addDummyDataButtonTap: Observable<Void>
    }
    
    struct Output {
        let dataSource: Driver<[String]>
    }
    
    func transform(input: Input) -> Output {
        print(#function)
        
        let dataSource = PublishSubject<[String]>()
        
        input.addDummyDataButtonTap
            .subscribe(with: self) { owner, _ in
                print("added new data")
                owner.dummyDataArray.append(String(Int.random(in: 1...100)))
                dataSource.onNext(owner.dummyDataArray)
            }
            .disposed(by: disposeBag)

        return Output(dataSource: dataSource.asDriver(onErrorJustReturn: []))
    }
    
}
