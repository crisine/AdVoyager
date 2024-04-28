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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func bind() {
        let input = TravelPlanOverviewViewModel.Input(addTravelPlanButtonTap: addTravelPlanButton.rx.tap.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.moveToAddTravelPlanViewTrigger
            .drive(with: self) { owner, _ in
                // MARK: 새 여행 계획 입력 화면 만들고 present
                let nav = UINavigationController(rootViewController: AddTravelPlanViewController())
                owner.present(nav, animated: true)
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
    }
}
