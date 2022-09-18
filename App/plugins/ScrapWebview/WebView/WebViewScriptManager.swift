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
        case JavascriptError(String)
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
    
    public func runJavascriptWithCallback(for webView: WKWebView, id: String, script: String, params scriptParams: String, timeout: Double, callback: @escaping(Result<Any,Error>) -> Void) {
        
        // Set callback into callback dictionary
        let scriptName = id + String(describing: Int.random(in: 0...99999))
        callbacks[scriptName] = callback
        
        webView.configuration.userContentController.add(self, name: scriptName)
        
        let handleResultJS = """
            (result) =>
        window.webkit.messageHandlers.\(scriptName).postMessage(
             { result }
        )
        """
        
        let handleErrorJS = """
        (error) =>
            window.webkit.messageHandlers.\(scriptName).postMessage(
                {
                    error: {
                        name: error.name,
                        message: error.message,
                        stack: error.stack
                    }
                }
            )
        """
        
        let toExecute = "(" + script + ")(" + scriptParams + ").then(\(handleResultJS)).catch(\(handleErrorJS))";
        
        print("JS to execute: \n\(toExecute)")
        
        DispatchQueue.main.async {
            
            // Main JS execution
            webView.evaluateJavaScript(toExecute)
            
            // Callback upon timeout
            DispatchQueue.main.asyncAfter(deadline: .now() + timeout / 1000) {
                webView.evaluateJavaScript("throw new Error()")
                
                self.executeCallback(for: scriptName, result: .failure(ExecuteJSError.TimeoutError))
            }
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        guard let dict = message.body as? [String: Any] else {
            return
        }
        
        if dict.keys.contains("result"), let result = dict["result"] {
            
            self.executeCallback(for: message.name, result: .success(result))
            
        } else if dict.keys.contains("error"), let error = dict["error"] {
            
            let data = try! JSONSerialization.data(withJSONObject: error, options: .prettyPrinted)
            let errorJSONString = String(data: data, encoding: String.Encoding.utf8) ?? ""
            
            self.executeCallback(for: message.name, result: .failure(ExecuteJSError.JavascriptError(errorJSONString)))
        }
    }
}
