//
//  OverviewViewController.swift
//  AdVoyager
//
//  Created by Minho on 4/16/24.
//

import UIKit
import SnapKit

final class OverviewViewController: BaseViewController {
    
    let tempLabel: UILabel = {
        let view = UILabel()
        view.text = "Overview"
        view.font = .boldSystemFont(ofSize: 32)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func bind() {
        
    }
    
    override func configureHierarchy() {
        view.addSubview(tempLabel)
    }
    
    override func configureConstraints() {
        tempLabel.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(36)
        }
    }
    
    override func configureView() {
        
    }
    
}
