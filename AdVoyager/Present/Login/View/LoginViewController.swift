//
//  LoginViewController.swift
//  AdVoyager
//
//  Created by Minho on 4/12/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class LoginViewController: BaseViewController {
    
    private let emailTextField: SignTextField = {
        let view = SignTextField(placeholderText: "이메일 입력...")
        return view
    }()
    private let passwordTextField: SignTextField = {
        let view = SignTextField(placeholderText: "비밀번호 입력...", isSecured: true)
        
        return view
    }()
    private let loginButton: FilledButton = {
        let view = FilledButton(title: "로그인", fillColor: .systemBlue)
        return view
    }()
    private let signupButton: UIButton = {
        let view = UIButton()
        view.setTitle("회원이 아니신가요?", for: .normal)
        view.setTitleColor(.text, for: .normal)
        return view
    }()
    
    private let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func bind() {
        let input = LoginViewModel.Input(
            emailText: emailTextField.rx.text.orEmpty.asObservable(),
            passwordText: passwordTextField.rx.text.orEmpty.asObservable(),
            loginButtonTapped: loginButton.rx.tap.asObservable(),
            signUpButtonTapped: signupButton.rx.tap.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.loginValidation
            .drive(with: self) { owner, valid in
                owner.loginButton.isEnabled = valid
            }
            .disposed(by: disposeBag)
        
        output.loginSuccessTrigger
            .drive(with: self) { owner, _ in
                let vc = MainTabBarViewController()
                owner.view.window?.rootViewController = vc
            }
            .disposed(by: disposeBag)
        
        output.signUpTrigger
            .drive(with: self) { owner, _ in
                print("signUp Button published")
                let vc = SignUpViewController()
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        [emailTextField, passwordTextField, loginButton, signupButton].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureConstraints() {
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(48)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(emailTextField)
            make.height.equalTo(emailTextField)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(32)
            make.horizontalEdges.equalTo(emailTextField)
            make.height.equalTo(emailTextField)
        }
        
        signupButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(32)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(64)
            make.height.equalTo(32)
        }
    }
    
    override func configureView() {
        
    }
}
