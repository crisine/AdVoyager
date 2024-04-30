//
//  SignUpViewController.swift
//  AdVoyager
//
//  Created by Minho on 4/16/24.
//

import UIKit
import SnapKit

final class SignUpViewController: BaseViewController  {
    
    private let emailTextField: SignTextField = {
        let view = SignTextField(placeholderText: "이메일 입력...")
        return view
    }()
    
    private let passwordTextField: SignTextField = {
        let view = SignTextField(placeholderText: "비밀번호 입력...", isSecured: true)
        return view
    }()
    
    private let nicknameTextField: SignTextField = {
        let view = SignTextField(placeholderText: "닉네임 입력...")
        return view
    }()
    
    private let phoneNumTextField: NumberTextField = {
        let view = NumberTextField(placeholderText: "010-0000-0000")
        return view
    }()
    
    private let birthdayDatePickerTitle: UILabel = {
        let view = UILabel()
        view.text = "생년월일 입력"
        view.font = .boldSystemFont(ofSize: 32)
        return view
    }()
    
    private let birthdayDatePicker: BirthdayDatePicker = {
        let view = BirthdayDatePicker()
        return view
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillProportionally
        return view
    }()
    
    private let signUpButton: FilledButton = {
        let view = FilledButton(title: "회원가입", fillColor: .lightpurple)
        return view
    }()
    
    private let viewModel = SignUpViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func bind() {
        let input = SignUpViewModel.Input(emailText: emailTextField.rx.text.orEmpty.asObservable(),
                                          passwordText: passwordTextField.rx.text.orEmpty.asObservable(),
                                          nicknameText: nicknameTextField.rx.text.orEmpty.asObservable(),
                                          phoneNumberText: phoneNumTextField.rx.text.orEmpty.asObservable(),
                                          birthdayDate: birthdayDatePicker.rx.date.asObservable(), signUpButtonTapped: signUpButton.rx.tap.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.signUpValidation
            .drive(with: self) { owner, valid in
                owner.signUpButton.isEnabled = valid
            }
            .disposed(by: disposeBag)
        
        output.signUpSuccessTrigger
            .drive(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        stackView.addArrangedSubview(birthdayDatePickerTitle)
        stackView.addArrangedSubview(birthdayDatePicker)
        
        [emailTextField, passwordTextField, nicknameTextField, phoneNumTextField, stackView, signUpButton].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureConstraints() {
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(60)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(48)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(emailTextField.snp.horizontalEdges)
            make.height.equalTo(emailTextField)
        }
        
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(emailTextField.snp.horizontalEdges)
            make.height.equalTo(emailTextField)
        }
        
        phoneNumTextField.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(emailTextField.snp.horizontalEdges)
            make.height.equalTo(emailTextField)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(phoneNumTextField.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(emailTextField.snp.horizontalEdges)
            make.height.equalTo(emailTextField)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(48)
        }
    }
    
    override func configureView() {
        
    }
}
