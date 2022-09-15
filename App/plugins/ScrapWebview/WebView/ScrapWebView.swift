//
//  ScrapWebView.swift
//  App
//
//  Created by Maxime Franchot on 15/09/22.
//

import Foundation
import WebKit

class ScrapWebView {
    static let shared = ScrapWebView()
    
    // WebView Reference Management
    
    /**
     Container Type  for keeping weak references to WKWebWiew allowing safe access and
     deallocation by other processes.
     */
    private struct WebViewRef {
        var webView: WKWebView
    }
    
    // Containers for webviews and storage based on IDs
    private var webViewsDictionary: [String: WebViewRef] = [:]
    private var persistentStorage: [String: (WKProcessPool, WKWebsiteDataStore)] = [:]
    
    func getWebView(forKey key: String) -> WKWebView? {
        guard webViewsDictionary.keys.contains(key),
              let webViewRef = webViewsDictionary[key]
        else {
            return nil
        }
        
        return webViewRef.webView
    }
    
    func addWebView(withKey key: String, webView: WKWebView) {
        // If key is already present, do nothing.
        guard !webViewsDictionary.keys.contains(key) else {
            return
        }
        
        webViewsDictionary[key] = WebViewRef(webView: webView)
    }
    
    func removeWebView(forKey key: String) {
        webViewsDictionary.removeValue(forKey: key)
    }
    
    func getPersistentStorageConfig(forKey key: String) -> (WKProcessPool, WKWebsiteDataStore)? {
        if persistentStorage.keys.contains(key) {
            return persistentStorage[key]
        }
        
        return nil
    }
    
    func createPersistentStorageConfig(forKey key: String) -> (WKProcessPool, WKWebsiteDataStore) {
        if persistentStorage.keys.contains(key) {
            fatalError("Persistent storage for this key already exists, use 'getPersistentStorageConfig(forKey: \(key)' instead")
        }
        
        let persistentStore = (WKProcessPool(), WKWebsiteDataStore.nonPersistent())
        persistentStorage[key] = persistentStore
        
        return persistentStore
    }
}
