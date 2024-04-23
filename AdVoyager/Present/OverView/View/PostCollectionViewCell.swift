//
//  PostCollectionViewCell.swift
//  AdVoyager
//
//  Created by Minho on 4/20/24.
//

import UIKit

class PostCollectionViewCell: UICollectionViewCell {
    
    let backView: NeuView = {
        let view = NeuView()
//        view.clipsToBounds = true
//        view.layer.cornerRadius = 16
        return view
    }()
    let titleImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 24)
        view.textAlignment = .center
        view.text = "Sample Text"
        return view
    }()
    let likeImage: UIImage = {
        let view = UIImage(systemName: "heart.fill")!
        return view.withTintColor(.systemPink)
    }()
    let likeLabel: UILabel = {
        let view = UILabel()
        
        return view
    }()
    let addressLabel: UILabel = {
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
        contentView.addSubview(backView)
        
        [titleImageView, titleLabel, addressLabel].forEach {
            backView.addSubview($0)
        }
    }
    
    func configureConstraints() {
        
        backView.snp.makeConstraints { make in
            make.edges.equalTo(contentView.safeAreaLayoutGuide).inset(16)
        }
        
        titleImageView.snp.makeConstraints { make in
            make.top.equalTo(backView.snp.top).offset(8)
            make.horizontalEdges.equalTo(backView).inset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleImageView.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(titleImageView)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(titleImageView)
            make.bottom.equalTo(backView).offset(-8)
        }
    }
    
    func configureView() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
