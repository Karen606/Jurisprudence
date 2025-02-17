//
//  ViewController.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 24.09.24.
//

import UIKit
import MessageUI

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
        infoViewController.completion = { [weak self] index in
            guard let self = self else { return }
            bgView.removeFromSuperview()
            switch index {
            case 1:
                if MFMailComposeViewController.canSendMail() {
                    let mailComposeVC = MFMailComposeViewController()
                    mailComposeVC.mailComposeDelegate = self
                    mailComposeVC.setToRecipients(["caymayakuplen@icloud.com"])
                    present(mailComposeVC, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(
                        title: "Mail Not Available",
                        message: "Please configure a Mail account in your settings.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    present(alert, animated: true)
                }
            case 2:
                let privacyVC = PrivacyViewController()
                privacyVC.url = URL(string: "https://docs.google.com/document/d/1y3cSKzcaZHRJSZA0ibfjLzY5zDieSn_Fyk-WwcTSFho/mobilebasic")
                self.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(privacyVC, animated: true)
                self.hidesBottomBarWhenPushed = false
            case 3:
                let appID = "6742007154"
                if let url = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        print("Unable to open App Store URL")
                    }
                }
            default:
                break
            }
        }
        present(infoViewController, animated: true)
        self.view.insertSubview(bgView, at: 0)
        
//        present(infoViewController, animated: true) {
//            self.view.insertSubview(bgView, at: 0)
//        }
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

extension MenuViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
