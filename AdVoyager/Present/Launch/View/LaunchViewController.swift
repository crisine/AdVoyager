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
    
    private let tempLogo: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "apple.logo")!
        view.contentMode = .scaleAspectFit
        return view
    }()
    private let tempLabel: UILabel = {
        let view = UILabel()
        view.text = "임시 런치스크린"
        view.textAlignment = .center
        view.font = .boldSystemFont(ofSize: 48)
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
                switch isTokenRefreshed {
                case true:
                    let vc = MainTabBarViewController()
                    vc.modalPresentationStyle = .fullScreen
                    owner.present(vc, animated: true)
                case false:
                    let vc = LoginViewController()
                    vc.modalPresentationStyle = .fullScreen
                    owner.present(vc, animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        view.addSubview(tempLogo)
        view.addSubview(tempLabel)
    }
    
    override func configureConstraints() {
        tempLogo.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.centerY.equalTo(view.safeAreaLayoutGuide).offset(-80)
            make.size.equalTo(80)
        }
        
        tempLabel.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(56)
        }
    }
    
    override func configureView() {
        tempLogo.tintColor = .red
    }
}
