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

final class SearchResultViewController: BaseViewController {
    
    private lazy var mainPostCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
        return view
    }()
    
    private let renderingRowPosition = PublishRelay<Int>()
    private let viewDidLoadTrigger = PublishRelay<Void>()
    private let refreshTrigger = PublishRelay<Void>()
    
    var query: String = ""
    
    private let viewModel = SearchResultViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewDidLoadTrigger.accept(())
    }
    
    override func bind() {
        let input = SearchResultViewModel.Input(
            viewDidLoadTrigger: viewDidLoadTrigger.asObservable(),
            query: Observable.just(query),
            refreshTrigger: refreshTrigger.asObservable(),
            renderingRowPosition: renderingRowPosition.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.dataSource
            .drive(mainPostCollectionView.rx.items(cellIdentifier: PostCollectionViewCell.identifier, cellType: PostCollectionViewCell.self)) { [weak self] row, element, cell in
                
                self?.renderingRowPosition.accept(row)
                cell.updateCell(data: element)
            }
            .disposed(by: disposeBag)
        
        mainPostCollectionView.rx.modelSelected(Post.self)
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
        [mainPostCollectionView].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureConstraints() {
        
        mainPostCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
    
    override func configureView() {
        navigationItem.title = "\(query) 검색 결과"
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backItem?.titleView?.tintColor = .white
        self.isLogoVisible = false
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
