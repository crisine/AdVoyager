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
    var dataSource: [String] = []
    
    struct Input {
        let viewWillAppearTrigger: Observable<Post>
    }
    
    struct Output {
        let dataSource: Driver<[String]>
    }
    
    func transform(input: Input) -> Output {
        
        let dataSource = PublishSubject<[String]>()
        
        input.viewWillAppearTrigger
            .subscribe(with: self) { owner, selectedPost in
                // TODO: 여기서 네트워크 통신으로 포스트 데이터 가져오기
                
                // 지금 뭐해야하냐하면, post 내의 이미지 배열 따서 dataSource에 넣어줘야함.
                // 그리고 dataSource를 뷰로 보내서 그거 기반으로 컬렉션뷰 그려야함 ㅇㅋ?
                owner.dataSource = selectedPost.files
                dataSource.onNext(owner.dataSource)
            }
            .disposed(by: disposeBag)
        
        return Output(dataSource: dataSource.asDriver(onErrorJustReturn: []))
    }
}
