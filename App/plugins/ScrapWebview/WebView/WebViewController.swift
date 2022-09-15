//
//  ScrapWebViewController.swift
//  App
//
//  Created by Maxime Franchot on 16/09/22.
//

import Foundation
import UIKit

class WebViewController: UIViewController {
    let webView: UIView
    
    init(webView: UIView) {
        self.webView = webView

        super.init(nibName: nil, bundle: nil)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        
        let closeButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(onCloseButtonPressed))
        navigationItem.leftBarButtonItems = [closeButtonItem]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    @objc private func onCloseButtonPressed() {
        if let navigationController = navigationController {
            navigationController.dismiss(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
