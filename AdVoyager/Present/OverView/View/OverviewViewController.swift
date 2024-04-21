//
//  OverviewViewController.swift
//  AdVoyager
//
//  Created by Minho on 4/16/24.
//

import UIKit
import SnapKit

final class OverviewViewController: BaseViewController {
    
    private lazy var mainPostCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return view
    }()
    private let addDummyDataButton: FilledButton = {
        let view = FilledButton(title: "추가", fillColor: .systemBlue)
        view.layer.cornerRadius = 32
        return view
    }()
    
    private let viewModel = OverviewViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
    }
    
    override func bind() {
        print(#function)
        let input = OverviewViewModel.Input(addNewPostButtonTap: addDummyDataButton.rx.tap.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.dataSource
            .drive(mainPostCollectionView.rx.items(cellIdentifier: "cell", cellType: PostCollectionViewCell.self)) { row, element, cell in
                cell.titleLabel.rx.text.onNext(element.content)
                cell.contentLabel.rx.text.onNext(element.content1)
            }
            .disposed(by: disposeBag)
        
        output.addNewPostTrigger
            .drive(with: self) { owner, _ in
                let nav = UINavigationController(rootViewController: AddPostViewController())
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        view.addSubview(mainPostCollectionView)
        view.addSubview(addDummyDataButton)
    }
    
    override func configureConstraints() {
        mainPostCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        addDummyDataButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-32)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(32)
            make.size.equalTo(64)
        }
    }
    
    override func configureView() {
        mainPostCollectionView.backgroundColor = .systemGray5
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 120)
        
        return layout
    }
}
