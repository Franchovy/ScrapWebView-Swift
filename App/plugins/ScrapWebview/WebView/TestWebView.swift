//
//  TestWebView.swift
//  App
//
//  Created by Maxime Franchot on 12/09/22.
//

import Foundation
import WebKit

fileprivate func configureButtonAppearance(_ button: UIButton) {
    button.backgroundColor = .systemBlue
    button.layer.shadowOffset = CGSize(width: 2, height: 2)
    button.layer.shadowOpacity = 0.2
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.cornerRadius = 15
    button.setTitleColor(.black, for: .normal)
}

class TestWebView:WKWebView {
    
    // MARK: - Components for testing
    
    let closeButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Close Webview", for: .normal)
        configureButtonAppearance(button)
        return button
    }()
    
    let hideButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Hide Webview", for: .normal)
        configureButtonAppearance(button)
        return button
    }()
    
    let minimizeButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        configureButtonAppearance(button)
        return button
    }()
    
    // MARK: - Variable Properties
    
    var minimized: Bool! {
        didSet {
            minimizeButton.setTitle(minimized ? "Maximize" : "Minimize", for: .normal)

            guard let superview = superview else { return }
            
            if minimized {
                frame.origin.y = superview.frame.height / 2
                frame.size.height = superview.frame.height / 2
            } else {
                frame.origin.y = superview.frame.origin.y
                frame.size.height = superview.frame.height
            }
        }
    }
    
    // MARK: - Webview Code
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        minimized = false
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 2
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 6
        
        closeButton.addTarget(self, action: #selector(onCloseButtonPressed), for: .touchUpInside)
        addSubview(closeButton)
        
        hideButton.addTarget(self, action: #selector(onHideButtonPressed), for: .touchUpInside)
        addSubview(hideButton)
        
        minimizeButton.addTarget(self, action: #selector(onMinimizeButtonPressed), for: .touchUpInside)
        addSubview(minimizeButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        closeButton.frame.size = CGSize(width: 130, height: 60)
        if minimized {
            closeButton.centerYAnchor.constraint(equalTo: topAnchor, constant: 25).isActive = true
        } else {
            closeButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
        closeButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        hideButton.frame.size = CGSize(width: 130, height: 60)
        hideButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        hideButton.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 25).isActive = true
        
        minimizeButton.frame.size = CGSize(width: 130, height: 60)
        minimizeButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        minimizeButton.topAnchor.constraint(equalTo: hideButton.bottomAnchor, constant: 25).isActive = true
    }
    
    // MARK: - Test Methods
    @objc private func onCloseButtonPressed() {
        removeFromSuperview()
    }
    
    @objc private func onHideButtonPressed() {
        isHidden = true
    }
    
    @objc private func onMinimizeButtonPressed() {
        minimized = !minimized
        
        layoutSubviews()
    }
}
