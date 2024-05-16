//
//  PlanCollectionViewCell.swift
//  AdVoyager
//
//  Created by Minho on 5/3/24.
//

import SwiftUI
import UIKit
import SnapKit
import Hero

final class PlanCollectionViewCell: BaseCollectionViewCell {
    
    private let shadowView: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowRadius = 5
        view.layer.cornerRadius = 16
        view.backgroundColor = .white
        return view
    }()
    
    private let backView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()
    private let thumbnailImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.layer.masksToBounds = true
        return view
    }()
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.text = "제목 없음"
        view.textAlignment = .center
        view.font = .boldSystemFont(ofSize: 18)
        view.numberOfLines = 2
        return view
    }()
    
    private let commentIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "bubble")
        view.tintColor = .black
        view.contentMode = .scaleAspectFit
        return view
    }()
    private let commentCountLabel: UILabel = {
        let view = UILabel()
        view.text = "0"
        view.font = .systemFont(ofSize: 16)
        return view
    }()
    private let likeIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "heart")
        view.tintColor = .systemPink
        view.contentMode = .scaleAspectFit
        return view
    }()
    private let likeCountLabel: UILabel = {
        let view = UILabel()
        view.text = "0"
        view.font = .systemFont(ofSize: 16)
        return view
    }()
    
    private let bottomStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.spacing = .zero
        view.alignment = .center
        return view
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(shadowView)
        
        [thumbnailImageView, 
         titleLabel,
         bottomStackView].forEach {
            backView.addSubview($0)
        }
        
        [commentIconImageView,
         commentCountLabel,
         likeIconImageView,
         likeCountLabel].forEach {
            bottomStackView.addArrangedSubview($0)
        }
        
        contentView.addSubview(backView)
    }
    
    override func configureConstraints() {
        shadowView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        
        backView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        
        thumbnailImageView.snp.makeConstraints { make in
            make.top.equalTo(backView)
            make.horizontalEdges.equalTo(backView)
            make.bottom.equalTo(backView.snp.centerY).offset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(thumbnailImageView.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(backView)
            make.height.equalTo(48)
        }
        
        bottomStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(backView)
            make.bottom.equalTo(backView).offset(-8)
        }
        
        commentIconImageView.snp.makeConstraints { make in
            make.height.equalTo(bottomStackView).inset(4)
        }
        
        commentCountLabel.snp.makeConstraints { make in
            make.height.equalTo(bottomStackView).inset(4)
        }
        
        likeIconImageView.snp.makeConstraints { make in
            make.height.equalTo(bottomStackView).inset(4)
        }
        
        likeCountLabel.snp.makeConstraints { make in
            make.height.equalTo(bottomStackView).inset(4)
        }
    }
    
    override func configureCell() {
        
    }

    func updateCell(post: Post) {
        
        titleLabel.text = post.title
        commentCountLabel.text = String(post.comments.count)
        likeCountLabel.text = String(post.likes.count)
        
        let baseUrl = APIKey.baseURL.rawValue + "/"
        
        if let thumbnailImageString = post.files.first {
            let imageURL = baseUrl + thumbnailImageString
            thumbnailImageView.kf.setImage(with: URL(string: imageURL), placeholder: UIImage(named: "purpleBackground"), options: [.requestModifier(NetworkManager.kingfisherImageRequest)])
        } else {
            thumbnailImageView.image = UIImage(named: "purpleBackground")
        }
    }
}
