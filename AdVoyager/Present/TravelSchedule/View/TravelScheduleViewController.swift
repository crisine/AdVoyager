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
        view.register(TravelScheduleTableViewCell.self, forCellReuseIdentifier: "cell")
        view.separatorStyle = .none
        return view
    }()
    
    private let viewModel = TravelScheduleViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        print(#function)
        
        let input = TravelScheduleViewModel.Input(travelPlanItem: travelPlanTableView.rx
            .modelSelected(TravelScheduleModel.self)
            .asObservable(),
                                              tableViewIndexPath: travelPlanTableView.rx.itemSelected.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.dataSource
            .drive(travelPlanTableView.rx.items(cellIdentifier: "cell", cellType: TravelScheduleTableViewCell.self)) {
                row, element, cell in
                
                output.dataSource
                    .map { dataSource in
                        print(row)
                        return row == dataSource.count - 1
                    }
                    .drive(with: self) { owner, isLastCell in
                        cell.updateCell(data: element, isLastCell: isLastCell)
                    }.dispose()
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
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureView() {
        navigationItem.title = "여행 일정"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
