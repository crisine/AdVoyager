//
//  OverviewViewController.swift
//  AdVoyager
//
//  Created by Minho on 4/16/24.
//

import UIKit
import SnapKit

final class OverviewViewController: BaseViewController {
    
    private let profileImageView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "person.circle"))
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var mainPostCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return view
    }()
    private let addPostButton: FilledButton = {
        let pencilImage = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32))
        let view = FilledButton(image: pencilImage)
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
        let input = OverviewViewModel.Input(addNewPostButtonTap: addPostButton.rx.tap.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.dataSource
            .drive(mainPostCollectionView.rx.items(cellIdentifier: "cell", cellType: PostCollectionViewCell.self)) { row, element, cell in
                
                cell.updateCell(data: element)
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
        view.addSubview(profileImageView)
        view.addSubview(mainPostCollectionView)
        view.addSubview(addPostButton)
    }
    
    override func configureConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(4)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.size.equalTo(32)
        }
        
        mainPostCollectionView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        addPostButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(32)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-64)
            make.size.equalTo(64)
        }
    }
    
    override func configureView() {
        navigationItem.title = "둘러보기"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2)
        
        return layout
    }
}
