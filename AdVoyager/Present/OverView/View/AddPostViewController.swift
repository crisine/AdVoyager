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
    private let contentTitleTextField: ContentTextView = {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func bind() {
        
        cancelPostBarButtonItem.rx.tap
            .asObservable()
            .subscribe(with: self) { owner, _ in
                print("cancelPostButton 눌림")
            }
            .disposed(by: disposeBag)
        
        addPostBarButtonItem.rx.tap
            .asObservable()
            .subscribe(with: self) { owner, _ in
                print("addPostButton 눌림")
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [postTitleTextField, contentTitleTextField].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureConstraints() {
        postTitleTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(32)
        }
        
        contentTitleTextField.snp.makeConstraints { make in
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
