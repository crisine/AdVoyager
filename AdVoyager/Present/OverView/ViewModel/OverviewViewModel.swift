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
    
    struct Input {
        let addNewPostButtonTap: Observable<Void>
    }
    
    struct Output {
        let dataSource: Driver<[Post]>
        let addNewPostTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        print(#function)
        
        let dataSource = BehaviorRelay<[Post]>(value: [])
        
        let tempPostQuery = PostQuery(next: "", limit: "10", product_id: "buyOrNot")
        let postModel = NetworkManager.fetchPost(query: tempPostQuery)
        
        let addNewPostTrigger = PublishRelay<Void>()
        
        postModel.asObservable()
            .subscribe(with: self) { owner, postModel in
                dataSource.accept(postModel.data)
                print("가져온 포스트 개수 : \(postModel.data.count)")
            }
            .disposed(by: disposeBag)
        
        input.addNewPostButtonTap
            .subscribe(with: self) { owner, _ in
                addNewPostTrigger.accept(())
            }
            .disposed(by: disposeBag)

        return Output(dataSource: dataSource.asDriver(),
                      addNewPostTrigger: addNewPostTrigger.asDriver(onErrorJustReturn: ()))
    }
    
}
