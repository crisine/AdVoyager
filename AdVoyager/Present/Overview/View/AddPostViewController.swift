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
        return view
    }()
    private lazy var photoCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.register(AddPhotoCollectionViewCell.self, forCellWithReuseIdentifier: AddPhotoCollectionViewCell.identifier)
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        view.backgroundColor = .systemGray6
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
        item.tintColor = .red
        return item
    }()
    private lazy var addPostBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "작성", style: .done, target: self, action: nil)
        return item
    }()
    
    private let addTravelPlanButton: FilledButton = {
        let view = FilledButton(image: UIImage(systemName: "checklist.unchecked"))
        return view
    }()
    private let addedTravelPlanTitleLabel: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 24)
        return view
    }()
    private let travelPlanBackView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        view.backgroundColor = .systemGray6
        return view
    }()
    
    private let viewModel = AddPostViewModel()
    private let imageStream = PublishSubject<UIImage>()
    private let travelPlan = PublishSubject<TravelPlan>()
    private let finishedAddingImageTrigger = PublishSubject<Void>()
    let postUploadSuccessTrigger = PublishRelay<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func bind() {
        
        let input = AddPostViewModel.Input(titleText: postTitleTextField.rx.text.orEmpty.asObservable(),
                                           contentText: contentTextView.rx.text.orEmpty.asObservable(),
                                           addPostButtonTapTrigger: addPostBarButtonItem.rx.tap.asObservable(),
                                           addTravelPlanButtonTapTrigger: addTravelPlanButton.rx.tap.asObservable(),
                                           cancelPostButtonTapTrigger: cancelPostBarButtonItem.rx.tap.asObservable(),
                                           imageStream: imageStream.asObservable(),
                                           travelPlan: travelPlan.asObservable(),
                                           finishedAddingImageTrigger: finishedAddingImageTrigger.asObservable())
        
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
                owner.postUploadSuccessTrigger.accept(())
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.dataSource
            .drive(photoCollectionView.rx.items(cellIdentifier: AddPhotoCollectionViewCell.identifier, cellType: AddPhotoCollectionViewCell.self)) { row, element, cell in
                cell.photoImageView.image = element
                cell.photoImageView.contentMode = .scaleToFill
            }
            .disposed(by: disposeBag)
        
        output.storedTravelPlan
            .drive(with: self) { owner, travelPlan in
                guard let travelPlan else { return }
                owner.addedTravelPlanTitleLabel.text = travelPlan.planTitle
            }
            .disposed(by: disposeBag)
        
        addPhotoButton.rx.tap
            .asObservable()
            .subscribe(with: self) { owner, _ in
                var configuration = PHPickerConfiguration()
                configuration.filter = .any(of: [.images, .screenshots])
                configuration.selection = .ordered
                
                guard owner.viewModel.dataSource.count != 5 else { return owner.showToast(message: "더 이상 사진을 추가할 수 없습니다.") }
                configuration.selectionLimit = 5 - owner.viewModel.dataSource.count
                
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = self
                
                owner.present(picker, animated: true)
            }
            .disposed(by: disposeBag)
        
        addTravelPlanButton.rx.tap
            .asObservable()
            .subscribe(with: self) { owner, _ in
                let vc = TravelPlanOverviewViewController()
                vc.addPostMode = true
                owner.present(vc, animated: true)
                
                vc.planSelectObservable
                    .subscribe(with: self) { owner, travelPlan in
                        owner.travelPlan.onNext(travelPlan)
                    }
                    .disposed(by: vc.disposeBag)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [addPhotoButton, 
         photoCollectionView,
         postTitleTextField,
         contentTextView,
         addTravelPlanButton,
         travelPlanBackView].forEach {
            view.addSubview($0)
        }
        
        travelPlanBackView.addSubview(addedTravelPlanTitleLabel)
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
        
        travelPlanBackView.snp.makeConstraints { make in
            make.centerY.equalTo(addTravelPlanButton)
            make.leading.equalTo(addTravelPlanButton.snp.trailing).offset(8)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(addTravelPlanButton)
        }
        
        addedTravelPlanTitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        addTravelPlanButton.snp.makeConstraints { make in
            make.top.equalTo(addPhotoButton.snp.bottom).offset(8)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.size.equalTo(64)
        }
        
        postTitleTextField.snp.makeConstraints { make in
            make.top.equalTo(addTravelPlanButton.snp.bottom).offset(8)
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
        
        let group = DispatchGroup()
        
        for index in 0..<results.count {
            let itemProvider = results[index].itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                group.enter()
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    defer { print("\(index)번째 이미지 추가 leave"); group.leave() }
                    
                    if let image = image as? UIImage {
                        DispatchQueue.global().async {
                            print("이미지 스트림으로 이미지 전송")
                            self?.imageStream.onNext(image)
                        }
                    }
                    
                    if let error = error {
                        print("이미지를 불러오는데 문제가 발생했습니다. \(error)")
                    }
                }
            } else {
                showToast(message: "불러올 수 없는 이미지가 포함되어 있습니다.")
                break
            }
        }
        
        group.notify(queue: .global()) {
            group.wait()
            self.finishedAddingImageTrigger.onNext(())
        }
        
        picker.dismiss(animated: true)
    }
}
