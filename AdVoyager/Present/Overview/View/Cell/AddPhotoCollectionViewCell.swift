//
//  AddPhotoCollectionViewCell.swift
//  AdVoyager
//
//  Created by Minho on 5/1/24.
//

import UIKit

class AddPhotoCollectionViewCell: BaseCollectionViewCell {
    
    let photoImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(photoImageView)
    }
    
    override func configureConstraints() {
        photoImageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
    
    override func configureCell() {
        contentMode = .scaleAspectFill
    }
}
