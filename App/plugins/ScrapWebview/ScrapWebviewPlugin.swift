//
//  ScrapWebviewPlugin.swift
//  App
//
//  Created by Paul Antoine on 09/06/2022.
//

import Foundation
import Capacitor
import WebKit

@objc(ScrapWebviewPlugin)
public class ScrapWebviewPlugin: CAPPlugin {
    
    // MARK: - Internal Methods and Properties
    
    /**
     Container Type  for keeping weak references to WKWebWiew allowing safe access and
     deallocation by other processes.
     */
    struct WebViewRef {
        weak var webView: WKWebView?
    }
    
    /**
     Dictionary ID-to-WebViewReference storing (potentially deallocated) webviews by ID.
     */
    var webViewsDictionary: [String: WebViewRef] = [:]
    
    // TODO: Session / Process Pool Dictionary to persist data
    
    private func getWebViewReference(byKey key: String) -> WKWebView? {
        guard webViewsDictionary.keys.contains(key),
              let webViewRef = webViewsDictionary[key]
        else {
            return nil
        }
        
        return webViewRef.webView
    }
    
    private func addToWebViewsDict(withKey key: String, webView: WKWebView) {
        // If key is already present, do nothing.
        guard !webViewsDictionary.keys.contains(key) else {
            return
        }
        
        webViewsDictionary[key] = WebViewRef(webView: webView)
    }
    
    private func removeFromWebViewsDict(forKey key: String) {
        webViewsDictionary.removeValue(forKey: key)
    }
    
    // MARK: - Plugin public methods
    
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
     *
     * windowSettings:
     * If 'closable' is true, the Web View must have a header with a close button when visible
     * If 'show' is true, the Web View must be visible on creation (but can be hidden later)
     * If 'show' is false, the Web View must be invisible on creation (but can be shown later)
     *
     * If proxySettings is not null, the Web View must load pages through a proxy with the settings given.
     * If possible, the proxy auth must be invisible to the user and not show anything
     * {
     *   host: string;
     *   port: number;
     *   username: string;
     *   password: string;
     * }
     *
     * IMPORTANT : Multiple webviews must be able to run at the same time and execute Javascript, event if not visible
     * They must not be in a "sleeping" state.
     */
    @objc public func create(_ call: CAPPluginCall) {
        
        // Load call parameters
        
        let id = call.getString("id", "");
        let userAgent = call.getString("userAgent", "");
        // let persistSession = call.getBool("persistSession", false);
        // let proxySettings = call.getObject("proxySettings");
        // let windowSettings = call.getObject("windowSettings");
        
        // If webview with this key already exists, do nothing.
        
        if webViewsDictionary.keys.contains(id) {
            return
        }
        
        // Ensure base webview exists
        // TODO: What is the fail condition?
        
        guard let baseWebView = webView else {
            call.reject("ERROR CREATING WEBVIEW: Cannot find base webview")
            return
        }
        
        // WebView Configuration
        
        let config = WKWebViewConfiguration()
        
        // TODO: Process Pool by ID
        // TODO: Proxy Settings
        // TODO: Window Settings
        
        // Create WebView and add to base WebView
        
        DispatchQueue.main.async {
            // Instantiate WebView
            let webView = TestWebView(frame: baseWebView.frame, configuration: config)
            webView.customUserAgent = userAgent
            // TODO: webView.isHidden = !shouldShow
            
            // Add reference to dictionary
            self.addToWebViewsDict(withKey: id, webView: webView)
            
            // Add to UI
            baseWebView.addSubview(webView)
            
            call.resolve();
        }
    }
    
    /**
     * This function must destroy the Web View with the given ID.
     */
    @objc public func destroy(_ call: CAPPluginCall) {
        let id = call.getString("id", "")
        
        guard let webView = getWebViewReference(byKey: id) else {
            call.reject("No WebView with id: '\(id)'")
            return
        }
        
        removeFromWebViewsDict(forKey: id)
        DispatchQueue.main.async {
            webView.removeFromSuperview()
            call.resolve();
        }
    }
    
    /**
     * This function must replace the ID of a Web View with a newId
     */
    @objc public func replaceId(_ call: CAPPluginCall) {
        let id = call.getString("id", "")
        
        guard let webView = getWebViewReference(byKey: id) else {
            call.reject("No WebView with id: '\(id)'")
            return
        }
        
        let newId = call.getString("new_id", "");
        
        // If ID hasn't changed, do nothing
        if id == newId {
            return
        }
        
        removeFromWebViewsDict(forKey: id)
        addToWebViewsDict(withKey: newId, webView: webView)
        
        call.resolve();
    }
    
    
    /**
     * This function must show the Web View with the given ID if invisible
     */
    @objc public func show(_ call: CAPPluginCall) {
        let id = call.getString("id", "")
        
        guard let webView = getWebViewReference(byKey: id) else {
            call.reject("No WebView with id: '\(id)'")
            return
        }
        
        DispatchQueue.main.async {
            webView.isHidden = false
            call.resolve();
        }
    }
    
    /**
     * This function must hide the Web View with the given ID if visible
     */
    @objc public func hide(_ call: CAPPluginCall) {
        let id = call.getString("id", "")
        
        guard let webView = getWebViewReference(byKey: id) else {
            call.reject("No WebView with id: '\(id)'")
            return
        }
        
        DispatchQueue.main.async {
            webView.isHidden = true
            call.resolve();
        }
    }
    
    
    /**
     * This function must return the current URL loaded in the Web View with the given ID
     */
    @objc public func getUrl(_ call: CAPPluginCall) {
        let id = call.getString("id", "")
        
        guard let webView = getWebViewReference(byKey: id) else {
            call.reject("No WebView with id: '\(id)'")
            return
        }
        
        DispatchQueue.main.async {
            let currentUrl = webView.url;
            
            call.resolve(["url": currentUrl?.absoluteString ?? ""]);
        }
    }
    
    
    /**
     * This function must load the URL given in the Web View with the given ID
     *
     * If force is true, the URL must be loaded in any case
     * If force is false, the URL must not be loaded if it's the current URL of the Web View
     */
    @objc public func loadUrl(_ call: CAPPluginCall) {
        
        let id = call.getString("id", "");
        let shouldForce = call.getBool("force", false);
        let urlStr = call.getString("url")
        
        guard urlStr != nil, let url = URL(string: urlStr!) else {
            if urlStr == nil { call.reject("You must provide a url parameter for loadUrl: \(String(describing: urlStr))") }
            else { call.reject("Invalid url parameter for loadUrl: \(String(describing: urlStr))") }
            return
        }
        
        guard let webView = getWebViewReference(byKey: id) else {
            call.reject("No WebView with id: \(id)")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        DispatchQueue.main.async {
            // Verify if url is the same.
            // If so, proceed if force parameter is true
            if webView.url == nil
                || webView.url! != url
                || shouldForce
            {
                webView.load(urlRequest)
            }
            
            call.resolve()
        }
    }
    
    /**
     * This function must reload the page of the Web View with the given ID
     */
    @objc public func reloadPage(_ call: CAPPluginCall) {
        let id = call.getString("id", "")
        
        guard let webView = getWebViewReference(byKey: id) else {
            call.reject("No WebView with id: '\(id)'")
            return
        }
        
        DispatchQueue.main.async {
            webView.reload()
            
            call.resolve();
        }
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
    @objc public func setCookie(_ call: CAPPluginCall) {
        
        let id = call.getString("id", "");
        let urlString = call.getString("url");
        
        guard let cookieJson = call.getString("cookie_stringified") else {
            call.reject("'cookie_stringified' parameter must not be null.")
            return
        }
        
        do {
            let url = urlString != nil ? URL(string: urlString!) : nil
            let cookieObject = try decodeCookie(from: cookieJson, url: url)
            print("Cookie object: \(cookieObject)")
        } catch {
            print("Error creating cookie: \(error)")
            call.reject("Error creating cookie")
        }
        
        
        
        call.resolve();
        
    }
}

// PATCH: Swift library does not explicitly declare the "httpOnly" property, it must be added manually.
extension HTTPCookiePropertyKey {
    static let httpOnly = HTTPCookiePropertyKey("HttpOnly")
}

extension ScrapWebviewPlugin {
    private enum CookieDecodeError: Error {
        case convertStringError
        case noUrlPathError
        case noDomainOrUrlError
    }
    
    private enum CookieSameSitePolicy: Decodable {
        case unspecified
        case no_restriction
        case lax
        case strict
        
        @available(iOS 13.0, *)
        func toHttpCookiePolicy() -> HTTPCookieStringPolicy? {
            switch self {
            case .unspecified: return .none
            case .lax: return .sameSiteLax
            case .strict: return .sameSiteStrict
            case .no_restriction: return .none
            }
        }
        
        /*
         @available(iOS 11.0, *)
         func toHttpCookiePolicy() -> String? {
         switch self {
         case .unspecified: return nil
         case .lax: return "Lax"
         case .strict: return "Strict"
         case .no_restriction: return "None"
         }
         }
         */
    }
    
    private struct CookieObject: Decodable {
        let name: String
        let value: String
        let domain: String?
        let path: String?
        let secure: Bool?
        let httpOnly: Bool?
        let expirationDate: Int64?
        let sameSite: CookieSameSitePolicy?
    }
    
    func decodeCookie(from cookieJsonString: String, url: URL?) throws -> HTTPCookie? {
        guard let cookieJsonData = cookieJsonString.data(using: .utf8) else {
            throw CookieDecodeError.convertStringError
        }
        
        // Decode JSON Cookie into object
        let decoder = JSONDecoder()
        let cookieObject = try decoder.decode(CookieObject.self, from: cookieJsonData)
        
        // Create HTTPCookie object from cookieObject
        
        var cookieProperties: [HTTPCookiePropertyKey: Any] = [
            .name: cookieObject.name,
            .value: cookieObject.value,
        ]
        
        // Load 'path' property into cookie properties
        if cookieObject.path == nil, let url = url {
            cookieProperties[.path] = url.path
        } else if let cookieUrlPath = cookieObject.path {
            cookieProperties[.path] = cookieUrlPath
        } else {
            throw CookieDecodeError.noUrlPathError
        }
        
        // Load either 'domain' or 'url' into properties
        if let cookieDomain = cookieObject.domain {
            cookieProperties[.domain] = cookieDomain
        } else if let cookieUrl = url {
            cookieProperties[.originURL] = cookieUrl
        } else {
            throw CookieDecodeError.noDomainOrUrlError
        }
        
        // Load remaining optional properties
        cookieProperties[.secure] = cookieObject.secure
        cookieProperties[.httpOnly] = cookieObject.httpOnly
        cookieProperties[.expires] = cookieObject.expirationDate != nil
        
        // Expiration date
        if cookieObject.expirationDate != nil {
            cookieProperties[.maximumAge] = Date(timeIntervalSince1970: TimeInterval(cookieObject.expirationDate!)).timeIntervalSinceNow
        }
        
        // Same-site policy
        if #available(iOS 13.0, *) {
            cookieProperties[.sameSitePolicy] = cookieObject.sameSite?.toHttpCookiePolicy()
        }
        
        guard let cookie = HTTPCookie(properties: cookieProperties) else {
            fatalError("Error creating cookie object")
            return nil
        }
        
        return cookie
    }
}
