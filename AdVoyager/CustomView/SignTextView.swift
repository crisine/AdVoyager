//
//  SignTextView.swift
//  AdVoyager
//
//  Created by Minho on 4/16/24.
//

import UIKit

class SignTextView: UIView {
    
    lazy var signTextFieldPlaceholder: String = ""
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 16)
        view.textColor = .text
        return view
    }()
    
    let validationLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16)
        view.textColor = .text
        return view
    }()
    
    lazy var signTextField: SignTextField = {
        let view = SignTextField(placeholderText: signTextFieldPlaceholder)
        return view
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillProportionally
        return view
    }()
    
    init(titleString: String, placeHolder: String) {
        super.init(frame: .zero)
        
        titleLabel.text = titleString
        signTextFieldPlaceholder = placeHolder
        
        backgroundColor = .blue
    }
    
    private func configureHierarchy() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(validationLabel)
        
        addSubview(stackView)
        addSubview(signTextField)
    }
    
    private func configureConstraints() {
        stackView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(4)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(4)
            make.height.equalTo(18)
        }
        
        signTextField.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(4)
            make.horizontalEdges.equalTo(stackView.snp.horizontalEdges)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-4)
        }
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
