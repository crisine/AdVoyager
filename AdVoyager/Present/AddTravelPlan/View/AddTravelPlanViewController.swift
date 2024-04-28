//
//  AddTravelPlanViewController.swift
//  AdVoyager
//
//  Created by Minho on 4/28/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import FSCalendar

final class AddTravelPlanViewController: BaseViewController {
    
    private let planTitleTextField: SignTextField = {
        let view = SignTextField(placeholderText: "여행 제목 입력...")
        return view
    }()
    private lazy var planDatePicker: FSCalendar = {
        let view = FSCalendar()
        view.appearance.weekdayTextColor = .lightpurple
        view.appearance.headerTitleColor = .lightpurple
        view.appearance.selectionColor = .lightpurple
        view.appearance.todayColor = .systemRed
        view.allowsMultipleSelection = true
        view.tintColor = .lightpurple
        view.locale = Locale(identifier: "ko_KR")
        
        view.delegate = self
        return view
    }()
    private let addPlanButton: FilledButton = {
        let view = FilledButton(title: "저장하기")
        return view
    }()
    
    private let firstDatePlaceHolderLabel: UILabel = {
        let view = UILabel()
        view.text = "시작일"
        view.font = .boldSystemFont(ofSize: 32)
        view.textAlignment = .center
        return view
    }()
    private let lastDatePlaceHolderLabel: UILabel = {
        let view = UILabel()
        view.text = "종료일"
        view.font = .boldSystemFont(ofSize: 32)
        view.textAlignment = .center
        return view
    }()
    
    private let datePlaceHolderLabelStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.alignment = .bottom
        return view
    }()
    
    private let firstDateLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 32)
        view.textAlignment = .center
        
        return view
    }()
    private let lastDateLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 32)
        view.textAlignment = .center
        return view
    }()
    
    private let dateLabelStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.alignment = .top
        return view
    }()
    
    private var firstDate: Date?
    private var lastDate: Date?
    private var datesRange: [Date]?
    
    private let firstDateObservable = PublishSubject<Date?>()
    private let lastDateObservable = PublishSubject<Date?>()
    
    private let viewModel = AddTravelPlanViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func bind() {
        
        let input = AddTravelPlanViewModel.Input(firstDate: firstDateObservable.asObservable(),
                                                 lastDate: lastDateObservable.asObservable())
        
        let output = viewModel.transform(input: input)
        
        // TODO: Model 형태로 전달하여 반영하는 것이 좋을 것 같음.
        output.firstDateString
            .drive(with: self) { owner, firstDateString in
                owner.firstDateLabel.text = firstDateString
            }
            .disposed(by: disposeBag)
        
        output.lastDateString
            .drive(with: self) { owner, lastDateString in
                owner.lastDateLabel.text = lastDateString
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [firstDateLabel, lastDateLabel].forEach {
            dateLabelStackView.addArrangedSubview($0)
        }
        
        [firstDatePlaceHolderLabel, lastDatePlaceHolderLabel].forEach {
            datePlaceHolderLabelStackView.addArrangedSubview($0)
        }
        
        [planTitleTextField, planDatePicker, datePlaceHolderLabelStackView, dateLabelStackView, addPlanButton].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureConstraints() {
        planTitleTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(48)
        }
        
        planDatePicker.snp.makeConstraints { make in
            make.top.equalTo(planTitleTextField.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(360)
        }
        
        datePlaceHolderLabelStackView.snp.makeConstraints { make in
            make.top.equalTo(planDatePicker.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(32)
        }
        
        dateLabelStackView.snp.makeConstraints { make in
            make.top.equalTo(datePlaceHolderLabelStackView.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(addPlanButton.snp.top).offset(16)
        }
        
        addPlanButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-32)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(48)
        }
    }
    
    override func configureView() {
        navigationItem.title = "새로운 여행 계획"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

extension AddTravelPlanViewController: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if firstDate == nil {
            firstDate = date
            firstDateObservable.onNext(firstDate!)
            
            datesRange = [firstDate!]
            
            return
        }
        
        if firstDate != nil && lastDate == nil {
            if date <= firstDate! {
                calendar.deselect(firstDate!)
                firstDate = date
                firstDateObservable.onNext(firstDate)
                datesRange = [firstDate!]
                
                return
            }
            
            let range = datesRange(from: firstDate!, to: date)

            lastDate = range.last
            lastDateObservable.onNext(lastDate)
            
            for d in range {
                calendar.select(d)
            }
            
            datesRange = range
            
            return
        }
        
        
        if firstDate != nil && lastDate != nil {
            for d in calendar.selectedDates {
                calendar.deselect(d)
            }
            
            lastDate = nil
            lastDateObservable.onNext(nil)
            firstDate = nil
            firstDateObservable.onNext(nil)
            
            datesRange = []
        }
    }

    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {

        // MARK: 날짜 범위가 선택된 상태에서 다른 곳을 누르려고 하는 경우 선택 기간 초기화
        if firstDate != nil && lastDate != nil {
            for d in calendar.selectedDates {
                calendar.deselect(d)
            }
            
            lastDate = nil
            lastDateObservable.onNext(nil)
            firstDate = nil
            firstDateObservable.onNext(nil)
            
            datesRange = []
        }
    }
    
    func datesRange(from: Date, to: Date) -> [Date] {
        
        // MARK: 선택한 여행 시작 날짜가 종료 날짜보다 이후인 경우 빈 배열 반환
        if from > to { return [Date]() }

        var tempDate = from
        var array = [tempDate]

        while tempDate < to {
            tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
            array.append(tempDate)
        }

        return array
    }
}
