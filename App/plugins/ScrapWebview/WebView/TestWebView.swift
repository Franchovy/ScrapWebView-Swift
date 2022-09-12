//
//  TestWebView.swift
//  App
//
//  Created by Maxime Franchot on 12/09/22.
//

import Foundation
import WebKit

class TestWebView:WKWebView {
    
    // MARK: - Test Components
    
    let closeButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.setTitle("Close Webview", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    let hideButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.setTitle("Hide Webview", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    // MARK: - Webview Code
    
    var id: String?
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .red
        
        closeButton.addTarget(self, action: #selector(onCloseButtonPressed), for: .touchUpInside)
        addSubview(closeButton)
        
        hideButton.addTarget(self, action: #selector(onHideButtonPressed), for: .touchUpInside)
        addSubview(hideButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        closeButton.frame.size = CGSize(width: 130, height: 60)
        closeButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        closeButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        hideButton.frame.size = CGSize(width: 130, height: 60)
        hideButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        hideButton.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 25).isActive = true
    }
    
    // MARK: - Test Methods
    @objc private func onCloseButtonPressed() {
        removeFromSuperview()
    }
    
    @objc private func onHideButtonPressed() {
        isHidden = true
    }
}
