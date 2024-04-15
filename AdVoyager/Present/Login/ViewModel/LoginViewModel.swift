//
//  LoginViewModel.swift
//  AdVoyager
//
//  Created by Minho on 4/12/24.
//

import Foundation
import RxSwift
import RxCocoa

final class LoginViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let emailText: Observable<String>
        let passwordText: Observable<String>
        let loginButtonTapped: Observable<Void>
        let signUpButtonTapped: Observable<Void>
    }
    
    struct Output {
        let loginValidation: Driver<Bool>
        let loginSuccessTrigger: Driver<Void>
        let signUpTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let loginValid = BehaviorRelay(value: false)
        let loginSuccessTrigger = PublishRelay<Void>()
        let signUpTrigger = PublishRelay<Void>()
        
        let loginObservable = Observable.combineLatest(
            input.emailText,
            input.passwordText
        )
            .map { email, password in
                return LoginQuery(email: email, password: password)
            }
        
        loginObservable
            .bind(with: self) { owner, login in
                if login.email.contains("@") && login.password.count > 3 {
                    loginValid.accept(true)
                } else {
                    loginValid.accept(false)
                }
            }
            .disposed(by: disposeBag)
        
        
        input.loginButtonTapped
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(loginObservable)
            .flatMap { loginQuery in
                return NetworkManager.createLogin(query: loginQuery)
            }
            .subscribe(with: self) { owner, loginModel in
                UserDefaults.standard.set(loginModel.accessToken, forKey: "accessToken")
                UserDefaults.standard.set(loginModel.refreshToken, forKey: "refreshToken")
                loginSuccessTrigger.accept(())
            } onError: { owner, error in
                print("로그인 오류 발생: \(error.localizedDescription)")
            }
            .disposed(by: disposeBag)
        
        input.signUpButtonTapped
            .bind(with: self) { owner, _ in
                print("signUp Button Tapped")
                signUpTrigger.accept(())
            }
            .disposed(by: disposeBag)
        
        return Output(
            loginValidation: loginValid.asDriver(),
            loginSuccessTrigger: loginSuccessTrigger.asDriver(onErrorJustReturn: ()),
            signUpTrigger: signUpTrigger.asDriver(onErrorJustReturn: ()))
    }
}
