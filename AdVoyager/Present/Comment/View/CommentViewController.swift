//
//  CommentViewController.swift
//  AdVoyager
//
//  Created by Minho on 5/1/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

/*
 struct Comment: Decodable {
     let comment_id: String
     let content: String
     let createdAt: String
     let creator: Creator
 }
 
 struct Creator: Decodable {
     let user_id: String
     let nick: String
     let profileImage: String?
 }
 */

final class CommentViewController: BaseViewController {
    
    private let commentTableView: UITableView = {
        let view = UITableView()
        view.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        return view
    }()
    private let commentTextField: SignTextField = {
        let view = SignTextField(placeholderText: "댓글 작성...")
        return view
    }()
    private let addCommentButton: FilledButton = {
        let view = FilledButton(image: UIImage(systemName: "ellipsis.bubble"))
        return view
    }()
    private let commentStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.spacing = 16
        return view
    }()
    
    private let viewWillAppearTrigger = PublishSubject<[Comment]>()
    private let cellModifyButtonTapped = PublishSubject<Int>()
    private let cellDeleteButtonTapped = PublishSubject<Int>()
    var postId: String = ""
    var comments: [Comment] = []
    
    private let viewModel = CommentViewModel()
    
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppearTrigger.onNext(comments)
        viewModel.postId = postId
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func bind() {
        let input = CommentViewModel.Input(viewWillAppearTrigger: viewWillAppearTrigger.asObservable(),
                                           comment: commentTextField.rx.text.orEmpty.asObservable(),
                                           addCommentButtonTap: addCommentButton.rx.tap.asObservable(),
                                           cellModifyButtonTap: cellModifyButtonTapped.asObservable(),
                                           cellDeleteButtonTap: cellDeleteButtonTapped.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.dataSource
            .drive(commentTableView.rx.items(cellIdentifier: CommentTableViewCell.identifier, cellType: CommentTableViewCell.self)) { [weak self] row, element, cell in
                guard let self else { return }
                cell.updateCell(comment: element)
                
                cell.modifyButton.rx.tap
                    .map { row }
                    .subscribe(with: self, onNext: { owner, row in
                        let actionSheet = UIAlertController(title: "댓글 관리", message: "하고싶은 동작을 선택해주세요", preferredStyle: .actionSheet)
                        
                        actionSheet.addAction(UIAlertAction(title: "댓글 수정하기", style: .default, handler: { action in
                            owner.cellModifyButtonTapped.onNext(row)
                        }))
                        actionSheet.addAction(UIAlertAction(title: "댓글 삭제하기", style: .destructive, handler: { action in
                            owner.cellDeleteButtonTapped.onNext(row)
                        }))
                        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel))
                        
                        owner.present(actionSheet, animated: true)
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.refreshCommentTrigger
            .drive(with: self) { owner, _ in
                owner.showToast(message: "댓글 새로고침에 성공했습니다.")
                owner.commentTextField.text = nil
            }
            .disposed(by: disposeBag)
        
        output.deleteCommentSuccess
            .drive(with: self) { owner, _ in
                owner.showToast(message: "댓글을 삭제했습니다.")
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        
        [commentTextField, addCommentButton].forEach {
            commentStackView.addArrangedSubview($0)
        }
        
        [commentTableView, commentStackView].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureConstraints() {
        commentTableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(commentStackView.snp.top).offset(-16)
        }
        
        addCommentButton.snp.makeConstraints { make in
            make.width.equalTo(48)
        }
        
        commentStackView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-32)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(48)
        }
    }
    
    override func configureView() {
        navigationItem.title = "댓글 보기"
    }
}
