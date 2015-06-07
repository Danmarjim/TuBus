//
//  SYSoapClient.m
//  BestSoapTool
//
//  Created by Serdar YILLAR on 12/28/12.
//  Copyright (c) 2012 yillars. All rights reserved.
//

#import <AFNetworking/AFHTTPClient.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import <AFNetworking/AFXMLRequestOperation.h>
#import <objc/runtime.h>
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "SYSoapXMLParser.h"
#import "SYSoapClient.h"

static char functionNameKey;
static char callbackKey;

@implementation SYSoapClient {

		NSURLConnection *theConnection;
		NSMutableData   *receivedData;
		NSXMLParser     *XParser;
		NSString        *LaStr;
		NSMutableArray  *resultArray;

		NSString       *_functionName;
		NSString       *_soapUrl;
		NSMutableArray *_tags;
		NSMutableArray *_vars;

		AFHTTPClient           *_af_client;
		NSMutableURLRequest    *_af_request;
		AFHTTPRequestOperation *_af_operation;
		UIAlertView            *_alertView;
	}

	+ ( SYSoapClient * )instance {
		static SYSoapClient *_instance = nil;

		@synchronized ( self ) {
			if ( _instance == nil) {
				_instance = [[self alloc] init];
			}
		}

		return _instance;
	}

	- ( id )init {
		self = [super init];
		if ( self ) {
			_af_client = [[AFHTTPClient alloc] initWithBaseURL:[[NSURL alloc] initWithString:@""]];
			[_af_client registerHTTPOperationClass:[AFXMLRequestOperation class]];

			[_af_client.operationQueue setMaxConcurrentOperationCount:1];
		}

		return self;
	}

	- ( void )callSoapServiceWithoutParameters__functionName:( NSString * )___functionName callback:( void (^)(NSDictionary *result, BOOL) )callback {
		int __status = 0;
		_functionName = ___functionName;
		_soapUrl      = [NSString stringWithFormat:@"%@%@", DOMAIN_URL, WSDL_PATH];

		[self makeOperationwithStatus:__status];
		objc_setAssociatedObject(_af_request, &callbackKey, callback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		[self doSoapCall:callback];
	}

	- ( void )callSoapServiceWithParameters__functionName:( NSString * )___functionName tags:( NSMutableArray * )___tags vars:( NSMutableArray * )___vars callback:( void (^)(NSDictionary *result, BOOL) )callback {

		assert(___tags.count == ___vars.count);

		_functionName = ___functionName;
		_soapUrl      = [NSString stringWithFormat:@"%@%@", DOMAIN_URL, WSDL_PATH];
		_tags         = ___tags;
		_vars         = ___vars;

		int __status = 1;

		[self makeOperationwithStatus:__status];
		objc_setAssociatedObject(_af_request, &callbackKey, callback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		[self doSoapCall:callback];
	}

	- ( void )doSoapCall:( void (^)(id, BOOL) )_callback {
		if ( _alertView ) {
			return;
		};

		void (^__block success_block) (NSURLRequest *, NSHTTPURLResponse *, NSXMLParser *) = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {

			NSString *call_function = (NSString *) objc_getAssociatedObject(request, &functionNameKey);
			void (^callback) (id, BOOL) = objc_getAssociatedObject(request, &callbackKey);

			NSDictionary *data        = [SYSoapXMLParser objectWithParser:XMLParser error:NULL ];
			id           result2      = [data valueForKeyPath:[NSString stringWithFormat:@"soap:Envelope.soap:Body.%@Response.%@Result", call_function, call_function]];
			NSString     *result_code = [result2 valueForKeyPath:@"returnCode.text"];
			if ( [result_code isEqualToString:@"25"] ) {
#ifdef CONFIGURATION_Debug
				UIAlertView *alertView = [[UIAlertView alloc]
													   initWithTitle:@"Server error code" message:[result2 valueForKeyPath:@"returnCode.text"]];
				[alertView addButtonWithTitle:@"Ok"];
				[alertView show];

#endif

				[[NSNotificationCenter defaultCenter] postNotificationName:@"" object:nil];
			} else {
				_callback(result2, [result_code isEqualToString:@"0"]);
			}

			objc_removeAssociatedObjects(request);
		};

		void (^__block failure_block) (NSURLRequest *, NSHTTPURLResponse *, NSError *, NSXMLParser *) = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
			NSLog(@"failure with error %@", error);

			if ( !_alertView ) {
				_alertView = [[UIAlertView alloc]
										   initWithTitle:@"Connection Error!" message:error.localizedDescription];
				[_alertView addButtonWithTitle:@"Ok" handler:^{
					_alertView = nil;
				}];

				[_alertView show];
			}



//			NSString *call_function = (NSString *) objc_getAssociatedObject(request, &functionNameKey);
			void (^callback) (id, BOOL) = objc_getAssociatedObject(request, &callbackKey);

			//        [self performBlock:^(id sender) {

			_callback(nil, NO);
			objc_removeAssociatedObjects(request);
			//        }       afterDelay:5.f];

		};

		_af_operation = [AFXMLRequestOperation XMLParserRequestOperationWithRequest:_af_request success:success_block failure:failure_block];
		[_af_operation setCacheResponseBlock:^NSCachedURLResponse * (NSURLConnection *connection, NSCachedURLResponse *cachedResponse) {
			NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) [cachedResponse response];

			// Look up the cache policy used in our request
			if ( [connection currentRequest].cachePolicy == NSURLRequestUseProtocolCachePolicy ) {
				NSDictionary *headers      = [httpResponse allHeaderFields];
				NSString     *cacheControl = [headers valueForKey:@"Cache-Control"];
				NSString     *expires      = [headers valueForKey:@"Expires"];

				if ( ( cacheControl == nil) && ( expires == nil) ) {
					NSLog(@"server does not provide expiration information and we are using NSURLRequestUseProtocolCachePolicy");
					return nil; // don't cache this
				}
			}
			return cachedResponse;
		}];

		[_af_client enqueueHTTPRequestOperation:_af_operation];
	}

	- ( void )makeOperationwithStatus:( int )__status {
		NSLog(@">> %@", _functionName);
		_af_request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_soapUrl]];
		[_af_request setTimeoutInterval:15];
		[_af_request setCachePolicy:NSURLRequestUseProtocolCachePolicy];

		NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithCapacity:0];

		[headers setObject:@"text/xml" forKey:@"Content-Type"];
		[headers setObject:@"utf-8" forKey:@"charset"];
		[headers setObject:@"tr" forKey:@"Lang"];
		[headers setObject:[NSString stringWithFormat:@"http://tempuri.org/%@", _functionName] forKey:@"SOAPAction"];
		[headers setObject:@"Mac OS X; WebServicesCore.framework (1.0.0)" forKey:@"User-Agent"];

		objc_setAssociatedObject(_af_request, &functionNameKey, _functionName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

		[_af_request setAllHTTPHeaderFields:headers];
		[_af_request setHTTPMethod:@"POST"];

		NSMutableString *log = [NSMutableString string];

		[log appendString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-radioKit\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
				"<soap:Body>"];

		if ( __status == 1 ) {
			[log appendString:[NSString stringWithFormat:@"\n<%@ xmlns=\"http://tempuri.org/\">\n", _functionName]];
		} else {
			[log appendString:[NSString stringWithFormat:@"\n<%@ xmlns=\"http://tempuri.org/\"/>", _functionName]];
		}

		for ( int i = 0; i < [_tags count]; i++ ) {

			if ( __status == 1 ) {
				NSString *strResult = [NSString stringWithFormat:@"<%@><![CDATA[%@]]></%@>", [_tags objectAtIndex:i], [_vars objectAtIndex:i], [_tags objectAtIndex:i]];

				[log appendString:strResult];
			}

		}

		if ( __status == 1 ) {
			[log appendString:[NSString stringWithFormat:@"\n</%@>\n</soap:Body>\n</soap:Envelope>", _functionName]];
		} else {
			[log appendString:[NSString stringWithFormat:@"\n</soap:Body>\n</soap:Envelope>"]];
		}

		NSData *aData;
		aData = [log dataUsingEncoding:NSUTF8StringEncoding];

		[_af_request setHTTPBody:aData];
	}

@end
