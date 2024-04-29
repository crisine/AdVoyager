//
//  TravelScheduleViewController.swift
//  AdVoyager
//
//  Created by Minho on 4/24/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class TravelScheduleViewController: BaseViewController {
    
    private let travelPlanTableView: UITableView = {
        let view = UITableView()
        view.register(TravelScheduleTableViewCell.self, forCellReuseIdentifier: TravelScheduleTableViewCell.identifier)
        view.separatorStyle = .none
        return view
    }()

    let viewModel = TravelScheduleViewModel()
    let reloadDataTrigger = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadDataTrigger.onNext(())
    }
    
    deinit {
        print("일정표 deinit")
    }
    
    override func bind() {
        print(#function)
        
        let input = TravelScheduleViewModel.Input(reloadDataTrigger: reloadDataTrigger.asObservable(),
                                                  travelSchedule: travelPlanTableView.rx
            .modelSelected(TravelSchedule.self)
            .asObservable(),
                                              tableViewIndexPath: travelPlanTableView.rx.itemSelected.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.dataSource
            .drive(travelPlanTableView.rx.items(cellIdentifier: TravelScheduleTableViewCell.identifier, cellType: TravelScheduleTableViewCell.self)) {
                row, element, cell in
                
                output.dataSource
                    .map { dataSource in
                        print(row)
                        return row == dataSource.count - 1
                    }
                    .drive(with: self) { owner, isLastCell in
                        cell.updateCell(data: element, isLastCell: isLastCell)
                    }.disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.indexPath
            .drive(with: self) { owner, indexPath in
                guard let indexPath else { return }
                owner.travelPlanTableView.deselectRow(at: indexPath, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [travelPlanTableView].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureConstraints() {
        travelPlanTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }
    
    override func configureView() {
        // 배경으로 깔리는 뷰
//        view.backgroundColor = .systemGray6
    }
}
