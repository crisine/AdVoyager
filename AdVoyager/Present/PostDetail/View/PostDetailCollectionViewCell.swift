//
//  PostDetailCollectionViewCell.swift
//  AdVoyager
//
//  Created by Minho on 5/1/24.
//

import UIKit
import SnapKit

final class PostDetailCollectionViewCell: BaseCollectionViewCell {
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func configureHierarchy() {
        contentView.addSubview(imageView)
    }
    
    override func configureConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
    }
    
    override func configureCell() {
        
    }
    
    func updateCell(imageUrl: String?) {
        let baseUrl = APIKey.baseURL.rawValue + "/"
        
        if let imageUrl {
            let requestUrl = baseUrl + imageUrl
            imageView.kf.setImage(with: URL(string: requestUrl), placeholder: UIImage(systemName: "photo"), options: [.requestModifier(NetworkManager.kingfisherImageRequest)])
        } else {
            return imageView.image = UIImage(systemName: "photo")
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
