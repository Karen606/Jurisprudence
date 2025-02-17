//
//  BaseButton.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 24.09.24.
//

import UIKit

class BaseButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 4
        self.titleLabel?.font = .semiboldMulish(size: 20)
        self.titleLabel?.numberOfLines = 0
        self.titleLabel?.textAlignment = .center
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [#colorLiteral(red: 0.4756370187, green: 0.4756369591, blue: 0.4756369591, alpha: 1).cgColor, #colorLiteral(red: 0.8, green: 0.7921568627, blue: 0.7921568627, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 15).cgPath
        gradientLayer.mask = shapeLayer
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2
        self.layer.addSublayer(gradientLayer)
        self.titleLabel?.layer.zPosition = 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = self.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            gradientLayer.frame = self.bounds
            if let shapeLayer = gradientLayer.mask as? CAShapeLayer {
                shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 15).cgPath
            }
        }
    }
}

