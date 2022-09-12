//
//  ScrapWebviewPlugin.swift
//  App
//
//  Created by Paul Antoine on 09/06/2022.
//

import Foundation
import Capacitor
// MARK: Solution imports
import WebKit

@objc(ScrapWebviewPlugin)
public class ScrapWebviewPlugin: CAPPlugin {
    
    // MARK: - Internal Methods and Properties
    
    /**
     Container Type  for keeping weak references to WKWebWiew allowing safe access and
     deallocation by other processes.
     */
    struct WebViewRef { weak var webView: WKWebView? }
    
    /**
     Dictionary ID-to-WebViewReference storing (potentially deallocated) webviews by ID.
     */
    var webViewsDictionary: [String: WebViewRef] = [:]
    
    private func addToWebViewsDict(id: String, webView: WKWebView) {
        // If key is already present, do nothing.
        guard !webViewsDictionary.keys.contains(id) else {
            return
        }
        
        webViewsDictionary[id] = WebViewRef(webView: webView)
    }
    
    private func removeFromWebViewsDict(id: String) {
        webViewsDictionary.removeValue(forKey: id)
    }
    
    
    // MARK: - Plugin public methods
    
    @objc public func create(_ call: CAPPluginCall) {
        
        // let userAgent = call.getString("userAgent", "");
        // let persistSession = call.getBool("persistSession", false);
        // let id = call.getString("id", "");
        // let proxySettings = call.getObject("proxySettings");
        // let windowSettings = call.getObject("windowSettings");
        
        guard let webView = webView else {
            print("ERROR - CANNOT LOAD: No existing webview.")
            return
        }
        
        // Log properties
        DispatchQueue.main.async {
            print("WebView Config object: \(webView.configuration)")
            print("Is visible: \(!webView.isHidden)")
            print("Preferences: \(webView.configuration.preferences)")
            print("ProcessPool Configuration: \(webView.configuration.processPool)")
        }
        
        // User Agent
        if let userAgent = call.getString("userAgent") {
            webView.customUserAgent = userAgent
        }
        
        DispatchQueue.main.async {
            let testWebView = TestWebView(frame: webView.frame, configuration: WKWebViewConfiguration())
            testWebView.id = "testing1"
            self.addToWebViewsDict(id: testWebView.id!, webView: testWebView)
            
            webView.addSubview(testWebView)
        }
        
        /**
         * This function must create a new Web View associated to a given ID.
         * This ID is used in other function to do things with the Web View.
         *
         * If a Web View already exists, do nothing
         * Multiple Web Views can be created
         *
         * If userAgent is not null, it must be used to load web pages of this Web View.
         *
         * If persistSession is true, the Web View must keep localStorage, cookies, etc... when destroyed, so
         * sessions on websites persist. If persistSession is false, all storage must be cleared on destroy.
         *
         * If closable is true, the Web View must have a header with a close button when visible
         *
         * If show is true, the Web View must be visible on creation (but can be hidden later)
         * If show is false, the Web View must be invisible on creation (but can be shown later)
         *
         * If proxySettings is not null, the Web View must load pages through a proxy with the settings given.
         * If possible, the proxy auth must be invisible to the user and not show anything
         *
         * IMPORTANT : Multiple webviews must be able to run at the same time and execute Javascript, event if not visible
         * They must not be in a "sleeping" state.
         */
        
        // @todo
        call.resolve();
        
    }
    
    @objc public func destroy(_ call: CAPPluginCall) {
        
        // let id = call.getString("id", "");
        
        /**
         * This function must destroy the Web View with the given ID.
         */
        
        // @todo
        
        call.resolve();
        
    }
    
    @objc public func replaceId(_ call: CAPPluginCall) {
        
        // let id = call.getString("id", "");
        // let newId = call.getString("new_id", "");
        
        /**
         * This function must replace the ID of a Web View with a newId
         */
        
        // @todo
        
        call.resolve();
        
        
    }
    
    @objc public func show(_ call: CAPPluginCall) {
        
        // let id = call.getString("id", "");
        
        /**
         * This function must show the Web View with the given ID if invisible
         */
        
        // @todo
        
        call.resolve();
        
    }
    
    @objc public func hide(_ call: CAPPluginCall) {
        
        // let id = call.getString("id", "");
        
        /**
         * This function must hide the Web View with the given ID if visible
         */
        
        // @todo
        
        call.resolve();
        
    }
    
    @objc public func getUrl(_ call: CAPPluginCall) {
        
        // let id = call.getString("id", "");
        
        /**
         * This function must return the current URL loaded in the Web View with the given ID
         */
        
        // @todo
        
        let currentUrl = "";
        
        call.resolve(["url": currentUrl]);
        
    }
    
    @objc public func loadUrl(_ call: CAPPluginCall) {
        
        // let id = call.getString("id", "");
        // let newId = call.getString("url", "");
        // let force = call.getBool("force", false);
        
        /**
         * This function must load the URL given in the Web View with the given ID
         *
         * If force is true, the URL must be loaded in any case
         * If force is false, the URL must not be loaded if it's the current URL of the Web View
         */
        
        // @todo
        
        call.resolve();
        
    }
    
    @objc public func reloadPage(_ call: CAPPluginCall) {
        
        // let id = call.getString("id", "");
        
        /**
         * This function must reload the page of the Web View with the given ID
         */
        
        // @todo
        
        call.resolve();
    }
    
    @objc public func evaluateScript(_ call: CAPPluginCall) {
        
        // let id = call.getString("id", null);
        // let script = call.getString("script", "");
        // let timeout = call.getInt("timeout", 1000);
        // let params = call.getString("params", "");
        // if (script == "") {
        // 		call.reject("You must provide a Javascript string to evaluate.");
        // }
        // let toExecute = "(" + script + ")(" + params + ").then(result => ({ result })).catch(error => { console.log(error); return { error: { name: error.name, message: error.message, stack: error.stack } }; })";
        
        /**
         * This function must execute Javascript in the Web View with the given ID.
         *
         * The code to execute is a single string in the variable toExecute.
         *
         * The result of the function will always be a JSON Object of this format :
         * {
         *      result: any,
         *      error: {
         *          name: string,
         *          message: string;
         *          stack: string;
         *      }
         * }
         *
         * If result exists in the object, it must be set to the variable below
         * If error exists in the object, call.reject() must be called with the stringified error object as a parameter
         *
         * IMPORTANT :
         * We also need a timeout feature if the script never ends its execution
         * If the script didn't end in the time given by timeout (ms), call.reject("ScrapingTimeoutError") must be called
         */
        
        
        // @todo
        
        let result = "";
        
        call.resolve(["result": result ]);
        
    }
    
    @objc public func getCookie(_ call: CAPPluginCall) {
        
        // let id = call.getString("id", "");
        // let name = call.getString("name", "");
        
        /**
         * This function must return the cookie of a given name stored in the Web View of the given ID
         */
        
        // @todo
        
        let cookie = "";
        
        
        call.resolve(["cookie": cookie ]);
        
    }
    
    @objc public func setCookie(_ call: CAPPluginCall) {
        
        // let id = call.getString("id", "");
        // let cookie = call.getString("cookie_stringified", "");
        // let url = call.getString("url", "");
        
        /**
         * This function must set a given cookie to the Web View with the given ID for the given URL
         *
         * The cookie variable contain a stringified JSON Object with the cookies params :
         * name: string
         * value: string
         * domain: string
         * path: string
         * secure: boolean
         * httpOnly: boolean
         * expirationDate: number
         * sameSite: 'unspecified' | 'no_restriction' | 'lax' | 'strict'
         */
        
        // @todo
        
        call.resolve();
        
    }
}