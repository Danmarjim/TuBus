//
//  TBMapController.h
//  TuBus
//
//  Created by Daniel Martin Jimenez on 27/7/15.
//  Copyright (c) 2015 Daniel Martin Jimenez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "AFNetworking.h"
#import "GeodeticUTMConverter.h"
#import "CLPAddressAnnotation.h"
#import "APITussam.h"
#import "HMSideMenu.h"

@interface TBMapController : UIViewController <MKMapViewDelegate,  CLLocationManagerDelegate, NSXMLParserDelegate>

@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, strong) HMSideMenu *sideMenu;

@property (nonatomic, strong) NSMutableArray *arrayLat;
@property (nonatomic, strong) NSMutableArray *arrayLon;

@end
