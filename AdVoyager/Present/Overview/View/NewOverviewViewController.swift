//
//  NewOverviewViewController.swift
//  AdVoyager
//
//  Created by Minho on 5/3/24.
//

import SwiftUI
import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class NewOverviewViewController: BaseViewController {
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isScrollEnabled = true
        view.showsVerticalScrollIndicator = true
        
        let refreshControl = UIRefreshControl()
        view.refreshControl = refreshControl
        view.refreshControl?.endRefreshing()
        view.refreshControl?.tintColor = .lightpurple
        return view
    }()
    private let postContentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let searchBackgroundImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .lavender
        return view
    }()
    private let profileImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 24
        view.tintColor = .lightpurple
        view.contentMode = .scaleAspectFit
        
        view.layer.borderColor = UIColor.lightpurple.cgColor
        view.layer.borderWidth = 2
        
        // 임시 이미지
        view.image = UIImage(systemName: "person")
        return view
    }()
    private let welcomeLabel: UILabel = {
        let view = UILabel()
        view.text = "안녕하세요! 사용자님"
        view.font = .systemFont(ofSize: 28, weight: .heavy)
        return view
    }()
    private let welcomeSubtitleLabel: UILabel = {
        let view = UILabel()
        view.text = "오늘도 많은 여행 코스가 공유되고 있어요!"
        view.font = .systemFont(ofSize: 16)
        view.textColor = .white
        return view
    }()
    private let searchBar: UISearchBar = {
        let view = UISearchBar()
        view.searchBarStyle = .minimal
        view.searchTextField.clearButtonMode = .whileEditing
        view.tintColor = .lightpurple
        view.placeholder = "이번엔 어디로 떠나볼까요?"
        view.setImage(UIImage(systemName: "airplane.departure"), for: .search, state: .normal)
        
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightpurple.cgColor
        view.backgroundImage = UIImage()
        view.backgroundColor = .systemGray6
        
        view.searchTextField.backgroundColor = .white
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowRadius = 5
        view.layer.cornerRadius = 16

        return view
    }()
    
    // MARK: 중간 부분
    private let newPlansTitleLabel: UILabel = {
        let view = UILabel()
        view.text = "🌏 새로운 여행 코스 둘러보기"
        view.font = .boldSystemFont(ofSize: 22)
        return view
    }()
    private lazy var newPlansCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.register(PlanCollectionViewCell.self, forCellWithReuseIdentifier: PlanCollectionViewCell.identifier)
        return view
    }()
    
    // MARK: 하단 부분
    private let hashtagPlansTitleLabel: UILabel = {
        let view = UILabel()
        view.text = "#️⃣ 대한민국🇰🇷 둘러보기"
        view.font = .boldSystemFont(ofSize: 22)
        return view
    }()
    private lazy var hashtagPlanCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.register(PlanCollectionViewCell.self, forCellWithReuseIdentifier: PlanCollectionViewCell.identifier)
        
        return view
    }()
    private let addPostButton: FilledButton = {
        let pencilImage = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32))
        let view = FilledButton(image: pencilImage)
        view.layer.cornerRadius = 32
        return view
    }()
    
    // MARK: ViewModel, RxSwift
    private let viewModel = OverviewViewModel()
    private let renderingRowPosition = PublishRelay<Int>()
    private let viewDidLoadTrigger = PublishRelay<Void>()
    private let refreshTrigger = PublishRelay<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadTrigger.accept(())
    }
    
    override func bind() {
        let input = OverviewViewModel.Input(viewDidLoadTrigger: viewDidLoadTrigger.asObservable(),
                                            searchText: searchBar.rx.text.orEmpty.asObservable(),
                                            searchButtonTap: searchBar.rx.searchButtonClicked.asObservable(),
                                            addNewPostButtonTap: addPostButton.rx.tap.asObservable(),
                                            renderingRowPosition: renderingRowPosition.asObservable(),
                                            refreshLoading: scrollView.refreshControl!.rx.controlEvent(.valueChanged).asObservable(),
                                            refreshTrigger: refreshTrigger.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.searchText
            .drive(with: self) { owner, query in
                let vc = SearchResultViewController()
                vc.query = query
                vc.hidesBottomBarWhenPushed = true
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.normalDataSource
            .drive(newPlansCollectionView.rx.items(cellIdentifier: PlanCollectionViewCell.identifier, cellType: PlanCollectionViewCell.self)) { [weak self] row, element, cell in
                
                self?.renderingRowPosition.accept(row)
                cell.updateCell(post: element)
            }
            .disposed(by: disposeBag)
        
        output.hashtagDataSource
            .drive(hashtagPlanCollectionView.rx.items(cellIdentifier: PlanCollectionViewCell.identifier, cellType: PlanCollectionViewCell.self)) { row, element, cell in
                // TODO: 위의 다른 컬렉션뷰에서 보이는 renderingRowPosition을 다른 이름으로 얘도 갖고 있어야 함
                cell.updateCell(post: element)
            }
            .disposed(by: disposeBag)
        
        output.profile
            .drive(with: self) { owner, profile in
                guard let profile else {
                    return
                }
                
                let baseUrl = APIKey.baseURL.rawValue + "/"
                let url = URL(string: baseUrl + (profile.profileImage ?? ""))
                owner.profileImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "person"), options: [.requestModifier(NetworkManager.kingfisherImageRequest)])
                
                owner.welcomeLabel.text = "안녕하세요! \(profile.nick)님"
            }
            .disposed(by: disposeBag)
        
        output.addNewPostTrigger
            .drive(with: self) { owner, _ in
                let vc = AddPostViewController()
                let nav = UINavigationController(rootViewController: vc)
                owner.present(nav, animated: true)
                
                vc.postUploadSuccessTrigger
                    .subscribe(with: self) { owner, _ in
                        owner.refreshTrigger.accept(())
                        owner.showToast(message: "게시글 작성에 성공했습니다.")
                    }
                    .disposed(by: vc.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.isRefreshing
            .drive(with: self) { owner, isRefreshing in
                if isRefreshing == false {
                    owner.scrollView.refreshControl?.endRefreshing()
                    print("리프레시 종료")
                } else {
                    owner.scrollView.refreshControl?.beginRefreshing()
                    print("리프레시 시작")
                }
            }
            .disposed(by: disposeBag)
        
        newPlansCollectionView.rx.modelSelected(Post.self)
            .asObservable()
            .subscribe(with: self) { owner, selectedPost in
                let vc = PostDetailViewController()
                vc.post = selectedPost
                vc.hidesBottomBarWhenPushed = true
                owner.navigationController?.pushViewController(vc, animated: true)
                
                vc.deleteSuccess
                    .subscribe { _ in
                        owner.refreshTrigger.accept(())
                        owner.showToast(message: "포스트가 삭제되었습니다.")
                    }
                    .disposed(by: vc.disposeBag)
            }
            .disposed(by: disposeBag)
        
        hashtagPlanCollectionView.rx.modelSelected(Post.self)
            .asObservable()
            .subscribe(with: self) { owner, selectedPost in
                let vc = PostDetailViewController()
                vc.post = selectedPost
                vc.hidesBottomBarWhenPushed = true
                owner.navigationController?.pushViewController(vc, animated: true)
                
                vc.deleteSuccess
                    .subscribe { _ in
                        owner.refreshTrigger.accept(())
                        owner.showToast(message: "포스트가 삭제되었습니다.")
                    }
                    .disposed(by: vc.disposeBag)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [searchBackgroundImageView,
         searchBar,
         welcomeLabel,
         welcomeSubtitleLabel,
         profileImageView,
         newPlansTitleLabel,
         newPlansCollectionView,
         hashtagPlansTitleLabel,
         hashtagPlanCollectionView,
         addPostButton].forEach {
            scrollView.addSubview($0)
        }
        
        view.addSubview(scrollView)
    }
    
    override func configureConstraints() {
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        searchBackgroundImageView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top).offset(-160)
            make.horizontalEdges.equalTo(scrollView.safeAreaLayoutGuide)
            make.bottom.equalTo(searchBar.snp.centerY)
        }
        
        welcomeLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView.safeAreaLayoutGuide).offset(16)
            make.leading.equalTo(scrollView.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(profileImageView.snp.leading).offset(8)
        }
        
        welcomeSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(welcomeLabel.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(welcomeLabel.snp.horizontalEdges)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.safeAreaLayoutGuide).offset(24)
            make.trailing.equalTo(scrollView.safeAreaLayoutGuide).offset(-16)
            make.size.equalTo(48)
        }
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(welcomeSubtitleLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(scrollView.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(48)
        }
        
        newPlansTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(32)
            make.horizontalEdges.equalTo(scrollView).inset(16)
        }
        
        newPlansCollectionView.snp.makeConstraints { make in
            make.top.equalTo(newPlansTitleLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(scrollView.safeAreaLayoutGuide)
            make.height.equalTo(UIScreen.main.bounds.height / 3.5)
        }
        
        hashtagPlansTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(newPlansCollectionView.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(scrollView).inset(16)
        }
        
        hashtagPlanCollectionView.snp.makeConstraints { make in
            make.top.equalTo(hashtagPlansTitleLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(newPlansCollectionView.snp.horizontalEdges)
            make.height.equalTo(UIScreen.main.bounds.height / 3.5)
        }
        
        addPostButton.snp.makeConstraints { make in
            make.trailing.equalTo(scrollView.safeAreaLayoutGuide).inset(32)
            make.bottom.equalTo(scrollView.safeAreaLayoutGuide).offset(-64)
            make.size.equalTo(64)
        }
    }
    
    override func configureView() {
        let logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 44))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = UIImage(named: "navTitleLogo")
        navigationItem.titleView = logoImageView
        
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = .clear
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 2.5, height: UIScreen.main.bounds.height / 4)
        
        return layout
    }
}

struct MyViewController_PreViews: PreviewProvider {
    static var previews: some View {
//        UINavigationController(rootViewController:NewOverviewViewController()).toPreview()
        NewOverviewViewController().toPreview()
    }
}
