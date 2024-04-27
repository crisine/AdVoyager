//
//  TravelScheduleTableViewCell.swift
//  AdVoyager
//
//  Created by Minho on 4/24/24.
//

import UIKit

final class TravelScheduleTableViewCell: UITableViewCell {
    
    private let dateLabel: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 16)
        return view
    }()
    private let iconImageView: UIImageView = {
        let view = UIImageView()
        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.layer.borderWidth = 2
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        return view
    }()
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 16)
        return view
    }()
    private let descriptionLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13)
        view.textColor = .darkGray
        view.numberOfLines = 0
        return view
    }()
    private let contentStackView: UIStackView = {
        let view = UIStackView(frame: .zero)
        view.axis = .vertical
        
        view.distribution = .equalCentering
        view.spacing = 4
        return view
    }()
    
    private let previousStepLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue
        view.isHidden = true
        return view
    }()
    private let nextStepLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue
        view.isHidden = true
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        configureHierarchy()
        configureConstraints()
    }
    
    func configureHierarchy() {
        [dateLabel, iconImageView, previousStepLine, nextStepLine, contentStackView].forEach {
            contentView.addSubview($0)
        }
        
        [titleLabel, descriptionLabel].forEach {
            contentStackView.addArrangedSubview($0)
        }
    }
    
    func configureConstraints() {
        dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(16)
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(8)
            make.width.equalTo(48)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalTo(dateLabel.snp.trailing).offset(4)
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(8)
            make.size.equalTo(24)
        }
        
        previousStepLine.snp.makeConstraints { make in
            make.centerX.equalTo(iconImageView)
            make.top.equalTo(contentView)
            make.bottom.equalTo(iconImageView.snp.top)
            make.width.equalTo(2)
        }
        
        nextStepLine.snp.makeConstraints { make in
            make.centerX.equalTo(iconImageView)
            make.top.equalTo(iconImageView.snp.bottom)
            make.bottom.equalTo(contentView)
            make.width.equalTo(2)
        }
        
        contentStackView.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(8)
            make.leading.equalTo(iconImageView.snp.trailing).offset(4)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).offset(-8)
        }
    }
    
    func updateCell(data: TravelScheduleModel, isLastCell: Bool) {
        dateLabel.text = data.date.toString(format: "hh:mm")
        // iconImageView.image = UIImage(systemName: "circle")
        titleLabel.text = data.placeTitle
        descriptionLabel.text = data.description
        
        if data.order == 1 {
            nextStepLine.isHidden = false
        } else if isLastCell == false {
            previousStepLine.isHidden = false
            nextStepLine.isHidden = false
        } else {
            previousStepLine.isHidden = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
