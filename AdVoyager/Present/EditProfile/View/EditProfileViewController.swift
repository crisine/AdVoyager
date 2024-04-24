//
//  EditProfileViewController.swift
//  AdVoyager
//
//  Created by Minho on 4/18/24.
//

import UIKit
import PhotosUI
import SnapKit
import RxGesture
import RxSwift
import RxCocoa

final class EditProfileViewController: BaseViewController {

    private let profileImageViewTapGesture = UITapGestureRecognizer()
    
    lazy var profileImageView: UIImageView = {
        let view = UIImageView()
        view.addGestureRecognizer(profileImageViewTapGesture)
        view.clipsToBounds = true
        view.layer.cornerRadius = 64
        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.layer.borderWidth = 1
        view.contentMode = .scaleAspectFill
        return view
    }()
    private let emailTextField: SignTextField = {
        let view = SignTextField(placeholderText: "")
        view.isEnabled = false
        view.backgroundColor = .systemGray4
        return view
    }()
    private let nickTextField: SignTextField = {
        let view = SignTextField(placeholderText: "수정할 닉네임 입력...")
        return view
    }()
    private let phoneNumTextField: NumberTextField = {
        let view = NumberTextField(placeholderText: "수정할 전화번호 입력...")
        
        return view
    }()
    private let birthDayPicker: BirthdayDatePicker = {
        let view = BirthdayDatePicker()
        return view
    }()
    
    private let editProfileButton: FilledButton = {
        let view = FilledButton(title: "회원정보 수정", fillColor: .systemBlue)
        return view
    }()
    
    private let viewModel = EditProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(#function)
    }
    
    override func bind() {
        print(#function)

        let input = EditProfileViewModel.Input(profileImage: profileImageView.rx.observe(UIImage.self, "image"),
                                               nick: nickTextField.rx.text
            .orEmpty.asObservable(), 
                                               phoneNum: phoneNumTextField.rx.text.orEmpty.asObservable(), birthDay: birthDayPicker.rx.date.asObservable(),
                                               profileImageViewTap: profileImageView.rx.tapGesture().asObservable(),
                                               editProfileButtonTap: editProfileButton.rx.tap.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.profileInfo
            .asObservable()
            .subscribe(with: self) { owner, profileInfo in
                guard let profileInfo else { print("profileInfo is nil"); return }
                print("profileInfo: \(profileInfo)")
                
                let imageURL = APIKey.baseURL.rawValue + "/" + (profileInfo.profileImage ?? "")
                
                owner.profileImageView.kf.setImage(with: URL(string: imageURL), options: [.requestModifier(NetworkManager.kingfisherImageRequest)])
                owner.emailTextField.rx.text.onNext(profileInfo.email)
                owner.nickTextField.rx.text.onNext(profileInfo.nick)
                owner.phoneNumTextField.rx.text.onNext(profileInfo.phoneNum)
                
                guard let birthDay = profileInfo.birthDay else {
                    return
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd"
                
                owner.birthDayPicker.rx.date.onNext(dateFormatter.date(from: birthDay)!)
            }
            .disposed(by: disposeBag)
        
        output.editProfileImageTrigger
            .asObservable()
            .subscribe(with: self) { owner, _ in
                var configuration = PHPickerConfiguration()
                configuration.filter = .any(of: [.images])
                
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = self
                
                owner.present(picker, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [profileImageView, emailTextField, nickTextField, phoneNumTextField, birthDayPicker, editProfileButton].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.size.equalTo(128)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(32)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(48)
        }
        
        nickTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(emailTextField)
            make.height.equalTo(emailTextField)
        }
        
        phoneNumTextField.snp.makeConstraints { make in
            make.top.equalTo(nickTextField.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(emailTextField)
            make.height.equalTo(emailTextField)
        }
        
        birthDayPicker.snp.makeConstraints { make in
            make.top.equalTo(phoneNumTextField.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(emailTextField)
            make.height.equalTo(emailTextField)
        }
        
        editProfileButton.snp.makeConstraints { make in
            make.top.equalTo(birthDayPicker.snp.bottom).offset(32)
            make.horizontalEdges.equalTo(emailTextField)
            make.height.equalTo(emailTextField)
        }
    }
    
    override func configureView() {
        
    }
}

extension EditProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        guard let itemprovider = results.first?.itemProvider else { return }
        
        if itemprovider.canLoadObject(ofClass: UIImage.self) {
            itemprovider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                if let image = image as? UIImage {
                    DispatchQueue.main.async {
                        self?.profileImageView.image = image
                    }
                }
            }
        }
    }
}
