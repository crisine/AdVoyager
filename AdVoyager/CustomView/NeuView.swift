//
//  NeuView.swift
//  AdVoyager
//
//  Created by Minho on 4/22/24.
//

import UIKit

class NeuView: UIView {
    
    public var image: UIImage? {
        didSet {
            imgView.image = image
        }
    }
    
    private let imgView = UIImageView()
    private let darkShadow = CALayer()
    private let lightShadow = CALayer()
    
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() -> Void {

        // add sublayers
        self.layer.addSublayer(darkShadow)
        self.layer.addSublayer(lightShadow)
        self.layer.addSublayer(gradientLayer)

        darkShadow.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        darkShadow.shadowOffset = CGSize(width: 5, height: 5)
        darkShadow.shadowOpacity = 1
        darkShadow.shadowRadius = 10

        lightShadow.shadowColor = UIColor.white.withAlphaComponent(0.9).cgColor
        lightShadow.shadowOffset = CGSize(width: -5, height: -5)
        lightShadow.shadowOpacity = 1
        lightShadow.shadowRadius = 10

        // 45-degree gradient layer
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        
        self.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        layer.borderWidth = 3
        
        // very light gray background color
        let bkgColor = UIColor(white: 0.95, alpha: 1.0)
        
        darkShadow.backgroundColor = bkgColor.cgColor
        lightShadow.backgroundColor = bkgColor.cgColor
        
        // set gradient colors from
        //  slightly darker than background to
        //  slightly lighter than background
        let c1 = UIColor(white: 0.92, alpha: 1.0)
        let c2 = UIColor(white: 0.97, alpha: 1.0)
        gradientLayer.colors = [c1.cgColor, c2.cgColor]

        // image view properties
        imgView.contentMode = .scaleAspectFit
        imgView.translatesAutoresizingMaskIntoConstraints = false
        //imgView.layer.masksToBounds = true
        
        addSubview(imgView)
        
        NSLayoutConstraint.activate([
            
            // let's make the image view 60% of self
            imgView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6),
            imgView.heightAnchor.constraint(equalTo: imgView.widthAnchor),
            imgView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imgView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
        ])
        
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        // set all layers' frames to bounds
        darkShadow.frame = bounds
        lightShadow.frame = bounds
        gradientLayer.frame = bounds
        
        // set all layers' cornerRadius to one-half height
        // bounds.height * 0.5 로 주면 Circle 형태로 만들 수 있음.
        let cr = 16.0
        darkShadow.cornerRadius = cr
        lightShadow.cornerRadius = cr
        gradientLayer.cornerRadius = cr
        layer.cornerRadius = cr
        
    }
    
}
