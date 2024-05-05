//
//  PushBackViewController.swift
//  AdVoyager
//
//  Created by Minho on 5/5/24.
//

import UIKit
import FSCalendar
import RxSwift
import RxCocoa

final class PushBackViewController: BaseViewController {
    
    private lazy var cancelSelectDateBarButton: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "취소", style: .plain, target: self, action: nil)
        item.tintColor = .red
        return item
    }()
    private lazy var doneSelectDateBarButton: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "확인", style: .done, target: self, action: nil)
        item.isEnabled = false
        return item
    }()
    
    private lazy var calendarView: FSCalendar = {
        let view = FSCalendar()
        
        view.appearance.weekdayTextColor = .lightpurple
        view.appearance.headerTitleColor = .lightpurple
        view.appearance.selectionColor = .lightpurple
        view.appearance.todayColor = .systemRed
        view.tintColor = .lightpurple
        view.locale = Locale(identifier: "ko_KR")
        
        view.delegate = self
        
        return view
    }()
    
    private var selectedDate: Date?
    let selectedDateStream = PublishSubject<Date?>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let sheetPresentationController = sheetPresentationController {
                    sheetPresentationController.detents = [.medium()]
        }
    }
    
    override func bind() {
        cancelSelectDateBarButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        doneSelectDateBarButton.rx.tap
            .map { [weak self] _ in
                return self?.selectedDate
            }
            .subscribe(with: self) { owner, date in
                owner.selectedDateStream.onNext(date)
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [calendarView].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureConstraints() {
        let screenHeight = UIScreen.main.bounds.height
        
        calendarView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo((screenHeight / 2) - 64)
        }
    }
    
    override func configureView() {
        navigationItem.title = "출발 일정 선택"
        navigationItem.leftBarButtonItem = cancelSelectDateBarButton
        navigationItem.rightBarButtonItem = doneSelectDateBarButton
    }
}

extension PushBackViewController: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        doneSelectDateBarButton.isEnabled = true
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = nil
        doneSelectDateBarButton.isEnabled = false
    }
}
