//
//  BaseCollectionViewCell.swift
//  AdVoyager
//
//  Created by Minho on 4/30/24.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
