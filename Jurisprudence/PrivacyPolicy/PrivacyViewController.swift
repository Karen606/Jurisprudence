//
//  PrivacyViewController.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 17.02.25.
//


import UIKit
import WebKit

class PrivacyViewController: UIViewController {
    private var webView: WKWebView!
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView(frame: self.view.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(webView)
        
        if let url = url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}