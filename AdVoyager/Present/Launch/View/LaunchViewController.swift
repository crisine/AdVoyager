//
//  LaunchViewController.swift
//  AdVoyager
//
//  Created by Minho on 4/23/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class LaunchViewController: BaseViewController {
    
    private let titleLogo: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "titleLogo")!
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let viewModel = LaunchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func bind() {
        let input = LaunchViewModel.Input()
        
        let output = viewModel.transform(input: input)
        
        output.loginSuccessTrigger
            .asObservable()
            .subscribe(with: self) { owner, isTokenRefreshed in
                print("로그인 이벤트 구독")
                
                switch isTokenRefreshed {
                case true:
                    print("메인 화면으로 이동합니다.")
                    let vc = MainTabBarViewController()
                    vc.modalPresentationStyle = .fullScreen
                    owner.present(vc, animated: true)
                case false:
                    print("로그인 화면으로 이동합니다.")
                    let vc = LoginViewController()
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    owner.present(nav, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        view.addSubview(titleLogo)
    }
    
    override func configureConstraints() {
        titleLogo.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
            make.size.equalTo(360)
        }
    }
    
    override func configureView() {}
}
