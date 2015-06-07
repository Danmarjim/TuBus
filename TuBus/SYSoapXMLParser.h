//
// Created by alik on 5/24/13.
// Copyright (c) 2013 dinamo. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface SYSoapXMLParser : NSObject <NSXMLParserDelegate>


+ (NSDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)error;

+ (NSDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)error;

+ (NSDictionary *)objectWithParser:(NSXMLParser *)parser error:(NSError **)error;
@end