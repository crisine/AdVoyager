//
//  BirthdayDatePicker.swift
//  AdVoyager
//
//  Created by Minho on 4/16/24.
//

import UIKit

class BirthdayDatePicker: UIDatePicker {

    init() {
        super.init(frame: .zero)
        
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray3.cgColor
        
        let dateString = "19000101"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        minimumDate = dateFormatter.date(from: dateString)
        maximumDate = Date.now
        datePickerMode = .date
        timeZone = .current
        
        let picker = UIDatePicker()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
