//
//  PlannerCollectionViewCell.swift
//  AdVoyager
//
//  Created by Minho on 5/3/24.
//

import UIKit
import SnapKit

final class PlannerCollectionViewCell: BaseCollectionViewCell {
    
    private let profileImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()
    private let nicknameLabel: UILabel = {
        let view = UILabel()
            
        return view
    }()
    
    override func configureHierarchy() {
        
    }
    
    override func configureConstraints() {
        
    }
    
    override func configureCell() {
        
    }

}
