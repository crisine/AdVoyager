//
//  BaseViewController.swift
//  LSLPBasic
//
//  Created by jack on 2024/04/09.
//
 
import UIKit
import RxSwift
import RxCocoa
import Toast

class BaseViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var isLogoVisible = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        bind()
        configureHierarchy()
        configureConstraints()
        configureView()
        
        if isLogoVisible {
            let logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 120, height: 44))
            logoImageView.contentMode = .scaleAspectFit
            logoImageView.image = UIImage(named: "navTitleLogo")
            navigationItem.titleView = logoImageView
        }
        
        navigationController?.navigationBar.isTranslucent = true
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationItem.standardAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.compactScrollEdgeAppearance = appearance
        
        navigationController?.navigationBar.tintColor = .lightpurple
    }
    
    func bind() {
        
    }
    
    func configureHierarchy() {
        
    }
    
    func configureConstraints() {
        
    }
    
    func configureView() {
        
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showToast(message: String) {
        view.makeToast(message)
    }
}
