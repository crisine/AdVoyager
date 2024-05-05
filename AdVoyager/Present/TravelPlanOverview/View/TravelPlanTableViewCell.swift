//
//  TravelPlanTableViewCell.swift
//  AdVoyager
//
//  Created by Minho on 4/28/24.
//

import UIKit

final class TravelPlanTableViewCell: BaseTableViewCell {
    
    private let backView: NeuView = {
        let view = NeuView()
        return view
    }()
    
    private let planTitleLabel: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 16)
        return view
    }()
    private let planDateLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13)
        return view
    }()
    private let thumbnailImageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .lightpurple
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    override func configureHierarchy() {
        [planTitleLabel, planDateLabel, thumbnailImageView].forEach {
            backView.addSubview($0)
        }
        
        contentView.addSubview(backView)
    }
    
    override func configureConstraints() {
        
        backView.snp.makeConstraints { make in
            make.edges.equalTo(contentView.safeAreaLayoutGuide).inset(8)
            make.height.equalTo(80)
        }
        
        planTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(backView).offset(8)
            make.leading.equalTo(backView).offset(8)
            make.trailing.equalTo(thumbnailImageView.snp.leading).inset(8)
        }
        
        planDateLabel.snp.makeConstraints { make in
            make.top.equalTo(planTitleLabel.snp.bottom).offset(4)
            make.leading.equalTo(backView).offset(8)
        }
        
        thumbnailImageView.snp.makeConstraints { make in
            make.trailing.equalTo(backView)
            make.verticalEdges.equalTo(backView)
            make.width.equalTo(80)
        }
    }
    
    override func prepareForReuse() {
        planTitleLabel.text = nil
        planDateLabel.text = nil
        thumbnailImageView.image = nil
    }
    
    func updateCell(data: TravelPlan) {
        planTitleLabel.text = data.planTitle
        planDateLabel.text = "\(data.firstDate.toString(format: "yy.MM.dd")) ~ \(data.lastDate.toString(format: "yy.MM.dd"))"
        thumbnailImageView.image = UIImage(systemName: "airplane.departure")
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
