//
//  TravelPlanViewModel.swift
//  AdVoyager
//
//  Created by Minho on 4/24/24.
//

import RxSwift
import RxCocoa
import Foundation

final class TravelPlanViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    private var dataSource: [TravelPlanModel] = []
    
    struct Input {
        let travelPlanItem: Observable<TravelPlanModel>
        let tableViewIndexPath: Observable<IndexPath>
        let addTravelPlanButtonTap: Observable<Void>
    }
    
    struct Output {
        let dataSource: Driver<[TravelPlanModel]>
        let indexPath: Driver<IndexPath?>
        let addTravelPlanTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let selectedTableViewItem = BehaviorSubject<TravelPlanModel?>(value: nil)
        let selectedIndexPath = PublishRelay<IndexPath?>()
        let addTravelPlanTrigger = PublishRelay<Void>()
        
        // 먼저 더미데이터부터 표현하고 저장해보자
        self.dataSource = [TravelPlanModel(post_id: "1", id: UUID(), order: 1, date: Date(), placeTitle: "기상 & 식사", description: "밤에 사온 로손 편의점 도시락 데워먹고 오후에 조이폴리스 갈거니까 짐 줄여두기", latitude: "111.111", longitude: "111.111"),
                           TravelPlanModel(post_id: "2", id: UUID(), order: 2, date: Date().addingTimeInterval(3600), placeTitle: "조이폴리스에서 신나게 놀기", description: "하프파이프 도쿄 - G-Storm - 롤코 순으로 무한으로 즐기기!!", latitude: "111.111", longitude: "111.111"),
                           TravelPlanModel(post_id: "3", id: UUID(), order: 3, date: Date().addingTimeInterval(3600 * 5), placeTitle: "도쿄 스카이트리 이동", description: "유리카모메선 타고 나가서 시내 지하철 타고 이동", latitude: "111.111", longitude: "111.111")]
        
        let dataSource = BehaviorRelay<[TravelPlanModel]>(value: dataSource)
        
        input.travelPlanItem
            .subscribe(with: self) { owner, item in
                selectedTableViewItem.onNext(item)
            }
            .disposed(by: disposeBag)
        
        input.tableViewIndexPath
            .subscribe(with: self) { owner, indexPath in
                selectedIndexPath.accept(indexPath)
            }
            .disposed(by: disposeBag)
        
        input.addTravelPlanButtonTap
            .bind(onNext: addTravelPlanTrigger.accept(_:))
            .disposed(by: disposeBag)
            
        
        return Output(dataSource: dataSource.asDriver(),
                      indexPath: selectedIndexPath.asDriver(onErrorJustReturn: nil),
                      addTravelPlanTrigger: addTravelPlanTrigger.asDriver(onErrorJustReturn: ()))
    }
}
