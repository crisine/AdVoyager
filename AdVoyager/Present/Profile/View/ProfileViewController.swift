//
//  ProfileViewController.swift
//  AdVoyager
//
//  Created by Minho on 4/16/24.
//

import UIKit
import Kingfisher

final class ProfileViewController: BaseViewController {
    
    private let profileImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 64
        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.layer.borderWidth = 1
        view.contentMode = .scaleAspectFill
        return view
    }()
    private let nickNameLabel: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 24)
        view.textColor = .text
        view.textAlignment = .center
        return view
    }()
    private let emailLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16)
        view.textColor = .text
        view.textAlignment = .center
        return view
    }()
    private let editProfileButton: FilledButton = {
        let view = FilledButton(title: "프로필 수정", fillColor: .systemBlue)
        view.layer.cornerRadius = 24
        return view
    }()
    
    private let viewModel = ProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func bind() {
        let input = ProfileViewModel.Input(editProfileButtonTapped: editProfileButton.rx.tap.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.profileInfo
            .asObservable()
            .subscribe(with: self) { owner, profile in
                guard let profile else { return }
                owner.profileImageView.kf.setImage(with: URL(string: profile.profileImage ?? ""), placeholder: UIImage(systemName: "person"))
                owner.nickNameLabel.text = profile.nick
                owner.emailLabel.text = profile.email
            }
            .disposed(by: disposeBag)
        
        output.editProfileTrigger.asObservable()
            .subscribe(with: self) { owner, _ in
                let vc = 
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [profileImageView, nickNameLabel, emailLabel, editProfileButton].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.size.equalTo(128)
        }
        
        nickNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(32)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nickNameLabel.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(32)
        }
        
        editProfileButton.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(32)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(64)
            make.height.equalTo(48)
        }
    }
    
    override func configureView() {
        
    }
    
}
