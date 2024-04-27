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
        view.text = "제목"
        return view
    }()
    let likeButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "heart"), for: .normal)
        view.tintColor = .systemPink
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 24
        return view
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
    }
    
    func configureHierarchy() {
        contentView.addSubview(backView)
        
        [titleImageView, likeButton, titleLabel, addressLabel].forEach {
            backView.addSubview($0)
        }
    }
    
    func configureConstraints() {
        
        backView.snp.makeConstraints { make in
            make.edges.equalTo(contentView.safeAreaLayoutGuide).inset(16)
        }
        
        titleImageView.snp.makeConstraints { make in
            make.top.equalTo(backView.snp.top).offset(16)
            make.horizontalEdges.equalTo(backView).inset(16)
            make.height.equalTo(300)
        }
        
        likeButton.snp.makeConstraints { make in
            make.bottom.equalTo(titleImageView).inset(16)
            make.trailing.equalTo(titleImageView).inset(16)
            make.size.equalTo(48)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleImageView.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(titleImageView)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(titleImageView)
            make.bottom.equalTo(backView).offset(-16)
        }
    }
    
    override func prepareForReuse() {
        titleImageView.image = nil
        titleLabel.text = ""
        addressLabel.text = ""
    }
    
    func updateCell(data: Post) {
        
        titleLabel.text = data.title
        addressLabel.text = data.content
        
        guard let thumbnailImageString = data.files.first else {
            return
        }
        
        let imageURL = APIKey.baseURL.rawValue + "/" + thumbnailImageString
         
        // TODO: placeholder를 사용하도록 바꾸면, 이미지 크기를 Snapkit에서 잡아둔 크기를 무시하고 잡힘. 이를 방지하기 위해서 snapkit height를 고정적으로 만들어주었음. 좋은 해결방안이 나올지 고려.
        titleImageView.kf.setImage(with: URL(string: imageURL), placeholder: UIImage(systemName: "photo"))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
