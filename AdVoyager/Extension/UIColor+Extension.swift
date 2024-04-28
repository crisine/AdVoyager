//
//  UIColor+Extension.swift
//  AdVoyager
//
//  Created by Minho on 4/28/24.
//

import UIKit

extension UIColor {
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs((1.0 - (percentage / 100.0)) * -1.0))
    }

    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: percentage / 100.0)
    }

    func adjust(by value: CGFloat) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + value, 1.0),
                           green: min(green + value, 1.0),
                           blue: min(blue + value, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}
