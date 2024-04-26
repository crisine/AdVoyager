//
//  AddNewTravelPlanViewController.swift
//  AdVoyager
//
//  Created by Minho on 4/27/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AddNewTravelPlanViewController: BaseViewController {
    
    private let closeBarButtonItem: UIBarButtonItem = {
        let view = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil)
        return view
    }()
    
    private let planTitleTextField: SignTextField = {
        let view = SignTextField(placeholderText: "제목 입력...")
        return view
    }()
    
    private let planDescriptionTextField: ContentTextView = {
        let view = ContentTextView(placeholderText: "내용 입력...")
        return view
    }()
    
    private let viewModel = AddNewTravelPlanViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func bind() {
        
        let input = AddNewTravelPlanViewModel.Input(closeButtonTap: closeBarButtonItem.rx.tap.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.closeTrigger
            .drive(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [planTitleTextField, planDescriptionTextField].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureConstraints() {
        planTitleTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(32)
        }
        
        planDescriptionTextField.snp.makeConstraints { make in
            make.top.equalTo(planTitleTextField.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }
    
    override func configureView() {
        self.navigationItem.leftBarButtonItem = closeBarButtonItem
    }
}
