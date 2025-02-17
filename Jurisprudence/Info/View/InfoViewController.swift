//
//  InfoViewController.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 24.09.24.
//

import UIKit

class InfoViewController: UIViewController {
    
    var completion: ((Int) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.masksToBounds = true
        self.view.layer.cornerRadius = 20
    }
    
    override func viewDidLayoutSubviews() {
        self.view.addGradientBorder(borderWidth: 1, colors: [#colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1), #colorLiteral(red: 0.8, green: 0.7921568627, blue: 0.7921568627, alpha: 1)])
    }
    
    @IBAction func clickedBack(_ sender: UIButton) {
        self.completion?(0)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickedContactUs(_ sender: UIButton) {
        completion?(1)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickedPrivacyPolicy(_ sender: UIButton) {
        completion?(2)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickedRateUs(_ sender: UIButton) {
        completion?(3)
        self.dismiss(animated: true, completion: nil)
    }
}
