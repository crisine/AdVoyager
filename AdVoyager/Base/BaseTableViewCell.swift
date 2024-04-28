//
//  BaseTableViewCell.swift
//  AdVoyager
//
//  Created by Minho on 4/28/24.
//

import UIKit

class BaseTableViewCell: UITableViewCell, Reusable {
    
    static var identifier: String {
        return String(describing: self)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureHierarchy()
        configureConstraints()
        configureCell()
    }
    
    func configureHierarchy() {}
    func configureConstraints() {}
    func configureCell() {}
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
