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
        view.layer.borderColor = UIColor.lightpurple.cgColor
        view.layer.borderWidth = 1
        view.tintColor = .lightpurple
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
        let view = FilledButton(title: "프로필 수정")
        return view
    }()
    private let logoutButton: FilledButton = {
        let view = FilledButton(title: "로그아웃", fillColor: .systemRed)
        return view
    }()
    
    private let viewModel = ProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func bind() {
        let input = ProfileViewModel.Input(editProfileButtonTapped: editProfileButton.rx.tap.asObservable(),
                                           logoutButtonTap: logoutButton.rx.tap.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.profileInfo
            .drive(with: self) { owner, profile in
                guard let profile else { return }
                
                let imageURL = APIKey.baseURL.rawValue + "/" + (profile.profileImage ?? "")
                
                owner.profileImageView.kf.setImage(with: URL(string: imageURL), placeholder: UIImage(systemName: "person"), options: [.requestModifier(NetworkManager.kingfisherImageRequest)])
                owner.nickNameLabel.text = profile.nick
                owner.emailLabel.text = profile.email
            }
            .disposed(by: disposeBag)
        
        output.editProfileTrigger
            .drive(with: self) { owner, _ in
                let vc = EditProfileViewController()
                vc.hidesBottomBarWhenPushed = true
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.logoutSuccess
            .drive(with: self) { owner, _ in
                let vc = LoginViewController()
                vc.showToast(message: "로그아웃에 성공했습니다.")
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                owner.present(nav, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [profileImageView, 
         nickNameLabel,
         emailLabel,
         editProfileButton,
         logoutButton].forEach {
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
        
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(editProfileButton.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(64)
            make.height.equalTo(48)
        }
    }
    
    override func configureView() {
        navigationItem.title = "나의 프로필"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        self.isLogoVisible = true
    }
    
}
