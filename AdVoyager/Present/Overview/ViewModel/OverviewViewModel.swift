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
    private var normalDataSource: [Post] = []
    private var hashtagDataSource: [Post] = []
    private var productId = "advoyager"
    private var limit = 10
    
    private var planNextCursor = ""
    private var hashtagPlanNextCursor = ""
    
    private var hashtag = "대한민국"
    private lazy var tempPostQuery = PostQuery(next: planNextCursor, limit: "\(limit)", product_id: productId)
    private lazy var tempHashtagPostQuery = HashtagPostQuery(next: planNextCursor, limit: "\(limit)", product_id: productId, hashTag: hashtag)
    
    struct Input {
        let viewDidLoadTrigger: Observable<Void>
        let addNewPostButtonTap: Observable<Void>
        let renderingRowPosition: Observable<Int>
        let refreshLoading: Observable<Void>
        let refreshTrigger: Observable<Void>
    }
    
    struct Output {
        let normalDataSource: Driver<[Post]>
        let hashtagDataSource: Driver<[Post]>
        let addNewPostTrigger: Driver<Void>
        let isRefreshing: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        let normalDataSource = BehaviorRelay<[Post]>(value: [])
        let hashtagDataSource = BehaviorRelay<[Post]>(value: [])
        let addNewPostTrigger = PublishRelay<Void>()
        let isRefreshing = PublishRelay<Bool>()
        
        // MARK: Normal
        input.viewDidLoadTrigger
            .flatMap { [weak self] _ -> Single<PostModel> in
                guard let self else { return .never() }
                return NetworkManager.fetchPost(query: self.tempPostQuery)
            }
            .subscribe(with: self) { owner, postModel in
                owner.normalDataSource = postModel.data
                owner.planNextCursor = postModel.next_cursor
                normalDataSource.accept(owner.normalDataSource)
            }
            .disposed(by: disposeBag)
        
        // MARK: Hashtag
        input.viewDidLoadTrigger
            .flatMap { [weak self] _ -> Single<PostModel> in
                guard let self else { return .never() }
                return NetworkManager.fetchHashtagPost(query: self.tempHashtagPostQuery)
            }
            .subscribe(with: self) { owner, postModel in
                owner.hashtagDataSource = postModel.data
                owner.hashtagPlanNextCursor = postModel.next_cursor
                hashtagDataSource.accept(owner.hashtagDataSource)
            }
            .disposed(by: disposeBag)
        
        input.addNewPostButtonTap
            .subscribe(with: self) { owner, _ in
                addNewPostTrigger.accept(())
            }
            .disposed(by: disposeBag)
        
        input.renderingRowPosition
            .subscribe(with: self) { owner, rowPosition in
                
                if rowPosition > (owner.normalDataSource.count - 4) && owner.planNextCursor != "0" {
                    NetworkManager.fetchPost(query: PostQuery(next: owner.planNextCursor, limit: "\(owner.limit)" , product_id: owner.productId)).asObservable()
                        .subscribe(with: self) { owner, postModel in
                            print("데이터가 새로 로드되었습니다.")
                            owner.normalDataSource.append(contentsOf: postModel.data)
                            owner.planNextCursor = postModel.next_cursor
                            normalDataSource.accept(owner.normalDataSource)
                        }
                        .disposed(by: owner.disposeBag)
                }
            }
            .disposed(by: disposeBag)
        
        input.refreshLoading
            .subscribe(with: self) { owner, _ in
                isRefreshing.accept(true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    owner.reloadData(dataSource: normalDataSource)
                    isRefreshing.accept(false)
                }
            }
            .disposed(by: disposeBag)
        
        input.refreshTrigger
            .subscribe(with: self) { owner, _ in
                owner.reloadData(dataSource: normalDataSource)
            }
            .disposed(by: disposeBag)
        

        return Output(normalDataSource: normalDataSource.asDriver(),
                      hashtagDataSource: hashtagDataSource.asDriver(),
                      addNewPostTrigger: addNewPostTrigger.asDriver(onErrorJustReturn: ()),
                      isRefreshing: isRefreshing.asDriver(onErrorJustReturn: false))
    }
    
    private func reloadData(dataSource: BehaviorRelay<[Post]>) {
        print("데이터 신규 로드")
        NetworkManager.fetchPost(query: PostQuery(next: "", limit: "\(limit)", product_id: productId)).asObservable()
            .subscribe(with: self) { owner, postModel in
                owner.normalDataSource = postModel.data
                owner.planNextCursor = postModel.next_cursor
                dataSource.accept(owner.normalDataSource)
            }
            .disposed(by: disposeBag)
    }
}
