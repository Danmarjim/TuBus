//
//  APITussam.h
//  TuBus
//
//  Created by Daniel Martin Jimenez on 12/6/15.
//  Copyright (c) 2015 Daniel Martin Jimenez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APITussam : NSObject <NSXMLParserDelegate>

//DINAMICA.asmx
- (void)getPasoParada:(NSString *)line stop:(NSString *)stop;
- (void)getVehiculos:(NSString *)line;

//ESTRUCTURA.asmx
- (void)getLines;
- (void)getNodosMapSublinea:(NSString *)line;
- (void)getPolylineaSublinea:(NSString *)line;
- (void)getRutasSublinea:(NSString *)line;
- (void)getTiposNodosMap;
- (void)getTopoSublinea:(NSString *)line;
- (void)searchNode:(NSString *)line;

@end
