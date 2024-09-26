//
//  ViewController.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 24.09.24.
//

import UIKit

class MenuViewController: UIViewController {

    let infoButton = UIButton(type: .custom)
    let transitingDelegate = InfoTransitioningDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        infoButton.frame.size = CGSize(width: 30, height: 30)
        infoButton.setImage(UIImage(named: "Info"), for: .normal)
        infoButton.imageView?.contentMode = .center
        self.setNavigationBar(rightButton: infoButton)
        infoButton.addTarget(self, action: #selector(openInfo), for: .touchUpInside)
    }
    
    @objc func openInfo() {
        let infoViewController = InfoViewController(nibName: "InfoViewController", bundle: nil)
        infoViewController.modalPresentationStyle = .custom
        infoViewController.transitioningDelegate = transitingDelegate
        let bgView = UIView(frame: self.view.frame)
        bgView.backgroundColor = #colorLiteral(red: 0.5529411765, green: 0.5333333333, blue: 0.5333333333, alpha: 1).withAlphaComponent(0.5)
        infoViewController.completion = {
            bgView.removeFromSuperview()
        }
        present(infoViewController, animated: true) {
            self.view.insertSubview(bgView, at: 0)
        }
        
    }
    
    @IBAction func clickedCaseAndBusiness(_ sender: UIButton) {
        let worksVC = WorksViewController(nibName: "WorksViewController", bundle: nil)
        self.navigationController?.pushViewController(worksVC, animated: true)
    }
    
    @IBAction func clickedDocumentManagement(_ sender: UIButton) {
        let documentsVC = DocumentsViewController(nibName: "DocumentsViewController", bundle: nil)
        self.navigationController?.pushViewController(documentsVC, animated: true)
    }
    
    @IBAction func clickedReferenceMaterials(_ sender: UIButton) {
        let materialsVC = MaterialsViewController(nibName: "MaterialsViewController", bundle: nil)
        self.navigationController?.pushViewController(materialsVC, animated: true)

    }
    
    @IBAction func clickedCalendarAndDeadlines(_ sender: UIButton) {
        let deadlinesVC = DeadlinesViewController(nibName: "DeadlinesViewController", bundle: nil)
        self.navigationController?.pushViewController(deadlinesVC, animated: true)
    }
    
}

