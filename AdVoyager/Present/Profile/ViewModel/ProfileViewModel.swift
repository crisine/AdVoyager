//
//  ProfileViewModel.swift
//  AdVoyager
//
//  Created by Minho on 4/17/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let editProfileButtonTapped: Observable<Void>
        let logoutButtonTap: Observable<Void>
    }
    
    struct Output {
        let profileInfo: Driver<ProfileModel?>
        let editProfileTrigger: Driver<Void>
        let logoutSuccess: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let profileModel = NetworkManager.fetchProfile()
        let profileInfo = PublishRelay<ProfileModel?>()
        let editProfileTrigger = PublishRelay<Void>()
        let logoutSuccess = PublishSubject<Void>()
        
        input.editProfileButtonTapped
            .subscribe(with: self) { owner, _ in
                editProfileTrigger.accept(())
            }
            .disposed(by: disposeBag)
        
        input.logoutButtonTap
            .subscribe(with: self) { owner, _ in
                UserDefaults.standard.removeObject(forKey: "accessToken")
                UserDefaults.standard.removeObject(forKey: "refreshToken")
                logoutSuccess.onNext(())
            }
            .disposed(by: disposeBag)
        
        profileModel.asObservable()
            .subscribe(with: self) { owner, profile in
                profileInfo.accept(profile)
            }
            .disposed(by: disposeBag)
        
        return Output(profileInfo: profileInfo.asDriver(onErrorJustReturn: nil),
                      editProfileTrigger: editProfileTrigger.asDriver(onErrorJustReturn: ()),
                      logoutSuccess: logoutSuccess.asDriver(onErrorJustReturn: ()))
    }
}
