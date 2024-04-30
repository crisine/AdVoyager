//
//  PostCollectionViewCell.swift
//  AdVoyager
//
//  Created by Minho on 4/20/24.
//

import UIKit

class PostCollectionViewCell: BaseCollectionViewCell {
    
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
        view.tintColor = .systemGray4
        return view
    }()
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 24)
        view.text = "제목"
        return view
    }()
    let likeLabel: UILabel = {
        let view = UILabel()
        
        return view
    }()
    let addressLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16)
        return view
    }()
    let profileImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        view.contentMode = .scaleAspectFill
        view.tintColor = .lightpurple
        return view
    }()
    let creatorNameLabel: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 16)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureHierarchy()
        configureConstraints()
    }
    
    override func configureHierarchy() {
        contentView.addSubview(backView)
        
        [titleImageView,
         titleLabel,
         addressLabel,
         profileImageView,
         creatorNameLabel].forEach {
            backView.addSubview($0)
        }
    }
    
    override func configureConstraints() {
        
        backView.snp.makeConstraints { make in
            make.edges.equalTo(contentView.safeAreaLayoutGuide).inset(16)
        }
        
        titleImageView.snp.makeConstraints { make in
            make.trailing.equalTo(backView).inset(4)
            make.width.equalTo(120)
            make.verticalEdges.equalTo(backView).inset(4)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(backView.snp.top).offset(16)
            make.leading.equalTo(backView.snp.leading).offset(16)
            make.trailing.equalTo(titleImageView.snp.leading).offset(-16)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(backView.snp.leading).offset(16)
            make.trailing.equalTo(titleImageView.snp.leading).offset(-16)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.leading.equalTo(backView.snp.leading).offset(16)
            make.bottom.equalTo(backView.snp.bottom).offset(-16)
            make.size.equalTo(32)
        }
        
        creatorNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(4)
            make.trailing.equalTo(titleImageView.snp.leading).offset(-16)
            make.centerY.equalTo(profileImageView.snp.centerY)
        }
    }
    
    override func prepareForReuse() {
        titleImageView.image = nil
        profileImageView.image = nil
        titleLabel.text = nil
        addressLabel.text = nil
        creatorNameLabel.text = nil
    }
    
    func updateCell(data: Post) {
        
        titleLabel.text = data.title
        addressLabel.text = data.content
        creatorNameLabel.text = data.creator.nick
        
        let baseUrl = APIKey.baseURL.rawValue + "/"
        
        if let thumbnailImageString = data.files.first {
            let imageURL = baseUrl + thumbnailImageString
            titleImageView.kf.setImage(with: URL(string: imageURL), placeholder: UIImage(systemName: "photo"), options: [.requestModifier(NetworkManager.kingfisherImageRequest)])
        } else {
            return titleImageView.image = UIImage(systemName: "photo")
        }
        
        if let profileImageString = data.creator.profileImage {
            let imageURL = baseUrl + profileImageString
            profileImageView.kf.setImage(with: URL(string: imageURL), placeholder: UIImage(systemName: "person.circle"), options: [.requestModifier(NetworkManager.kingfisherImageRequest)])
        } else {
            return profileImageView.image = UIImage(systemName: "person.circle")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
