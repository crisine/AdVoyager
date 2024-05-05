//
//  TravelPlanOverviewViewController.swift
//  AdVoyager
//
//  Created by Minho on 4/28/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class TravelPlanOverviewViewController: BaseViewController {
    
    private let travelPlanTableView: UITableView = {
        let view = UITableView()
        view.register(TravelPlanTableViewCell.self, forCellReuseIdentifier: TravelPlanTableViewCell.identifier)
        view.separatorStyle = .none
        return view
    }()
    private let addTravelPlanButton: FilledButton = {
        let plusImage = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32))
        let view = FilledButton(image: plusImage)
        view.backgroundColor = .systemPurple
        return view
    }()
    
    private let viewModel = TravelPlanOverviewViewModel()
    private let dataReloadTrigger = PublishRelay<Void>()
    lazy var planSelectObservable = travelPlanTableView.rx.modelSelected(TravelPlan.self)
        .asObservable()
    var addPostMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func bind() {
        let input =
        TravelPlanOverviewViewModel.Input(
            travelPlan: travelPlanTableView.rx.modelSelected(TravelPlan.self).asObservable(),
            tableViewIndexPath: travelPlanTableView.rx.itemSelected.asObservable(),
            addTravelPlanButtonTap: addTravelPlanButton.rx.tap.asObservable(),
            dataReloadTrigger: dataReloadTrigger.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.dataSource
            .drive(travelPlanTableView.rx.items(cellIdentifier: TravelPlanTableViewCell.identifier, cellType: TravelPlanTableViewCell.self)) { row, element, cell in
                cell.updateCell(data: element)
            }
            .disposed(by: disposeBag)
        
        planSelectObservable
            .subscribe(with: self) { owner, travelPlanModel in
                if owner.addPostMode {
                    owner.dismiss(animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        output.moveToAddTravelPlanViewTrigger
            .drive(with: self) { owner, _ in
                // MARK: 새 여행 계획 입력 화면 만들고 present
                let vc = AddTravelPlanViewController()
                let nav = UINavigationController(rootViewController: vc)
                owner.present(nav, animated: true)
                
                vc.dismissTrigger
                    .subscribe(with: self) { owner, _ in
                        owner.dataReloadTrigger.accept(())
                    }
                    .disposed(by: vc.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.travelPlan
            .drive(with: self) { owner, travelPlan in
                guard let travelPlan else { return }
                
                let vc = TravelPlanDetailViewController()
                vc.hidesBottomBarWhenPushed = true
                
                vc.viewModel.selectedTravelPlan = travelPlan
                
                owner.navigationController?.pushViewController(vc, animated: true)
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
        [travelPlanTableView, addTravelPlanButton].forEach {
            view.addSubview($0)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addTravelPlanButton.circle()
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
        navigationItem.title = "여행 계획"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        self.isLogoVisible = true
    }
}
