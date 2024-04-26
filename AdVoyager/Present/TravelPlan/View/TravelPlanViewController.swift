//
//  TravelPlanViewController.swift
//  AdVoyager
//
//  Created by Minho on 4/24/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class TravelPlanViewController: BaseViewController {
    
    private let travelPlanTableView: UITableView = {
        let view = UITableView()
        view.register(TravelPlanTableViewCell.self, forCellReuseIdentifier: "cell")
        view.separatorStyle = .none
        return view
    }()
    
    private let addTravelPlanButton: FilledButton = {
        let plusImage = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32))
        let view = FilledButton(image: plusImage)
        return view
    }()
    
    private let viewModel = TravelPlanViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(addTravelPlanButton.frame.height)
        addTravelPlanButton.circle()
    }
    
    override func bind() {
        print(#function)
        
        let input = TravelPlanViewModel.Input(travelPlanItem: travelPlanTableView.rx
            .modelSelected(TravelPlanModel.self)
            .asObservable(),
                                              tableViewIndexPath: travelPlanTableView.rx.itemSelected.asObservable(),
                                              addTravelPlanButtonTap: addTravelPlanButton.rx.tap.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.dataSource
            .drive(travelPlanTableView.rx.items(cellIdentifier: "cell", cellType: TravelPlanTableViewCell.self)) {
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
        
        output.addTravelPlanTrigger
            .drive(with: self) { owner, _ in
                let nav = UINavigationController(rootViewController: AddNewTravelPlanViewController())
                nav.modalPresentationStyle = .fullScreen
                
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [travelPlanTableView, addTravelPlanButton].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureConstraints() {
        travelPlanTableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        addTravelPlanButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(32)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-64)
            make.size.equalTo(64)
        }
    }
    
    override func configureView() {
        navigationItem.title = "여행 일정"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
