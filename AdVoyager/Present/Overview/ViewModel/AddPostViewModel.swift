//
//  AddPostViewModel.swift
//  AdVoyager
//
//  Created by Minho on 4/22/24.
//

import UIKit
import RxSwift
import RxCocoa

final class AddPostViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    var dataSource: [UIImage] = []
    private var travelPlan: TravelPlan?
    private var travelSchedules: [TravelSchedule] = []
    
    private let repository = Repository()
    
    struct Input {
        let titleText: Observable<String>
        let contentText: Observable<String>
        let addPostButtonTapTrigger: Observable<Void>
        let addTravelPlanButtonTapTrigger: Observable<Void>
        let cancelPostButtonTapTrigger: Observable<Void>
        let imageStream: Observable<UIImage>
        let travelPlan: Observable<TravelPlan>
        let finishedAddingImageTrigger: Observable<Void>
    }
    
    struct Output {
        let postUploadSuccessTrigger: Driver<Void>
        let postValidation: Driver<Bool>
        let canelPostUploadTrigger: Driver<Void>
        let dataSource: Driver<[UIImage]>
        let storedTravelPlan: Driver<TravelPlan?>
    }
    
    func transform(input: Input) -> Output {
        
        let postValid = BehaviorRelay(value: false)
        let postUploadSuccessTrigger = PublishRelay<Void>()
        let cancelPostUploadTrigger = PublishRelay<Void>()
        let dataSource = PublishSubject<[UIImage]>()
        let uploadedImages = PublishSubject<[String]>()
        let storedTravelPlan = PublishSubject<TravelPlan?>()
        
        let postObservable = Observable.combineLatest(
            input.titleText,
            input.contentText,
            uploadedImages
        ).map { title, content, files in
            let encodedTravelPlan = self.travelPlan?.convertToCodableModel().encodeToString()
            
            let encodedTravelSchedule = self.travelSchedules.map {
                return $0.convertToCodableModel().encodeToString()
            }.joined(separator: "`")
            
            return UploadPostQuery(title: title, content: content, content1: encodedTravelPlan, content2: encodedTravelSchedule, files: files)
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
        
        input.addTravelPlanButtonTapTrigger
            .subscribe(with: self) { owner, _ in
                print("여행계획 갖다붙여~~")
            }
            .disposed(by: disposeBag)
        
        input.cancelPostButtonTapTrigger
            .subscribe(with: self) { owner, _ in
                cancelPostUploadTrigger.accept(())
            }
            .disposed(by: disposeBag)
        
        input.imageStream
            .subscribe(with: self) { owner, selectedImage in
                print("이미지 추가중")
                owner.dataSource.append(selectedImage)
                dataSource.onNext(owner.dataSource)
            }
            .disposed(by: disposeBag)
        
        input.travelPlan
            .subscribe(with: self) { owner, travelPlan in
                owner.travelPlan = travelPlan
                owner.travelSchedules = Array(owner.repository.fetchSchedule(planId: travelPlan.id))
                storedTravelPlan.onNext(travelPlan)
            }
            .disposed(by: disposeBag)
        
        input.finishedAddingImageTrigger
            .flatMap {
                let query = UploadPostImageQuery(files: self.compressImages(dataSource: self.dataSource))
                return NetworkManager.uploadImage(query: query)
            }
            .subscribe(with: self) { owner, response in
                print("이미지 업로드 성공")
                uploadedImages.onNext(response.files)
            }
            .disposed(by: disposeBag)
        
        return Output(postUploadSuccessTrigger: postUploadSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      postValidation: postValid.asDriver(),
                      canelPostUploadTrigger: cancelPostUploadTrigger.asDriver(onErrorJustReturn: ()),
                      dataSource: dataSource.asDriver(onErrorJustReturn: []),
                      storedTravelPlan: storedTravelPlan.asDriver(onErrorJustReturn: nil))
    }
    
    func compressImages(dataSource: [UIImage]) -> [Data] {
        var images: [Data] = []
        
        dataSource.forEach { uiimage in
            guard let jpegImage = uiimage.jpegData(compressionQuality: 0.5) else { return }
            
            if jpegImage.count <= (5 * 1024 * 1024) {
                print("현재 이미지 크기 \(jpegImage.count / (1 * 1024 * 1024))MB")
                images.append(jpegImage)
            }
        }
        
        return images
    }
}
