//
//  CommentViewModel.swift
//  AdVoyager
//
//  Created by Minho on 5/1/24.
//

import RxSwift
import RxCocoa

final class CommentViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    var comments: [Comment] = []
    var postId: String = ""
    
    struct Input {
        let viewWillAppearTrigger: Observable<[Comment]>
        let comment: Observable<String>
        let addCommentButtonTap: Observable<Void>
        let cellModifyButtonTap: Observable<Int>
        let cellDeleteButtonTap: Observable<Int>
    }
    
    struct Output {
        let dataSource: Driver<[Comment]>
        let refreshCommentTrigger: Driver<Void>
        let deleteCommentSuccess: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let dataSource = PublishSubject<[Comment]>()
        let refreshCommentTrigger = PublishSubject<Void>()
        let deleteCommentSuccess = PublishSubject<Void>()
        
        input.viewWillAppearTrigger
            .subscribe(with: self) { owner, comments in
                owner.comments = comments
                dataSource.onNext(comments)
            }
            .disposed(by: disposeBag)
        
        input.addCommentButtonTap
            .withLatestFrom(input.comment)
            .flatMap { comment in
                print("comment 내용: \(comment)")
                let query = UploadCommentQuery(content: comment)
                return NetworkManager.createComment(query: query, postId: self.postId)
            }
            .subscribe(with: self) { owner, comment in
                refreshCommentTrigger.onNext(())
            }
            .disposed(by: disposeBag)
        
        refreshCommentTrigger
            .flatMap {
                return NetworkManager.fetchSpecificPost(postId: self.postId)
            }
            .subscribe(with: self) { owner, post in
                owner.comments = post.comments
                dataSource.onNext(post.comments)
            }
            .disposed(by: disposeBag)
        
        input.cellModifyButtonTap
            .subscribe(with: self) { owner, row in
                print("해당 댓글 수정처리: \(owner.comments[row])")
            }
            .disposed(by: disposeBag)
        
        input.cellDeleteButtonTap
            .flatMap { row in
                return NetworkManager.deleteComment(postId: self.postId, commentId: self.comments[row].comment_id)
            }
            .subscribe(with: self) { owner, _ in
                print("댓글 삭제 성공")
                refreshCommentTrigger.onNext(())
            }
            .disposed(by: disposeBag)
        
        return Output(dataSource: dataSource.asDriver(onErrorJustReturn: []),
                      refreshCommentTrigger: refreshCommentTrigger.asDriver(onErrorJustReturn: ()),
                      deleteCommentSuccess: deleteCommentSuccess.asDriver(onErrorJustReturn: ()))
    }
}
