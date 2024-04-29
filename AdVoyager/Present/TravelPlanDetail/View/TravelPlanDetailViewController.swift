//
//  TravelPlanDetailViewController.swift
//  AdVoyager
//
//  Created by Minho on 4/27/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Tabman
import Pageboy

final class TravelPlanDetailViewController: TabmanViewController {
    
    private let fullView: UIView = {
        let view = UIView()
        return view
    }()
    private let addTravelScheduleButton: FilledButton = {
        let plusImage = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32))
        let view = FilledButton(image: plusImage)
        view.layer.cornerRadius = 32
        view.backgroundColor = .systemPurple
        return view
    }()
    
    private let disposeBag = DisposeBag()
    let viewModel = TravelPlanDetailViewModel()
    let reloadDataTrigger = PublishRelay<Void>()
    
    private var newTravelSchedule = PublishSubject<TravelScheduleModel>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        configureHierarchy()
        configureConstraints()
        configureView()
    }
    
    private func bind() {
        
        let input = TravelPlanDetailViewModel.Input(reloadDataTrigger: reloadDataTrigger.asObservable(),
                                                    addTravelScheduleButtonTap: addTravelScheduleButton.rx.tap.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.addTravelScheduleTrigger
            .drive(with: self) { owner, _ in
                let vc = AddNewTravelScheduleViewController()
                let nav = UINavigationController(rootViewController: vc)
                
                vc.dismissTrigger.subscribe(with: self) { owner, _ in
                    owner.reloadDataTrigger.accept(())
                }
                .disposed(by: vc.disposeBag)
                
                vc.viewModel.selectedTravelPlan = owner.viewModel.selectedTravelPlan
                
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureHierarchy() {
        [fullView, addTravelScheduleButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func configureConstraints() {
        fullView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(32)
        }
        
        addTravelScheduleButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(32)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-64)
            make.size.equalTo(64)
        }
    }
    
    func configureView() {
        viewModel.setViewControllers()
        
        let bar = TMBar.ButtonBar()
        bar.layout.transitionStyle = .snap
        bar.tintColor = .systemPurple
        
        bar.layout.alignment = .centerDistributed
        
        bar.buttons.customize { button in
            button.tintColor = .lightGray
            button.selectedTintColor = .systemPurple
        }
        
        self.dataSource = self
        addBar(bar, dataSource: self, at: .custom(view: fullView, layout: nil))
        
        view.backgroundColor = .white
        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "여행 일정"
    }
}

extension TravelPlanDetailViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let item = TMBarItem(title: "")
        item.title = "\(index + 1)일차"
        
        return item
    }
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewModel.viewControllers.count
    }

    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        // MARK: 여기서 index로 지금 몇 번째 뷰를 보고있는지 알 수 있음.
        // print("이건 언제불리니 \(index)")
        return viewModel.viewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
}
