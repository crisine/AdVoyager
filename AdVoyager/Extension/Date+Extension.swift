//
//  Date+Extension.swift
//  AdVoyager
//
//  Created by Minho on 4/16/24.
//

import Foundation

extension Date {
    
    func toString(format: String) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = format
        
        return dateformatter.string(from: self)
    }
    
    func isSameWith(_ otherDate: Date) -> Bool {
        let calendar = Calendar.current
        
        let components1 = calendar.dateComponents([.year, .month, .day], from: self)
        let components2 = calendar.dateComponents([.year, .month, .day], from: otherDate)
        
        return components1.year == components2.year &&
               components1.month == components2.month &&
               components1.day == components2.day
    }
}
