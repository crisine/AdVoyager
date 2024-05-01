//
//  EditProfileViewModel.swift
//  AdVoyager
//
//  Created by Minho on 4/18/24.
//

import UIKit
import RxSwift
import RxCocoa

final class EditProfileViewModel: ViewModelType {

    var disposeBag = DisposeBag()
    
    var profileInfo: ProfileModel!
    
    struct Input {
        let profileImage: Observable<UIImage?>
        let nick: Observable<String>
        let phoneNum: Observable<String>
        let birthDay: Observable<Date>
        let profileImageViewTap: Observable<UITapGestureRecognizer>
        let editProfileButtonTap: Observable<Void>
    }
    
    struct Output {
        let profileInfo: Driver<ProfileModel?>
        let editProfileImageTrigger: Driver<Void>
        let editProfileSuccessTrigger: Driver<Void>
    }
    
    var profileImage: Data = Data()
    
    func transform(input: Input) -> Output {
        
        let profileModel = NetworkManager.fetchProfile()
        let profileInfo = PublishRelay<ProfileModel?>()
        let editProfileImageTrigger = PublishRelay<Void>()
        let editProfileSuccessTrigger = PublishRelay<Void>()
        
        // 프로필 이미지 선택 후 잠시 VM에서 보유
        input.profileImage.subscribe(with: self) { owner, image in
            owner.profileImage = image?.jpegData(compressionQuality: 0.5) ?? Data()
        }
        .disposed(by: disposeBag)
        
        let editProfileObservable = Observable.combineLatest(
            input.nick,
            input.phoneNum,
            input.birthDay
        ).map { nick, phoneNum, birthDay in
            print("프로필 정보 수정된 부분 전송 전 확인: \n이미지: \(self.profileImage.count / (5 * 1024 * 1024))MB\n닉네임: \(nick)\n휴대폰: \(phoneNum)\n생년월일: \(birthDay)")
            return EditProfileQuery(nick: nick,
                                    phoneNum: phoneNum,
                                    birthDay: birthDay.toString(format: "yyyyMMdd"),
                                    profile: self.profileImage)
        }
        
        profileModel.asObservable()
            .subscribe(with: self) { owner, profile in
                print("profileinfo accepted")
                profileInfo.accept(profile)
            }
            .disposed(by: disposeBag)
        
        input.profileImageViewTap
            .subscribe(with: self) { owner, tapGesture in
                editProfileImageTrigger.accept(())
            }
            .disposed(by: disposeBag)
        
        input.editProfileButtonTap
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .withLatestFrom(editProfileObservable)
            .flatMap { editProfileQuery in
                return NetworkManager.editProfile(query: editProfileQuery)
            }
            .subscribe(with: self) { owner, profileModel in
                // MARK: 결과로 넘어온 profileModel 어떻게 사용할것인지
                print("프로필 수정 성공")
                editProfileSuccessTrigger.accept(())
            } onError: { owner, error in
                print("프로필 수정 오류 발생: \(error.localizedDescription)")
            }
            .disposed(by: disposeBag)
        
        return Output(profileInfo:
                        profileInfo.asDriver(onErrorJustReturn: nil),
                      editProfileImageTrigger: editProfileImageTrigger.asDriver(onErrorJustReturn: ()),
                      editProfileSuccessTrigger: editProfileSuccessTrigger.asDriver(onErrorJustReturn: ()))
    }
}
