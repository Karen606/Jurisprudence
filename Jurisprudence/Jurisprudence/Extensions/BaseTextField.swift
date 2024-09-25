//
//  BaseTextField.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 24.09.24.
//

import UIKit

class BaseTextField: UITextField {
    private var padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 14)
    private let bottomLabel = UILabel()
    private var isValid: Bool = true {
        didSet {
            bottomLabel.isHidden = isValid
            if let view = self.superview {
                view.constraints.first?.constant = isValid ? self.bounds.height : self.bounds.height + bottomLabel.bounds.height + 8
            }
        }
    }
    var heightForError: CGFloat {
        get {
            isValid ? self.bounds.height : self.bounds.height + bottomLabel.bounds.height + 8
        }
    }

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func showError(error: String?) {
        if let error = error {
            bottomLabel.text = error
            bottomLabel.frame.size.width = self.bounds.width - 32
            bottomLabel.sizeToFit()
            if isValid {
                isValid = false
            }
            return
        }
        bottomLabel.sizeToFit()
        if !isValid {
            isValid = true
        }
    }
    
    func commonInit() {
        bottomLabel.font = UIFont.systemFont(ofSize: 12)
        bottomLabel.textColor = .red
        bottomLabel.backgroundColor = .clear
        bottomLabel.isHidden = true
        bottomLabel.sizeToFit()
        bottomLabel.frame.origin = CGPoint(x: 16, y: self.bounds.height + 4)
        bottomLabel.numberOfLines = 0
        addSubview(bottomLabel)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.25
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
        self.font = .italicMulish(size: 16)
        self.textColor = .black
        self.layer.cornerRadius = 3
        self.backgroundColor = #colorLiteral(red: 0.5803921569, green: 0.6705882353, blue: 0.631372549, alpha: 1)
        
        self.attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)])
    }
}
