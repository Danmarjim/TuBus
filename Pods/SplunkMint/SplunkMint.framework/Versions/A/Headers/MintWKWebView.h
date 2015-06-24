//
//  MintWKWebView.h
//  Splunk-iOS
//
//  Created by Dharmalingam Madheswaran on 3/23/15.
//  Copyright (c) 2015 SLK. All rights reserved.
//



#import <WebKit/WebKit.h>

/**
 @class MintWKWebView
 @abstract WKWebView with built-in, WebView monitoring in your app to view Web pages.
 
 Mint.initAndStartSession('apiKey')
 Mint.logEvent('event name', {'key': 'value'})
 Mint.logView('view name', {'key': 'value'} )
 Mint.leaveBreadcrumb('breadcrumb1')
 Mint.transactionStart('transaction name', {'key': 'value'})
 Mint.transactionStop('transaction name', {'key': 'value'})
 Mint.transactionCancel('transaction name', 'reason for cancel', {'key': 'value'})
 Mint.addExtraData('key', 'value')
 Mint.clearExtraData()
 Mint.flush()
 Mint.startSession()
 Mint.closeSession()
 Mint.setUserIdentifier('username')
 **/

@interface MintWKWebView : WKWebView
- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration;
- (instancetype)initWithFrame:(CGRect)frame;
@end
