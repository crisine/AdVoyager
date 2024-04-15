//
//  SignUpViewModel.swift
//  AdVoyager
//
//  Created by Minho on 4/16/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SignUpViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let emailText: Observable<String>
        let passwordText: Observable<String>
        let nicknameText: Observable<String>
        let phoneNumberText: Observable<String>
        let birthdayDate: Observable<Date>
        let signUpButtonTapped: Observable<Void>
    }
    
    struct Output {
        let signUpValidation: Driver<Bool>
        let signUpSuccessTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let emailRegex = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        let signUpValid = BehaviorRelay(value: false)
        
        let signUpObservable = Observable.combineLatest(
            input.emailText,
            input.passwordText,
            input.nicknameText,
            input.phoneNumberText,
            input.birthdayDate
        ).map { email, password, nickname, phoneNumber, birthday in
            return SignUpQuery(email: email, password: password, nick: nickname, phoneNum: phoneNumber, birthDay: birthday.toString(format: "yyyyMMdd"))
        }
        let signUpSuccessTrigger = PublishRelay<Void>()
        
        signUpObservable
            .bind(with: self) { owner, signUp in
                // TODO: 추후 조건별 분리로 디테일 업, 로그인 validation 결과 텍스트를 통합하지 말고 각각의 요소에 맞게 분리.
                if emailTest.evaluate(with: signUp.email) &&
                    signUp.password.count >= 8 &&
                    signUp.nick.count >= 2
                     {
                    signUpValid.accept(true)
                } else {
                    signUpValid.accept(false)
                }
            }
            .disposed(by: disposeBag)
        
        input.signUpButtonTapped
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(signUpObservable)
            .flatMap { signUpQuery in
                return NetworkManager.createSignUp(query: signUpQuery)
            }
            .subscribe(with: self) { owner, signUpModel in
                UserDefaults.standard.setValue(signUpModel.user_id, forKey: "user_id")
                signUpSuccessTrigger.accept(())
            } onError: { owner, error in
                // TODO: response코드를 여기로 보낸 후에, API 문서 기준으로 어떤 코드가 반환되었는지 분기 처리 후, 여러 개의 Trigger를 만들어서 VC로 보낸 후 VC에서 Alert 등으로 보이도록 처리할 것.
                print(error)
            }
            .disposed(by: disposeBag)
        
        return Output(signUpValidation: signUpValid.asDriver(), signUpSuccessTrigger: signUpSuccessTrigger.asDriver(onErrorJustReturn: ()))
    }
}
