//
//  AddPostViewController.swift
//  AdVoyager
//
//  Created by Minho on 4/22/24.
//

import UIKit
import RxSwift
import RxCocoa
import PhotosUI

final class AddPostViewController: BaseViewController {
    
    private let addPhotoButton: FilledButton = {
        let view = FilledButton()
        view.layer.borderColor = UIColor.darkPurple.cgColor
        view.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        view.setTitle("0/5", for: .normal)
        return view
    }()
    private lazy var photoCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.register(AddPhotoCollectionViewCell.self, forCellWithReuseIdentifier: AddPhotoCollectionViewCell.identifier)
        return view
    }()
    private lazy var postTitleTextField: SignTextField = {
        let view = SignTextField(placeholderText: "제목 입력...")
        view.textAlignment = .left
        view.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: view.frame.height))
        view.leftViewMode = .always
        return view
    }()
    private let contentTextView: ContentTextView = {
        let view = ContentTextView(placeholderText: "내용 입력...")
        return view
    }()
    
    private lazy var cancelPostBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "취소", style: .plain, target: self, action: nil)
        return item
    }()
    private lazy var addPostBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "작성", style: .done, target: self, action: nil)
        return item
    }()
    
    private let viewModel = AddPostViewModel()
    private let imageStream = PublishSubject<UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func bind() {
        
        let input = AddPostViewModel.Input(titleText: postTitleTextField.rx.text.orEmpty.asObservable(),
                                           contentText: contentTextView.rx.text.orEmpty.asObservable(),
                                           addPostButtonTapTrigger: addPostBarButtonItem.rx.tap.asObservable(),
                                           cancelPostButtonTapTrigger: cancelPostBarButtonItem.rx.tap.asObservable(),
                                           imageStream: imageStream.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.canelPostUploadTrigger
            .asObservable()
            .subscribe(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.postValidation
            .asObservable()
            .bind(with: self) { owner, isEnabled in
                owner.addPostBarButtonItem.isEnabled = isEnabled
            }
            .disposed(by: disposeBag)
        
        output.postUploadSuccessTrigger
            .asObservable()
            .subscribe(with: self) { owner, _ in
                // dismiss + 성공 trigger를 completeHandler로 다른 view로 전송
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.dataSource
            .drive(photoCollectionView.rx.items(cellIdentifier: AddPhotoCollectionViewCell.identifier, cellType: AddPhotoCollectionViewCell.self)) { row, element, cell in
                cell.photoImageView.image = element
                cell.photoImageView.contentMode = .scaleToFill
            }
            .disposed(by: disposeBag)
        
        addPhotoButton.rx.tap
            .asObservable()
            .subscribe(with: self) { owner, _ in
                var configuration = PHPickerConfiguration()
                configuration.filter = .any(of: [.images, .screenshots])
                configuration.selection = .ordered
                configuration.selectionLimit = 5
                
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = self
                
                owner.present(picker, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [addPhotoButton, photoCollectionView, postTitleTextField, contentTextView].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureConstraints() {
        
        addPhotoButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.size.equalTo(64)
        }
        
        photoCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalTo(addPhotoButton.snp.trailing).offset(8)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(addPhotoButton)
        }
        
        postTitleTextField.snp.makeConstraints { make in
            make.top.equalTo(addPhotoButton.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(48)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(postTitleTextField.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(postTitleTextField.snp.horizontalEdges)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-8)
        }
    }
    
    override func configureView() {
        self.navigationItem.leftBarButtonItem = cancelPostBarButtonItem
        self.navigationItem.rightBarButtonItem = addPostBarButtonItem
        
        navigationItem.title = "새 포스트 작성하기"
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 64, height: 64)
        
        return layout
    }
}

extension AddPostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        results.forEach { result in
                        let itemProvider = result.itemProvider
                        if itemProvider.canLoadObject(ofClass: UIImage.self) {
                            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                                if let image = image as? UIImage {
                                    self?.imageStream.onNext(image)
                                }
                                if let error = error {
                                    print("이미지가 너무 커서 찐빠가 났다!")
                                }
                            }
                        }
                    }
        picker.dismiss(animated: true)
    }
}
