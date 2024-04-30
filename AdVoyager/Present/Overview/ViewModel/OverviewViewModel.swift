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
    private var dataSource: [Post] = []
    private var nextCursor = ""
    private var productId = ""
    private var limit = 10
    private lazy var tempPostQuery = PostQuery(next: nextCursor, limit: "\(limit)", product_id: productId)
    
    struct Input {
        let viewDidLoadTrigger: Observable<Void>
        let addNewPostButtonTap: Observable<Void>
        let renderingRowPosition: Observable<Int>
    }
    
    struct Output {
        let dataSource: Driver<[Post]>
        let addNewPostTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let dataSource = BehaviorRelay<[Post]>(value: [])
        let addNewPostTrigger = PublishRelay<Void>()
        
        input.viewDidLoadTrigger
            .flatMap { [weak self] _ -> Single<PostModel> in
                guard let self else { return .never() }
                return NetworkManager.fetchPost(query: self.tempPostQuery)
            }
            .subscribe(with: self) { owner, postModel in
                owner.dataSource = postModel.data
                owner.nextCursor = postModel.next_cursor
                dataSource.accept(owner.dataSource)
            }
            .disposed(by: disposeBag)
        
        input.addNewPostButtonTap
            .subscribe(with: self) { owner, _ in
                addNewPostTrigger.accept(())
            }
            .disposed(by: disposeBag)
        
        input.renderingRowPosition
            .subscribe(with: self) { owner, rowPosition in
                if rowPosition > (owner.dataSource.count - 4) {
                    NetworkManager.fetchPost(query: PostQuery(next: owner.nextCursor, limit: "\(owner.limit)" , product_id: "")).asObservable()
                        .subscribe(with: self) { owner, postModel in
                            print("데이터가 새로 로드되었습니다.")
                            owner.dataSource.append(contentsOf: postModel.data)
                            owner.nextCursor = postModel.next_cursor
                            dataSource.accept(owner.dataSource)
                        }
                        .disposed(by: owner.disposeBag)
                }
            }
            .disposed(by: disposeBag)
        

        return Output(dataSource: dataSource.asDriver(),
                      addNewPostTrigger: addNewPostTrigger.asDriver(onErrorJustReturn: ()))
    }
    
}
