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
import FSCalendar

final class AddNewTravelScheduleViewController: BaseViewController {
    
    private let closeBarButtonItem: UIBarButtonItem = {
        let view = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil)
        view.tintColor = .lightpurple
        return view
    }()
    private let scheduleDateLabel: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 30)
        view.text = "일정 시간 선택"
        view.textAlignment = .center
        return view
    }()
    private let scheduleTimePicker: UIDatePicker = {
        let view = UIDatePicker()
        view.datePickerMode = .time
        view.tintColor = .lightpurple
        return view
    }()
    lazy var scheduleDatePicker: FSCalendar = {
        let view = FSCalendar()
        view.delegate = self
        view.appearance.weekdayTextColor = .lightpurple
        view.appearance.headerTitleColor = .lightpurple
        view.appearance.selectionColor = .lightpurple
        view.appearance.todayColor = .systemRed
        view.tintColor = .lightpurple
        view.locale = Locale(identifier: "ko_KR")
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
    private let addScheduleButton: FilledButton = {
        let view = FilledButton(title: "일정 저장하기")
        return view
    }()
    
    let viewModel = AddNewTravelScheduleViewModel()
    private var selectedDate = PublishSubject<Date>()
    let dismissTrigger = PublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    deinit {
        print("AddNewTravelVC Deinit")
    }
    
    override func bind() {
        
        let input = AddNewTravelScheduleViewModel.Input(closeButtonTap: closeBarButtonItem.rx.tap.asObservable(),
                                                    addScheduleButtonTap: addScheduleButton.rx.tap.asObservable(),
                                                        scheduleDate: selectedDate.asObservable(),
                                                        scheduleTime: scheduleTimePicker.rx.date.asObservable(),
                                                    scheduleTitle: scheduleTitleTextField.rx.text.orEmpty.asObservable(),
                                                    scheduleDescription: scheduleDescriptionTextField.rx.text.orEmpty.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.closeTrigger
            .drive(with: self) { owner, _ in
                // TODO: 수정 사항이 있었을 경우 닫기 전에 한번 Alert로 물어봐야 함.
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.successTrigger
            .drive(with: self) { owner, _ in
                owner.dismissTrigger.onNext(())
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [scheduleDateLabel, scheduleTimePicker, scheduleDatePicker, scheduleTitleTextField, scheduleDescriptionTextField, addScheduleButton].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureConstraints() {
        scheduleDateLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.width.equalTo(200)
        }
        
        scheduleTimePicker.snp.makeConstraints { make in
            make.top.equalTo(scheduleDateLabel.snp.top)
            make.leading.equalTo(scheduleDateLabel.snp.trailing).offset(8)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(scheduleDateLabel)
        }
        
        scheduleDatePicker.snp.makeConstraints { make in
            make.top.equalTo(scheduleDateLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(360)
        }
        
        scheduleTitleTextField.snp.makeConstraints { make in
            make.top.equalTo(scheduleDatePicker.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(48)
        }
        
        scheduleDescriptionTextField.snp.makeConstraints { make in
            make.top.equalTo(scheduleTitleTextField.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(addScheduleButton.snp.top).offset(-16)
        }
        
        addScheduleButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-32)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(48)
        }
    }
    
    override func configureView() {
        self.navigationItem.leftBarButtonItem = closeBarButtonItem
        
        guard let travelPlan = viewModel.selectedTravelPlan else { return }
        scheduleDatePicker.currentPage = travelPlan.firstDate
    }
}

extension AddNewTravelScheduleViewController: FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.selectedDate.onNext(date)
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        guard let travelPlan = viewModel.selectedTravelPlan else { return true }
        let minDate = travelPlan.firstDate
        let maxDate = travelPlan.lastDate
        
        return date >= minDate && date <= maxDate
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        
        guard let travelPlan = viewModel.selectedTravelPlan else { return .black }
        let minDate = travelPlan.firstDate
        let maxDate = travelPlan.lastDate
        
        if date >= minDate && date <= maxDate {
            return .black
        } else {
            return .lightGray
        }
    }
}
