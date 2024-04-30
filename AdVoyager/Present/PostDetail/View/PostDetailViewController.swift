//
//  PostDetailViewController.swift
//  AdVoyager
//
//  Created by Minho on 5/1/24.
//

import UIKit
import RxSwift
import RxCocoa

final class PostDetailViewController: BaseViewController {
    
    private lazy var imageCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.register(PostDetailCollectionViewCell.self, forCellWithReuseIdentifier: PostDetailCollectionViewCell.identifier)
        view.isPagingEnabled = true
        view.indicatorStyle = .default
        view.tintColor = .lightpurple
        view.flashScrollIndicators()
        view.backgroundColor = .systemGray6
        return view
    }()
    private let creatorProfileImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()
    private let creatorNicknameLabel: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 18)
        return view
    }()
    private let separatorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()
    private let postTitleLabel: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 24)
        return view
    }()
    private let postDescriptionTextView: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 16)
        view.isEditable = false
        return view
    }()
    
    private let viewModel = PostDetailViewModel()
    private let viewWillAppearTrigger = PublishRelay<Post>()
    var post: Post?
    
    override func viewWillAppear(_ animated: Bool) {
        guard let post else { return }
        viewWillAppearTrigger.accept(post)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func bind() {
        
        let input = PostDetailViewModel.Input(viewWillAppearTrigger: viewWillAppearTrigger.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.dataSource
            .drive(imageCollectionView.rx.items(cellIdentifier: PostDetailCollectionViewCell.identifier, cellType: PostDetailCollectionViewCell.self)) { row, element, cell in
                
                cell.updateCell(imageUrl: element)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [creatorProfileImageView, creatorNicknameLabel, separatorLineView, imageCollectionView, postTitleLabel, postDescriptionTextView].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureConstraints() {
        imageCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(UIScreen.main.bounds.width)
        }
        
        creatorProfileImageView.snp.makeConstraints { make in
            make.top.equalTo(imageCollectionView.snp.bottom).offset(16)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.size.equalTo(32)
        }
        
        creatorNicknameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(creatorProfileImageView.snp.centerY)
            make.leading.equalTo(creatorProfileImageView.snp.trailing).offset(4)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        separatorLineView.snp.makeConstraints { make in
            make.top.equalTo(creatorProfileImageView.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(2)
        }
        
        postTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorLineView.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        postDescriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(postTitleLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.lessThanOrEqualTo(360)
        }
    }
    
    override func configureView() {
        postTitleLabel.text = post?.title
        postDescriptionTextView.text = post?.content
        creatorNicknameLabel.text = post?.creator.nick
        
        let baseUrl = APIKey.baseURL.rawValue + "/"
        
        if let profileImageUrl = post?.creator.profileImage {
            let requestUrl = baseUrl + profileImageUrl
            creatorProfileImageView.kf.setImage(with: URL(string: requestUrl), placeholder: UIImage(systemName: "photo"), options: [.requestModifier(NetworkManager.kingfisherImageRequest)])
        } else {
            return creatorProfileImageView.image = UIImage(systemName: "photo")
        }
    }
                                    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        
        return layout
    }
}
