//
//  PaddingLabel.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 25.09.24.
//

import UIKit

class PaddingLabel: UILabel {

    var topInset: CGFloat = 4
    var bottomInset: CGFloat = 4
    var leftInset: CGFloat = 16
    var rightInset: CGFloat = 0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }

    override var bounds: CGRect {
        didSet {
            // ensures this works within stack views if multi-line
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
}
