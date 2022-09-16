//
//  WebViewScriptManager.swift
//  App
//
//  Created by Maxime Franchot on 16/09/22.
//

import Foundation
import WebKit

class WebViewScriptManager: NSObject, WKScriptMessageHandler {
    
    static let shared = WebViewScriptManager()
    
    enum ExecuteJSError: Error {
        case TimeoutError
        case CodeError(String)
        case JavascriptError(Error)
    }
    
    var callbacks: [String: ((Result<Any,Error>) -> Void)?] = [:]
    
    private func executeCallback(for id: String, result: Result<Any,Error>) {
        guard callbacks.keys.contains(id),
              let callback = callbacks.removeValue(forKey: id),
              let callback = callback else {
            return
        }
        
        callback(result)
    }
    
    public func runJavascriptWithCallback(for webView: WKWebView, id: String, script jsScript: String, timeout: Double, callback: @escaping(Result<Any,Error>) -> Void) {
        
        // Set callback into callback dictionary
        let scriptName = id + String(describing: Int.random(in: 0...99999))
        callbacks[scriptName] = callback
        
        webView.configuration.userContentController.add(self, name: scriptName)
        
        let testJSScript = """
        window.webkit.messageHandlers.\(scriptName).postMessage(
            "Does this works?"
        );
        """
        
        // Main JS execution
        DispatchQueue.main.async {
            
            webView.evaluateJavaScript(testJSScript) { _, error in
                // Callback upon failure to execute this javascript code, e.g. invalid JS
                if let error = error {
                    self.executeCallback(for: scriptName, result: .failure(ExecuteJSError.CodeError(error.localizedDescription)))
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
                // Callback upon timeout
                self.executeCallback(for: scriptName, result: .failure(ExecuteJSError.TimeoutError))
            }
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        print("Script execution successful for \(message.name). Message: \(message.body)")
        
        let dict = message.body as? [String: Any]
        
        self.executeCallback(for: message.name, result: .success(dict ?? ""))

        // TODO: Error?
        
    }
    
}
