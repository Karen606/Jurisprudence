//
//  WorkTableViewCell.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 25.09.24.
//

import UIKit

class WorkTableViewCell: UITableViewCell {
    @IBOutlet weak var clientName: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.layer.cornerRadius = 15
//        self.layer.borderWidth = 1
//        self.layer.borderColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
//        self.contentView.layer.cornerRadius = 15
        self.contentView.backgroundColor = .clear
        self.backgroundColor = UIColor.clear
//        self.contentView.layer.backgroundColor = UIColor.clear.cgColor
        self.bgView.layer.cornerRadius = 15
        self.bgView.layer.borderWidth = 1
        self.bgView.layer.borderColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        let labels = [clientName, typeLabel, deadlineLabel, statusLabel]
        labels.forEach({ $0?.font = .regularMulish(size: 14)})
        costLabel.font = .semiboldMulish(size: 14)
        statusButton.titleLabel?.font = .lightMulish(size: 14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupData(work: WorkModel) {
        self.clientName.text = work.name
        self.typeLabel.text = work.type
        self.deadlineLabel.text = "Due date: \(work.deadline?.dateFormat() ?? "")"
        self.costLabel.text = work.cost
        self.statusButton.setTitle(work.status.id, for: .normal)
    }
    
    @IBAction func clickedStatus(_ sender: UIButton) {
    }
}
