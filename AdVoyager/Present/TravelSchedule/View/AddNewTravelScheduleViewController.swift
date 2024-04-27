//
//  AddNewTravelScheduleViewController.swift
//  AdVoyager
//
//  Created by Minho on 4/27/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AddNewTravelScheduleViewController: BaseViewController {
    
    private let closeBarButtonItem: UIBarButtonItem = {
        let view = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil)
        return view
    }()
    private let addScheduleBarButtonItem: UIBarButtonItem = {
        let view = UIBarButtonItem(title: "추가", style: .done, target: nil, action: nil)
        return view
    }()
    
    private let scheduleDateStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillProportionally
        return view
    }()
    private let scheduleDateLabel: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 30)
        view.text = "일정 날짜 선택"
        view.textAlignment = .center
        return view
    }()
    private let scheduleDatePicker: UIDatePicker = {
        let view = UIDatePicker()
        view.datePickerMode = .dateAndTime
        return view
    }()
    private let scheduleTitleTextField: SignTextField = {
        let view = SignTextField(placeholderText: "제목 입력...")
        view.textAlignment = .left
        return view
    }()
    private let scheduleDescriptionTextField: ContentTextView = {
        let view = ContentTextView(placeholderText: "내용 입력...")
        return view
    }()
    
    private let viewModel = AddNewTravelScheduleViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    deinit {
        print("AddNewTravelVC Deinit")
    }
    
    override func bind() {
        
        let input = AddNewTravelScheduleViewModel.Input(closeButtonTap: closeBarButtonItem.rx.tap.asObservable(),
                                                    addScheduleButtonTap: addScheduleBarButtonItem.rx.tap.asObservable(),
                                                    scheduleDate: scheduleDatePicker.rx.date.asObservable(),
                                                    scheduleTitle: scheduleTitleTextField.rx.text.orEmpty.asObservable(),
                                                    scheduleDescription: scheduleDescriptionTextField.rx.text.orEmpty.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.closeTrigger
            .drive(with: self) { owner, _ in
                // TODO: 텍스트필드에 수정 사항이 있었을 경우 닫기 전에 한번 Alert로 물어봐야 함.
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.successTrigger
            .drive(with: self) { owner, schedule in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        
        [scheduleDateLabel, scheduleDatePicker].forEach {
            scheduleDateStackView.addArrangedSubview($0)
        }
        
        [scheduleDateStackView, scheduleTitleTextField, scheduleDescriptionTextField].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureConstraints() {
        scheduleDateStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        scheduleTitleTextField.snp.makeConstraints { make in
            make.top.equalTo(scheduleDateStackView.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(32)
        }
        
        scheduleDescriptionTextField.snp.makeConstraints { make in
            make.top.equalTo(scheduleTitleTextField.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }
    
    override func configureView() {
        navigationItem.title = "신규 여행 일정"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        self.navigationItem.leftBarButtonItem = closeBarButtonItem
        self.navigationItem.rightBarButtonItem = addScheduleBarButtonItem
    }
}
