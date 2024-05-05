//
//  SearchResultViewModel.swift
//  AdVoyager
//
//  Created by Minho on 5/5/24.
//

import RxSwift
import RxCocoa

final class SearchResultViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    var dataSource: [Post] = []
    var query: String = ""
    private var nextCursor = ""
    private var productId = "advoyager"
    
    struct Input {
        let viewDidLoadTrigger: Observable<Void>
        let query: Observable<String>
        let refreshTrigger: Observable<Void>
        let renderingRowPosition: Observable<Int>
    }
    
    struct Output {
        let dataSource: Driver<[Post]>
    }
    
    func transform(input: Input) -> Output {
        
        let dataSource = PublishRelay<[Post]>()
        let searchQuery = input.query
            .map { query in
                return HashtagPostQuery(next: self.nextCursor, limit: "10", product_id: self.productId, hashTag: query)
            }
        
        input.query
            .bind(with: self) { owner, query in
                owner.query = query
            }
            .disposed(by: disposeBag)
        
        input.viewDidLoadTrigger
            .withLatestFrom(searchQuery)
            .flatMap { searchQuery -> Single<PostModel> in
                return NetworkManager.fetchHashtagPost(query: searchQuery)
            }
            .subscribe(with: self) { owner, postModel in
                owner.dataSource = postModel.data
                owner.nextCursor = postModel.next_cursor
                dataSource.accept(owner.dataSource)
            }
            .disposed(by: disposeBag)
        
        input.refreshTrigger
            .withLatestFrom(searchQuery)
            .subscribe(with: self) { owner, searchQuery in
                owner.reloadData(dataSource: dataSource, query: searchQuery.hashTag)
            }
            .disposed(by: disposeBag)
        
        input.renderingRowPosition
            .subscribe(with: self) { owner, rowPosition in
                
                if rowPosition > (owner.dataSource.count - 4) && owner.nextCursor != "0" {
                
                    let hashTagQuery = HashtagPostQuery(next: owner.nextCursor, limit: "10" , product_id: owner.productId, hashTag: owner.query)
                    
                    NetworkManager.fetchHashtagPost(query: hashTagQuery).asObservable()
                        .subscribe(with: self) { owner, postModel in
                            print("데이터 로드성공")
                            owner.dataSource.append(contentsOf: postModel.data)
                            owner.nextCursor = postModel.next_cursor
                            dataSource.accept(owner.dataSource)
                        }
                        .disposed(by: owner.disposeBag)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(dataSource: dataSource.asDriver(onErrorJustReturn: []))
    }
    
    private func reloadData(dataSource: PublishRelay<[Post]>, query: String) {
        let hashTagPostQuery = HashtagPostQuery(next: "", limit: "10", product_id: productId, hashTag: query)
        
        NetworkManager.fetchHashtagPost(query: hashTagPostQuery).asObservable()
            .subscribe(with: self) { owner, postModel in
                owner.dataSource = postModel.data
                owner.nextCursor = postModel.next_cursor
                dataSource.accept(owner.dataSource)
            }
            .disposed(by: disposeBag)
    }
}
