//
//  ScrapWebView.swift
//  App
//
//  Created by Maxime Franchot on 15/09/22.
//

import Foundation
import WebKit

class WebViewManager {
    static let shared = WebViewManager()
    
    // MARK: - Private Properties
    
    private var webViewsDictionary: [String: WKWebView] = [:]
    private var viewControllers: [String: UIViewController?] = [:]
    
    // MARK: - Public Methods
    
    func getWebView(forKey key: String) -> WKWebView? {
        guard webViewsDictionary.keys.contains(key),
              let webView = webViewsDictionary[key]
        else {
            return nil
        }
        
        return webView
    }
    
    func createWebView(forKey key: String, frame: CGRect, persistSession: Bool) -> WKWebView {
        // If key is already present, do nothing.
        guard !webViewsDictionary.keys.contains(key) else {
            fatalError("Webview with this ID has already been created, Use getWebView(forKey:\(key)) instead.")
        }
        
        let config = createWebViewConfiguration(forKey: key, persistSession: persistSession)
        
        let webView = WKWebView(frame: frame, configuration: config)
        webViewsDictionary[key] = webView
        
        return webView
    }
    
    func removeWebView(forKey key: String) {
        webViewsDictionary.removeValue(forKey: key)
    }
    
    func replaceWebViewId(forKey prevKey: String, newKey: String) {
        let webView = webViewsDictionary.removeValue(forKey: prevKey)
        webViewsDictionary[newKey] = webView
    }
    
    // MARK: - Private methods
    
    // WKWebView Configuration
    
    private func createWebViewConfiguration(forKey key: String, persistSession: Bool) -> WKWebViewConfiguration {
        // WebView Configuration
        let config = WKWebViewConfiguration()
        
        // Load persistence config
        if persistSession {
            config.websiteDataStore = .default()
        } else {
            config.websiteDataStore = .nonPersistent()
        }
        
        return config
    }
}
