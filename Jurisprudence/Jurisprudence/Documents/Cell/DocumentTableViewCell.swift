//
//  DocumentTableViewCell.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 25.09.24.
//

import UIKit

class DocumentTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .clear
        self.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setupData(name: String?) {
        self.titleLabel.text = name
    }
    
    func setFont() {
        self.titleLabel.font = .regularMulish(size: 20)
    }
    
}
