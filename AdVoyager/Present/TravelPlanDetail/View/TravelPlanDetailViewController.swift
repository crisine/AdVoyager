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
    
    private var viewControllers: Array<UINavigationController> = []
    
    private let addTravelScheduleButton: FilledButton = {
        let plusImage = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32))
        let view = FilledButton(image: plusImage)
        view.backgroundColor = .systemPurple
        return view
    }()
    
    private let disposeBag = DisposeBag()
    private let viewModel = TravelPlanDetailViewModel()
    
    private var newTravelSchedule = PublishSubject<TravelScheduleModel>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        configureHierarchy()
        configureConstraints()
        configureView()
    }
    
    private func bind() {
        
        let input = TravelPlanDetailViewModel.Input(addTravelScheduleButtonTap: addTravelScheduleButton.rx.tap.asObservable(),
        newTravelPlan: newTravelSchedule.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.addTravelScheduleTrigger
            .drive(with: self) { owner, _ in
                let nav = UINavigationController(rootViewController: AddNewTravelScheduleViewController())
                nav.modalPresentationStyle = .fullScreen
                
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureHierarchy() {
        [addTravelScheduleButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func configureConstraints() {
        addTravelScheduleButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(32)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-64)
            make.size.equalTo(64)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(addTravelScheduleButton.frame.height)
        addTravelScheduleButton.circle()
    }
    
    func configureView() {
        viewControllers.append(UINavigationController(rootViewController: TravelScheduleViewController()))
        viewControllers.append(UINavigationController(rootViewController: TravelScheduleViewController()))
        
        let bar = TMBar.ButtonBar()
        bar.layout.transitionStyle = .snap
        bar.tintColor = .systemPurple
        
        bar.layout.alignment = .centerDistributed
        
        bar.buttons.customize { button in
            button.tintColor = .lightGray
            button.selectedTintColor = .systemPurple
        }
        
        self.dataSource = self
        addBar(bar, dataSource: self, at: .top)
        
        view.backgroundColor = .red
    }
}

extension TravelPlanDetailViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        let item = TMBarItem(title: "")
        item.title = "\(index + 1)일차"
        
        return item
    }
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }

    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        // MARK: 여기서 index로 지금 몇 번째 뷰를 보고있는지 알 수 있음.
        // print("이건 언제불리니 \(index)")
        return viewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
}
