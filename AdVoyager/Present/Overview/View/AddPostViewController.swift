//
//  AddPostViewController.swift
//  AdVoyager
//
//  Created by Minho on 4/22/24.
//

import UIKit
import RxSwift
import RxCocoa

final class AddPostViewController: BaseViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func bind() {
        
        let input = AddPostViewModel.Input(titleText: postTitleTextField.rx.text.orEmpty.asObservable(),
                                           contentText: contentTextView.rx.text.orEmpty.asObservable(),
                                           addPostButtonTapTrigger: addPostBarButtonItem.rx.tap.asObservable(),
                                           cancelPostButtonTapTrigger: cancelPostBarButtonItem.rx.tap.asObservable())
        
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
    }
    
    override func configureHierarchy() {
        [postTitleTextField, contentTextView].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureConstraints() {
        postTitleTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(32)
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
    }
}
