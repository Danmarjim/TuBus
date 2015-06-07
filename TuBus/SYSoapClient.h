//
//  SYSoapClient.h
//  BestSoapTool
//
//  Created by Serdar YILLAR on 12/28/12.
//  Copyright (c) 2012 yillars. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class NSMutableArray;
@class SYSoapClient;

@interface SYSoapClient : NSObject <NSXMLParserDelegate>

	+ ( SYSoapClient * )instance;

	- ( void )callSoapServiceWithParameters__functionName:( NSString * )___functionName tags:( NSMutableArray * )___tags vars:( NSMutableArray * )___vars callback:( void (^)(NSDictionary *result, BOOL response) )callback;

	- ( void )callSoapServiceWithoutParameters__functionName:( NSString * )___functionName callback:( void (^)(NSDictionary *result, BOOL response) )callback;

@end
