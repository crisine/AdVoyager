//
//  OverviewViewController.swift
//  AdVoyager
//
//  Created by Minho on 4/16/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class OverviewViewController: BaseViewController {
    
    private lazy var mainPostCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
        view.refreshControl = UIRefreshControl()
        view.refreshControl?.endRefreshing()
        view.refreshControl?.tintColor = .lightpurple
        view.backgroundView = UIImageView(image: UIImage(named: "purpleBackground"))
        return view
    }()
    private let addPostButton: FilledButton = {
        let pencilImage = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32))
        let view = FilledButton(image: pencilImage)
        view.layer.cornerRadius = 32
        return view
    }()
    
    private let viewModel = OverviewViewModel()
    private let renderingRowPosition = PublishRelay<Int>()
    private let viewDidLoadTrigger = PublishRelay<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewDidLoadTrigger.accept(())
    }
    
    override func bind() {
        let input = OverviewViewModel.Input(viewDidLoadTrigger: viewDidLoadTrigger.asObservable(),
                                            addNewPostButtonTap: addPostButton.rx.tap.asObservable(),
                                            renderingRowPosition: renderingRowPosition.asObservable(),
                                            refreshLoading:  mainPostCollectionView.refreshControl!.rx.controlEvent(.valueChanged).asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.dataSource
            .drive(mainPostCollectionView.rx.items(cellIdentifier: PostCollectionViewCell.identifier, cellType: PostCollectionViewCell.self)) { [weak self] row, element, cell in
                
                self?.renderingRowPosition.accept(row)
                cell.updateCell(data: element)
            }
            .disposed(by: disposeBag)
        
        output.addNewPostTrigger
            .drive(with: self) { owner, _ in
                let nav = UINavigationController(rootViewController: AddPostViewController())
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.isRefreshing
            .drive(with: self) { owner, isRefreshing in
                if isRefreshing == false {
                    owner.mainPostCollectionView.refreshControl?.endRefreshing()
                    print("리프레시 종료")
                } else {
                    owner.mainPostCollectionView.refreshControl?.beginRefreshing()
                    print("리프레시 시작")
                }
            }
            .disposed(by: disposeBag)
        
        mainPostCollectionView.rx.modelSelected(Post.self)
            .asObservable()
            .subscribe(with: self) { owner, selectedPost in
                let vc = PostDetailViewController()
                vc.post = selectedPost
                vc.hidesBottomBarWhenPushed = true
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [mainPostCollectionView, addPostButton].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureConstraints() {
        
        mainPostCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        addPostButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(32)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-64)
            make.size.equalTo(64)
        }
    }
    
    override func configureView() {
        // TODO: LargeContent 와 RefreshControl을 동시에 사용하면 깜빡임 문제가 생김
//        navigationItem.title = "둘러보기"
//        navigationController?.navigationBar.prefersLargeTitles = true
        
        self.isLogoVisible = true
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 5)
        
        return layout
    }
}
