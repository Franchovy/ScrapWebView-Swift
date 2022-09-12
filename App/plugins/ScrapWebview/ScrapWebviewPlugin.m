//
//  ScrapWebviewPlugin.m
//  App
//
//  Created by Paul Antoine on 09/06/2022.
//

#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

CAP_PLUGIN(ScrapWebviewPlugin, "ScrapWebview",
					 CAP_PLUGIN_METHOD(create, CAPPluginReturnPromise);
					 CAP_PLUGIN_METHOD(destroy, CAPPluginReturnPromise);
					 CAP_PLUGIN_METHOD(replaceId, CAPPluginReturnPromise);
					 CAP_PLUGIN_METHOD(show, CAPPluginReturnPromise);
					 CAP_PLUGIN_METHOD(hide, CAPPluginReturnPromise);
					 CAP_PLUGIN_METHOD(getUrl, CAPPluginReturnPromise);
					 CAP_PLUGIN_METHOD(loadUrl, CAPPluginReturnPromise);
					 CAP_PLUGIN_METHOD(reloadPage, CAPPluginReturnPromise);
					 CAP_PLUGIN_METHOD(evaluateScript, CAPPluginReturnPromise);
					 CAP_PLUGIN_METHOD(getCookie, CAPPluginReturnPromise);
					 CAP_PLUGIN_METHOD(setCookie, CAPPluginReturnPromise);
					 
					 )
