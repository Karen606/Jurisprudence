//
//  MaterialTableViewCell.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 26.09.24.
//

import UIKit

class MaterialTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .clear
        self.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
