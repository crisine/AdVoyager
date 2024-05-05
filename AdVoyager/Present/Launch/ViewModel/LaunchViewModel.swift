//
//  LaunchViewModel.swift
//  AdVoyager
//
//  Created by Minho on 4/23/24.
//

import Foundation
import RxSwift
import RxCocoa

final class LaunchViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let viewDidLoadTrigger: Observable<Void>
    }
    
    struct Output {
        let loginSuccessTrigger: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        let loginSuccessTrigger = PublishSubject<Bool>()
        
        input.viewDidLoadTrigger
            .flatMap { _ in
                return NetworkManager.refreshToken()
            }
            .subscribe(with: self) { owner, accessToken in
                UserDefaults.standard.setValue(accessToken, forKey: "accessToken")
                loginSuccessTrigger.onNext(true)
            } onError: { owner, error in
                UserDefaults.standard.removeObject(forKey: "accessToken")
                UserDefaults.standard.removeObject(forKey: "refreshToken")
                print(error.localizedDescription)
                loginSuccessTrigger.onNext(false)
            }
            .disposed(by: disposeBag)
        
        return Output(loginSuccessTrigger: loginSuccessTrigger.asDriver(onErrorJustReturn: false))
    }
}
