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
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isScrollEnabled = true
        view.showsVerticalScrollIndicator = true
        return view
    }()
    private let postContentView: UIView = {
        let view = UIView()
        return view
    }()
    private lazy var imageCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.register(PostDetailCollectionViewCell.self, forCellWithReuseIdentifier: PostDetailCollectionViewCell.identifier)
        view.isPagingEnabled = true
        view.indicatorStyle = .default
        view.tintColor = .lightpurple
        view.flashScrollIndicators()
        view.backgroundColor = .systemGray6
        view.contentMode = .scaleAspectFill
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
    private let profileSeparatorLineView: UIView = {
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
        view.isScrollEnabled = false
        return view
    }()
    private let showCommentButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        view.tintColor = .black
        view.setTitleColor(.black, for: .normal)
        view.contentHorizontalAlignment = .trailing
        return view
    }()
    private let commentSeparatorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let contentHeight = postDescriptionTextView.frame.maxY + 16
        postContentView.frame.size.height = contentHeight
    }
    
    override func bind() {
        
        let input = PostDetailViewModel.Input(viewWillAppearTrigger: viewWillAppearTrigger.asObservable(),
                                              showCommentButtonTrigger: showCommentButton.rx.tap.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.dataSource
            .drive(imageCollectionView.rx.items(cellIdentifier: PostDetailCollectionViewCell.identifier, cellType: PostDetailCollectionViewCell.self)) { row, element, cell in
                
                cell.updateCell(imageUrl: element)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        
        [creatorProfileImageView, creatorNicknameLabel, profileSeparatorLineView, imageCollectionView, postTitleLabel, postDescriptionTextView, commentSeparatorLineView, showCommentButton].forEach {
            postContentView.addSubview($0)
        }
        
        scrollView.addSubview(postContentView)
        view.addSubview(scrollView)
    }
    
    override func configureConstraints() {
        let screenWidth = UIScreen.main.bounds.width
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageCollectionView.snp.makeConstraints { make in
            make.top.equalTo(postContentView.safeAreaLayoutGuide)
            make.width.equalTo(screenWidth)
            make.height.equalTo(screenWidth)
        }
        
        creatorProfileImageView.snp.makeConstraints { make in
            make.top.equalTo(imageCollectionView.snp.bottom).offset(16)
            make.leading.equalTo(postContentView.safeAreaLayoutGuide).offset(16)
            make.size.equalTo(32)
        }
        
        creatorNicknameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(creatorProfileImageView.snp.centerY)
            make.leading.equalTo(creatorProfileImageView.snp.trailing).offset(8)
            make.width.lessThanOrEqualTo(screenWidth - creatorProfileImageView.fs_width)
            make.height.equalTo(creatorProfileImageView.snp.height)
        }
        
        profileSeparatorLineView.snp.makeConstraints { make in
            make.top.equalTo(creatorProfileImageView.snp.bottom).offset(16)
            make.leading.equalTo(postContentView.snp.leading).offset(16)
            make.width.equalTo(screenWidth - 32)
            make.height.equalTo(2)
        }
        
        postTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(profileSeparatorLineView.snp.bottom).offset(16)
            make.leading.equalTo(postContentView.snp.leading).offset(16)
            make.width.equalTo(screenWidth - 32)
            make.height.equalTo(28)
        }
        
        postDescriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(postTitleLabel.snp.bottom).offset(8)
            make.leading.equalTo(postContentView.snp.leading).offset(16)
            make.trailing.equalTo(postContentView.snp.trailing).inset(16)
        }
        
        commentSeparatorLineView.snp.makeConstraints { make in
            make.top.equalTo(postDescriptionTextView.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(postContentView.snp.horizontalEdges).inset(16)
            make.height.equalTo(2)
        }
        
        showCommentButton.snp.makeConstraints { make in
            make.top.equalTo(commentSeparatorLineView.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(postContentView.snp.horizontalEdges).inset(16)
            make.height.equalTo(32)
            make.bottom.lessThanOrEqualToSuperview().inset(16)
        }
        
        postContentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(screenWidth)
        }
        
    }
    
    override func configureView() {
        postTitleLabel.text = post?.title
        postDescriptionTextView.text = post?.content
        creatorNicknameLabel.text = post?.creator.nick
        showCommentButton.setTitle("\(post?.comments.count ?? 0)개의 댓글", for: .normal)
        
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
