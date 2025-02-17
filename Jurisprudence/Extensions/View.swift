//
//  View.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 24.09.24.
//

import UIKit

extension UIView {
    func addGradientBorder(borderWidth: CGFloat, colors: [UIColor]) {
        self.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 20
        
        gradientLayer.frame = self.bounds
        
        let borderPath = UIBezierPath(rect: self.bounds)
        
        gradientLayer.mask = createBorderMask(borderPath: borderPath, borderWidth: borderWidth)
        self.layer.addSublayer(gradientLayer)
    }
    
    private func createBorderMask(borderPath: UIBezierPath, borderWidth: CGFloat) -> CAShapeLayer {
        let maskLayer = CAShapeLayer()
        
        let outerPath = borderPath.cgPath
        let innerRect = borderPath.bounds.insetBy(dx: borderWidth, dy: borderWidth)
        let innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: 20)
        
        let combinedPath = CGMutablePath()
        combinedPath.addPath(outerPath)
        combinedPath.addPath(innerPath.cgPath)
        
        maskLayer.path = combinedPath
        maskLayer.fillRule = .evenOdd
        
        return maskLayer
    }
}
