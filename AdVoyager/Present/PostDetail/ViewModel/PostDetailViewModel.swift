//
//  PostDetailViewModel.swift
//  AdVoyager
//
//  Created by Minho on 5/1/24.
//

import RxSwift
import RxCocoa

final class PostDetailViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    private var post: Post?
    private var dataSource: [String] = []
    
    struct Input {
        let viewWillAppearTrigger: Observable<Post>
        let modifyPostTrigger: Observable<Void>
        let deletePostTrigger: Observable<Void>
    }
    
    struct Output {
        let dataSource: Driver<[String]>
        let deletePostSuccess: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let dataSource = PublishSubject<[String]>()
        let deletePostSuccess = PublishSubject<Void>()
        
        input.viewWillAppearTrigger
            .subscribe(with: self) { owner, selectedPost in
                // TODO: 여기서 네트워크 통신으로 포스트 데이터 가져오기
                owner.post = selectedPost
                owner.dataSource = selectedPost.files
                dataSource.onNext(owner.dataSource)
            }
            .disposed(by: disposeBag)
        
        input.modifyPostTrigger
            .subscribe(with: self) { owner, _ in
                print("글 수정하기")
            }
            .disposed(by: disposeBag)
        
        input.deletePostTrigger
            .flatMap {
                return NetworkManager.deletePost(postId: self.post!.post_id)
            }
            .subscribe(with: self) { owner, _ in
                deletePostSuccess.onNext(())
            }
            .disposed(by: disposeBag)
        
        return Output(dataSource: dataSource.asDriver(onErrorJustReturn: []),
                      deletePostSuccess: deletePostSuccess.asDriver(onErrorJustReturn: ()))
    }
}
