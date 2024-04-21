//
//  PostCollectionViewCell.swift
//  AdVoyager
//
//  Created by Minho on 4/20/24.
//

import UIKit

class PostCollectionViewCell: UICollectionViewCell {
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 24)
        view.textAlignment = .center
        view.text = "Sample Text"
        return view
    }()
    let contentLabel: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 16)
        view.textAlignment = .center
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureHierarchy()
        configureConstraints()
        configureView()
    }
    
    func configureHierarchy() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)
    }
    
    func configureConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(4)
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(16)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(titleLabel.snp.horizontalEdges)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).offset(-4)
        }
    }
    
    func configureView() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
