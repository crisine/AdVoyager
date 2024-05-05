//
//  PostDetailViewModel.swift
//  AdVoyager
//
//  Created by Minho on 5/1/24.
//

import Foundation
import RxSwift
import RxCocoa

final class PostDetailViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    private var post: Post?
    private var dataSource: [String] = []
    private let repository = Repository()
    
    struct Input {
        let viewWillAppearTrigger: Observable<Post>
        let modifyPostTrigger: Observable<Void>
        let deletePostTrigger: Observable<Void>
        let savePlanTrigger: Observable<Void>
        let pushBackedDate: Observable<Date?>
    }
    
    struct Output {
        let dataSource: Driver<[String]>
        let deletePostSuccess: Driver<Void>
        let saveStatus: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        
        let dataSource = PublishSubject<[String]>()
        let deletePostSuccess = PublishSubject<Void>()
        let saveStatus = PublishSubject<Bool>()
        
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
        
        input.savePlanTrigger
            .withLatestFrom(input.pushBackedDate)
            .map { [weak self] pushBackedDate in
                guard let self else { return false }
                return self.saveTravelPlan(post: self.post, pushBackedDate: pushBackedDate)
            }
            .subscribe(with: self) { owner, saveSuccess in
                saveStatus.onNext(saveSuccess)
            }
            .disposed(by: disposeBag)
        
        return Output(dataSource: dataSource.asDriver(onErrorJustReturn: []),
                      deletePostSuccess: deletePostSuccess.asDriver(onErrorJustReturn: ()),
                      saveStatus: saveStatus.asDriver(onErrorJustReturn: false))
    }
    
    func saveTravelPlan(post: Post?, pushBackedDate: Date?) -> Bool {
        guard let post else { return false }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let rawTravelPlanString = post.content1
        let rawTravelScheduleStrings = post.content2?.split(separator: "`")
        
        guard let rawTravelPlanString,
              let rawTravelScheduleStrings else {
                  return false
              }
        
        let travelPlanModel = try! decoder.decode(TravelPlanModel.self, from: rawTravelPlanString.data(using: .utf8)!)
        
        let travelScheduleModels = rawTravelScheduleStrings.map {
            return try! decoder.decode(TravelScheduleModel.self, from: $0.data(using: .utf8)!)
        }
        
        let pushBackTimeInterval = travelPlanModel.firstDate.distance(to: pushBackedDate ?? travelPlanModel.firstDate)
        
        print("pushBackTimeInterval: \(pushBackTimeInterval)")
        
        let travelPlan = TravelPlan(
            planTitle: travelPlanModel.planTitle,
            firstDate: travelPlanModel.firstDate + pushBackTimeInterval,
            lastDate: travelPlanModel.lastDate + pushBackTimeInterval
        )
        
        repository.addTravelPlan(travelPlan)
        
        travelScheduleModels.forEach {
            repository.addSchedule(TravelSchedule(planId: travelPlan.id,
                                                  order: $0.order,
                                                  date: $0.date + pushBackTimeInterval,
                                                  scheduleTitle: $0.scheduleTitle,
                                                  scheduleDescription: $0.scheduleDescription, 
                                                  latitude: $0.latitude,
                                                  longitude: $0.longitude))
        }
        
        return true
    }
}
