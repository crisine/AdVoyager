//
//  AddPostViewModel.swift
//  AdVoyager
//
//  Created by Minho on 4/22/24.
//

import RxSwift
import RxCocoa

final class AddPostViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let titleText: Observable<String>
        let contentText: Observable<String>
        let addPostButtonTapTrigger: Observable<Void>
        let cancelPostButtonTapTrigger: Observable<Void>
    }
    
    struct Output {
        let postUploadSuccessTrigger: Driver<Void>
        let postValidation: Driver<Bool>
        let canelPostUploadTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let postValid = BehaviorRelay(value: false)
        let postUploadSuccessTrigger = PublishRelay<Void>()
        let cancelPostUploadTrigger = PublishRelay<Void>()
        
        let postObservable = Observable.combineLatest(
            input.titleText,
            input.contentText
        ).map { title, content in
            return UploadPostQuery(title: title, content: content, files: [])
        }
        
        postObservable
            .bind(with: self) { owner, post in
                if post.title?.isEmpty == false &&
                    post.content?.isEmpty == false {
                    postValid.accept(true)
                } else {
                    postValid.accept(false)
                }
            }
            .disposed(by: disposeBag)
        
        input.addPostButtonTapTrigger
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .withLatestFrom(postObservable)
            .flatMap { postQuery in
                return NetworkManager.createPost(query: postQuery)
            }
            .subscribe(with: self) { owner, postQuery in
                postUploadSuccessTrigger.accept(())
            } onError: { addPostViewModel, error in
                print("에러 내용: \(error.localizedDescription)")
            }
            .disposed(by: disposeBag)
        
        input.cancelPostButtonTapTrigger
            .subscribe(with: self) { owner, _ in
                cancelPostUploadTrigger.accept(())
            }
            .disposed(by: disposeBag)
        
        return Output(postUploadSuccessTrigger: postUploadSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      postValidation: postValid.asDriver(),
                      canelPostUploadTrigger: cancelPostUploadTrigger.asDriver(onErrorJustReturn: ()))
    }
}
