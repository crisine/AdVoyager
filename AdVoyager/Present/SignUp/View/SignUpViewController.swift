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
    
    private let birthDayDatePicker: BirthdayDatePicker = {
        let view = BirthdayDatePicker()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func bind() {
        [emailTextField, passwordTextField, nicknameTextField, phoneNumTextField, birthDayDatePicker].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureHierarchy() {
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
        
        birthDayDatePicker.snp.makeConstraints { make in
            make.top.equalTo(phoneNumTextField.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(emailTextField.snp.horizontalEdges)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }
    
    override func configureConstraints() {
       
    }
    
    override func configureView() {
        
    }
}
