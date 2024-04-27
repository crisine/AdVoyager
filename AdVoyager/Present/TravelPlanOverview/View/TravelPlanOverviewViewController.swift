//
//  TravelPlanOverviewViewController.swift
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

final class TravelPlanOverviewViewController: TabmanViewController {
    
    private var viewControllers: Array<UINavigationController> = []
    
    private let addTravelPlanButton: FilledButton = {
        let plusImage = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32))
        let view = FilledButton(image: plusImage)
        return view
    }()
    
    private let disposeBag = DisposeBag()
    private let viewModel = TravelPlanOverviewViewModel()
    
    private var newTravelPlan = PublishSubject<TravelScheduleModel>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        configureHierarchy()
        configureConstraints()
        configureView()
    }
    
    private func bind() {
        
        let input = TravelPlanOverviewViewModel.Input(addTravelPlanButtonTap: addTravelPlanButton.rx.tap.asObservable(),
        newTravelPlan: newTravelPlan.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.addTravelPlanTrigger
            .drive(with: self) { owner, _ in
                let vc = AddNewTravelScheduleViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                
                vc.travelScheduleObservable.subscribe(with: self) { owner, travelPlan in
                    owner.newTravelPlan.onNext(travelPlan)
                }
                .disposed(by: vc.disposeBag)
                
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func configureHierarchy() {
        [addTravelPlanButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func configureConstraints() {
        addTravelPlanButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(32)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-64)
            make.size.equalTo(64)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(addTravelPlanButton.frame.height)
        addTravelPlanButton.circle()
    }
    
    func configureView() {
        viewControllers.append(UINavigationController(rootViewController: TravelScheduleViewController()))
        viewControllers.append(UINavigationController(rootViewController: TravelScheduleViewController()))
        
        let bar = TMBar.ButtonBar()
        bar.layout.transitionStyle = .snap
        bar.tintColor = .black
        
        bar.layout.alignment = .centerDistributed
        
        bar.buttons.customize { button in
            button.tintColor = .lightGray
            button.selectedTintColor = .systemBlue
        }
        
        self.dataSource = self
        addBar(bar, dataSource: self, at: .top)
        
        view.backgroundColor = .red
    }
}

extension TravelPlanOverviewViewController: PageboyViewControllerDataSource, TMBarDataSource {
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
