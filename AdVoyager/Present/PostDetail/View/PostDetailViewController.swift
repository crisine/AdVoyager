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
    
    private let modifyBarButtonItem: UIBarButtonItem = {
        let view = UIBarButtonItem()
        view.tintColor = .black
        view.image = UIImage(systemName: "ellipsis")
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isScrollEnabled = true
        view.showsVerticalScrollIndicator = true
        view.delegate = self
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
        view.tintColor = .lightpurple
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
    private let createdAtLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13)
        view.textColor = .systemGray
        return view
    }()
    
    private let postSeparatorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()
    private let downloadTravelPlanButton: FilledButton = {
        let view = FilledButton(title: "여행 계획 다운받기")
        return view
    }()
    
    private let commentSeparatorLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
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
    
    private let viewModel = PostDetailViewModel()
    private let viewWillAppearTrigger = PublishRelay<Post>()
    private let modifyPost = PublishSubject<Void>()
    private let deletePost = PublishSubject<Void>()
    private let pushBackedDate = PublishSubject<Date?>()
    private let savePlanTrigger = PublishSubject<Void>()
    let deleteSuccess = PublishRelay<Void>()
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
        
        showCommentButton.rx.tap
            .asObservable()
            .subscribe(with: self) { owner, _ in
                guard let post = owner.post else { return }
                let vc = CommentViewController()
                let nav = UINavigationController(rootViewController: vc)
                vc.comments = post.comments
                vc.postId = post.post_id
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
        
        modifyBarButtonItem.rx.tap
            .asObservable()
            .subscribe(with: self) { owner, _ in
                let actionSheet = UIAlertController(title: "게시글 관리", message: "하고싶은 동작을 선택해주세요", preferredStyle: .actionSheet)
                
                actionSheet.addAction(UIAlertAction(title: "글 수정하기", style: .default, handler: { action in
                    owner.modifyPost.onNext(())
                }))
                
                actionSheet.addAction(UIAlertAction(title: "글 삭제하기", style: .destructive, handler: { action in
                    owner.deletePost.onNext(())
                }))
                
                actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel))
                
                owner.present(actionSheet, animated: true)
            }
            .disposed(by: disposeBag)
        
        downloadTravelPlanButton.rx.tap
            .subscribe(with: self) { owner, _ in
                let vc = PushBackViewController()
                let nav = UINavigationController(rootViewController: vc)
                owner.present(nav, animated: true)
                
                vc.selectedDateStream.subscribe(with: self) { owner, selectedDate in
                    owner.pushBackedDate.onNext(selectedDate)
                    owner.savePlanTrigger.onNext(())
                }
                .disposed(by: vc.disposeBag)
            }
            .disposed(by: disposeBag)
        
        let input = PostDetailViewModel.Input(viewWillAppearTrigger: viewWillAppearTrigger.asObservable(),
                                              modifyPostTrigger: modifyPost.asObservable(),
                                              deletePostTrigger: deletePost.asObservable(),
                                              savePlanTrigger: savePlanTrigger.asObservable(),
                                              pushBackedDate: pushBackedDate.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.dataSource
            .drive(imageCollectionView.rx.items(cellIdentifier: PostDetailCollectionViewCell.identifier, cellType: PostDetailCollectionViewCell.self)) { row, element, cell in
                
                cell.updateCell(imageUrl: element)
            }
            .disposed(by: disposeBag)
        
        output.deletePostSuccess
            .drive(with: self) { owner, _ in
                owner.deleteSuccess.accept(())
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.saveStatus
            .drive(with: self) { owner, saveSuccess in
                if saveSuccess {
                    owner.showToast(message: "여행계획 저장에 성공했습니다.")
                } else {
                    owner.showToast(message: "여행계획 저장에 실패했습니다.")
                }
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        
        [creatorProfileImageView, 
         creatorNicknameLabel,
         profileSeparatorLineView,
         imageCollectionView,
         postTitleLabel,
         postDescriptionTextView,
         createdAtLabel,
         postSeparatorLineView,
         downloadTravelPlanButton,
         commentSeparatorLineView,
         showCommentButton].forEach {
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
            make.horizontalEdges.equalTo(postContentView).inset(16)
//            make.leading.equalTo(postContentView.snp.leading).offset(16)
//            make.trailing.equalTo(postContentView.snp.trailing).inset(16)
        }
        
        createdAtLabel.snp.makeConstraints { make in
            make.top.equalTo(postDescriptionTextView.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(postContentView).inset(16)
        }
        
        postSeparatorLineView.snp.makeConstraints { make in
            make.top.equalTo(createdAtLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(postContentView).inset(16)
            make.height.equalTo(2)
        }
        
        downloadTravelPlanButton.snp.makeConstraints { make in
            make.top.equalTo(postSeparatorLineView.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(postContentView).inset(16)
            make.height.equalTo(48)
        }
        
        commentSeparatorLineView.snp.makeConstraints { make in
            make.top.equalTo(downloadTravelPlanButton.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(postContentView).inset(16)
            make.height.equalTo(2)
        }
        
        showCommentButton.snp.makeConstraints { make in
            make.top.equalTo(commentSeparatorLineView.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(postContentView).inset(16)
            make.height.equalTo(32)
            make.bottom.lessThanOrEqualToSuperview().inset(16)
        }
        
        postContentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(screenWidth)
        }
        
    }
    
    override func configureView() {
        postTitleLabel.text = post?.title?.isEmpty == true ? "제목 없음" : post!.title
        postDescriptionTextView.text = post?.content?.isEmpty == true ? "내용 없음" : post!.content
        creatorNicknameLabel.text = post?.creator.nick
        showCommentButton.setTitle("\(post?.comments.count ?? 0)개의 댓글", for: .normal)
        createdAtLabel.text = post?.createdAt.toDate()?.toString(format: "yyyy-MM-dd HH:mm:ss")
        
        let baseUrl = APIKey.baseURL.rawValue + "/"
        
        if let profileImageUrl = post?.creator.profileImage {
            let requestUrl = baseUrl + profileImageUrl
            creatorProfileImageView.kf.setImage(with: URL(string: requestUrl), placeholder: UIImage(systemName: "photo"), options: [.requestModifier(NetworkManager.kingfisherImageRequest)])
        } else {
            creatorProfileImageView.image = UIImage(systemName: "person.circle")
        }
        
        navigationItem.rightBarButtonItem = modifyBarButtonItem
        
        downloadTravelPlanButton.isEnabled = post?.content1 != nil ? true : false
        downloadTravelPlanButton.backgroundColor = downloadTravelPlanButton.isEnabled ? .lightpurple : .lightGray
    }
                                    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        
        return layout
    }
}

extension PostDetailViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        if (velocity.y > 0) {
            UIView.animate(withDuration: 0.1, delay: 0, options: UIView.AnimationOptions(), animations: {
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                print("Hide")
            }, completion: nil)

        } else {
            UIView.animate(withDuration: 0.1, delay: 0, options: UIView.AnimationOptions(), animations: {
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                print("Unhide")
            }, completion: nil)
        }
   }
}
