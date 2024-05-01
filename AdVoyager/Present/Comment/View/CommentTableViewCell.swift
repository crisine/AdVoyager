//
//  CommentTableViewCell.swift
//  AdVoyager
//
//  Created by Minho on 5/1/24.
//

import UIKit
import SnapKit
import RxSwift

/*
 struct Comment: Decodable {
     let comment_id: String
     let content: String
     let createdAt: String
     let creator: Creator
 }
 
 struct Creator: Decodable {
     let user_id: String
     let nick: String
     let profileImage: String?
 }
 */

final class CommentTableViewCell: BaseTableViewCell {
    
    let disposeBag = DisposeBag()
    
    private let creatorProfileImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        view.contentMode = .scaleAspectFill
        view.tintColor = .lightpurple
        return view
    }()
    private let creatorNicknameLabel: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 16)
        view.textColor = .black
        return view
    }()
    let modifyButton: UIButton = {
        let view = UIButton()
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        view.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        view.tintColor = .black
        return view
    }()
    private let commentTextView: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 14)
        view.textColor = .black
        view.isEditable = false
        return view
    }()
    private let createdTimeLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13)
        view.textColor = .systemGray
        return view
    }()
    
    override func configureHierarchy() {
        [creatorProfileImageView,
         creatorNicknameLabel,
         modifyButton,
         commentTextView,
         createdTimeLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func configureConstraints() {
        creatorProfileImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(8)
            make.leading.equalTo(contentView).offset(8)
            make.size.equalTo(32)
        }
        
        creatorNicknameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(creatorProfileImageView.snp.centerY)
            make.leading.equalTo(creatorProfileImageView.snp.trailing).offset(4)
            make.trailing.equalTo(modifyButton.snp.leading).offset(-8)
        }
        
        modifyButton.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(8)
            make.trailing.equalTo(contentView).offset(-8)
            make.size.equalTo(32)
        }
        
        commentTextView.snp.makeConstraints { make in
            make.top.equalTo(creatorProfileImageView.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(contentView).inset(16)
            make.height.greaterThanOrEqualTo(80)
        }
        
        createdTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(commentTextView.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(contentView).inset(16)
            make.bottom.equalTo(contentView).offset(-8)
        }
    }
    
    override func configureCell() {
        selectionStyle = .none
    }

    func updateCell(comment: Comment) {
        
        creatorNicknameLabel.text = comment.creator.nick
        commentTextView.text = comment.content
        createdTimeLabel.text = comment.createdAt.toDate()?.toString(format: "yyyy.MM.dd. HH:mm")
        
        let baseUrl = APIKey.baseURL.rawValue + "/"
        
        if let profileImageUrl = comment.creator.profileImage {
            let requestUrl = baseUrl + profileImageUrl
            creatorProfileImageView.kf.setImage(with: URL(string: requestUrl), placeholder: UIImage(systemName: "photo"), options: [.requestModifier(NetworkManager.kingfisherImageRequest)])
        } else {
            creatorProfileImageView.image = UIImage(systemName: "person.circle")
        }
    }
}
