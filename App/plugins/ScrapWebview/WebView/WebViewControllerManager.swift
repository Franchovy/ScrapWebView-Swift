//
//  ScrapWebViewControllerManager.swift
//  App
//
//  Created by Maxime Franchot on 16/09/22.
//

import UIKit

class WebViewControllerManager {
    static let shared = WebViewControllerManager()
    
    /**
     Container type to allow viewcontrollers to be owned and de-allocated by other processes.
     */
    private struct ViewControllerReference {
        weak var viewController: UIViewController?
    }
    
    // MARK: - Private properties
    
    private var viewControllers: [String: ViewControllerReference?] = [:]
    
    // MARK: - Public methods
    
    public func createViewController(forKey key: String, webView: UIView) -> UINavigationController {
        let webViewController = WebViewController(webView: webView)
        
        let navigationController = UINavigationController(rootViewController: webViewController)
        
        if #available(iOS 13.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithTransparentBackground()
            navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationBarAppearance.backgroundColor = UIColor.systemBackground

            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        }
        
        viewControllers[key] = ViewControllerReference(viewController: navigationController)
        
        return navigationController
    }
    
    public func dismissViewController(forKey key: String) {
        if let containerViewController = viewControllers.removeValue(forKey: key)??.viewController {
            containerViewController.dismiss(animated: true)
        }
    }
}
