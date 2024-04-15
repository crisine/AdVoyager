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
}
