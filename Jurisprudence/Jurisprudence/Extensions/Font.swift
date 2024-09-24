//
//  Font.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 24.09.24.
//

import UIKit

extension UIFont {
    static func regularMulish(size: CFloat) -> UIFont? {
        return UIFont(name: .regular, size: CGFloat(size))
    }
    
    static func italicMulish(size: CFloat) -> UIFont? {
        return UIFont(name: .italic, size: CGFloat(size))
    }
    
    static func semiboldMulish(size: CFloat) -> UIFont? {
        return UIFont(name: .semibold, size: CGFloat(size))
    }
    
    static func boldMulish(size: CFloat) -> UIFont? {
        return UIFont(name: .bold, size: CGFloat(size))
    }
}
