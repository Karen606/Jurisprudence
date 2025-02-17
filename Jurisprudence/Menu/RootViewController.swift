//
//  RootViewController.swift
//  Jurisprudence
//
//  Created by Karen Khachatryan on 17.02.25.
//

import UIKit
import FirebaseRemoteConfig
import WebKit
import Network

class RootViewController: UIViewController {

    private var remoteConfig: RemoteConfig!
    private var privacyWebViewController: PrivacyViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        checkPrivacyLinkAndNavigate()
    }

    private func checkPrivacyLinkAndNavigate() {
        if isNetworkAvailable() {
            initializeRemoteConfig()
        } else {
            showAlertForNoInternet()
        }
    }
    
    private func showAlertForNoInternet() {
        let alert = UIAlertController(
            title: "No Internet Connection",
            message: "Please check your network and try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func initializeRemoteConfig() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        fetchRemoteConfigLink()
    }

    private func fetchRemoteConfigLink() {
        remoteConfig.fetchAndActivate { [weak self] status, error in
            guard let self = self else { return }
            
            if error != nil {
                self.navigateToMenuViewController()
                return
            }

            let privacyLink = self.remoteConfig["privacyLink"].stringValue
            if let url = URL(string: privacyLink), UIApplication.shared.canOpenURL(url) {
                self.loadWebView(with: url)
            } else {
                self.navigateToMenuViewController()
            }
        }
    }

    private func loadWebView(with url: URL) {
        privacyWebViewController = PrivacyViewController()
        privacyWebViewController?.url = url
        privacyWebViewController?.navigationItem.hidesBackButton = true
        self.navigationController?.pushViewController(privacyWebViewController!, animated: true)
    }

    private func navigateToMenuViewController() {
        if let menuVC = storyboard?.instantiateViewController(withIdentifier: "MenuViewController") {
            self.navigationController?.viewControllers = [menuVC]
        }
    }
    
    private func isNetworkAvailable() -> Bool {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        var isAvailable = false
        
        let semaphore = DispatchSemaphore(value: 0)
        
        monitor.pathUpdateHandler = { path in
            isAvailable = path.status == .satisfied
            semaphore.signal()
        }
        
        monitor.start(queue: queue)
        semaphore.wait()
        monitor.cancel()
        return isAvailable
    }
}
