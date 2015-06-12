//
//  TBMainController.m
//  TuBus
//
//  Created by Daniel Martin Jimenez on 10/6/15.
//  Copyright (c) 2015 Daniel Martin Jimenez. All rights reserved.
//
#import "TBMainController.h"
#import "AFNetworking.h"
#import "GeodeticUTMConverter.h"
#import "CLPAddressAnnotation.h"
#import "APITussam.h"

@interface TBMainController ()

@property NSXMLParser *parser;
@property NSString *element;

@property NSNumber *currentLon;
@property NSNumber *currentLat;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *arrayCoord;
@property (nonatomic, strong) NSUserDefaults *userData;

@end

@implementation TBMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _mapView.delegate = self;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization];
    
    [self.locationManager startUpdatingLocation];
    
    _mapView.showsUserLocation = YES;
    [_mapView setMapType:MKMapTypeStandard];
    [_mapView setZoomEnabled:YES];
    [_mapView setScrollEnabled:YES];

    self.arrayLon = [[NSMutableArray alloc] init];
    self.arrayLat = [[NSMutableArray alloc] init];
    self.arrayCoord = [[NSMutableArray alloc] init];
    self.userData = [NSUserDefaults standardUserDefaults];
    
    //Service to get all lines from TUSSAM
    //[self getLines];
    
    //Every each 10 seconds call the service and update the location of buses.
    //[self getVehiculos];
    
    //self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getVehiculos) userInfo:nil repeats:YES];
    
    //Services request to get all stops. Filter by line.
    //[self getNodosMapSublinea];
    
    //Service request to get Polyline. Filter by line, after that i can display on the mapView.
    //[self getPolylineaSublinea];
    
    //Service to get "El itinerario" for each line
    //[self getRutasSublinea];
    
    //Service NULL
    //[self getTiposNodosMap];
    
    //Service to
    //[self getTopoSublinea];
    
    //Service to
    //[self searchNode];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    //View Area
    MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = self.locationManager.location.coordinate.latitude;
    region.center.longitude = self.locationManager.location.coordinate.longitude;
    region.span.longitudeDelta = 0.005f;
    region.span.longitudeDelta = 0.005f;
    [_mapView setRegion:region animated:YES];
}

-(void)getVehiculos
{
    //Remove all items from arrays
    [self.arrayLat removeAllObjects];
    [self.arrayLon removeAllObjects];
    
    NSURL *baseURL = [NSURL URLWithString:@"http://www.infobustussam.com:9001/services/dinamica.asmx"];
    
    NSString *soapBody = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><GetVehiculos xmlns=\"http://tempuri.org/\"><linea>%@</linea></GetVehiculos></soap:Body></soap:Envelope>", @"01"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request addValue:@"http://tempuri.org/GetVehiculos" forHTTPHeaderField:@"SOAPAction"];
    
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        self.parser = [[NSXMLParser alloc] initWithData:data];
        self.parser.delegate = self;
        [self.parser parse];
        
        //Remover all annotations befora add new ones
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        //Add new annotations
        UTMCoordinates coordinates;
        coordinates.gridZone = 30;
        
        for(int i=0; i<self.arrayLat.count; i++) {
            coordinates.northing = [[self.arrayLat objectAtIndex:i] doubleValue];
            coordinates.easting = [[self.arrayLon objectAtIndex:i] doubleValue];
            coordinates.hemisphere = kUTMHemisphereNorthern;
            
            GeodeticUTMConverter *converter = [[GeodeticUTMConverter alloc] init];
            CLLocationCoordinate2D testMark = [converter UTMCoordinatesToLatitudeAndLongitude:coordinates];
            
            CLPAddressAnnotation *annotationAddress = [[CLPAddressAnnotation alloc] initWithCoordinate:testMark];
            [self.arrayCoord addObject:annotationAddress];
            
            [self.mapView addAnnotation:annotationAddress];
        }

        NSLog(@"%@", string);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
    }];   
    
    [operation start];
}

-(void)getLines
{
    APITussam *api = [APITussam alloc];
    [api getLines];
}

-(void)getNodosMapSublinea
{
    NSURL *baseURL = [NSURL URLWithString:@"http://www.infobustussam.com:9001/services/estructura.asmx"];
    
    NSString *soapBody = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><GetNodosMapSublinea xmlns=\"http://tempuri.org/\"><label>%@</label><sublinea>1</sublinea></GetNodosMapSublinea></soap:Body></soap:Envelope>", @"01"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request addValue:@"http://tempuri.org/GetNodosMapSublinea" forHTTPHeaderField:@"SOAPAction"];
    
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];

        NSLog(@"%@", string);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
    }];
    
    [operation start];
}

-(void)getPolylineaSublinea
{
    //Remove all items from arrays
    [self.arrayLat removeAllObjects];
    [self.arrayLon removeAllObjects];
    
    NSURL *baseURL = [NSURL URLWithString:@"http://www.infobustussam.com:9001/services/estructura.asmx"];
    
    NSString *soapBody = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><GetPolylineaSublinea xmlns=\"http://tempuri.org/\"><label_linea>%@</label_linea><num_sublinea>1</num_sublinea></GetPolylineaSublinea></soap:Body></soap:Envelope>", @"01"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request addValue:@"http://tempuri.org/GetPolylineaSublinea" forHTTPHeaderField:@"SOAPAction"];
    
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        self.parser = [[NSXMLParser alloc] initWithData:data];
        self.parser.delegate = self;
        [self.parser parse];
        
        //Remover all annotations befora add new ones
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        //Add new annotations
        UTMCoordinates coordinates;
        coordinates.gridZone = 30;
        
        for(int i=0; i<self.arrayLat.count; i++) {
            coordinates.northing = [[self.arrayLat objectAtIndex:i] doubleValue];
            coordinates.easting = [[self.arrayLon objectAtIndex:i] doubleValue];
            coordinates.hemisphere = kUTMHemisphereNorthern;
            
            GeodeticUTMConverter *converter = [[GeodeticUTMConverter alloc] init];
            CLLocationCoordinate2D testMark = [converter UTMCoordinatesToLatitudeAndLongitude:coordinates];
            
            CLPAddressAnnotation *annotationAddress = [[CLPAddressAnnotation alloc] initWithCoordinate:testMark];
            [self.arrayCoord addObject:annotationAddress];
            
            [self drawRoute:self.arrayCoord];
        }

        NSLog(@"%@", string);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
    }];
    
    [operation start];
}

-(void)getRutasSublinea
{
    NSURL *baseURL = [NSURL URLWithString:@"http://www.infobustussam.com:9001/services/estructura.asmx"];
    
    NSString *soapBody = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><GetRutasSublinea xmlns=\"http://tempuri.org/\"><label>%@</label><sublinea>1</sublinea></GetRutasSublinea></soap:Body></soap:Envelope>", @"01"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request addValue:@"http://tempuri.org/GetRutasSublinea" forHTTPHeaderField:@"SOAPAction"];
    
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@", string);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
    }];
    
    [operation start];
}

-(void)getTiposNodosMap
{
    NSURL *baseURL = [NSURL URLWithString:@"http://www.infobustussam.com:9001/services/estructura.asmx"];
    
    NSString *soapBody = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><GetTiposNodosMap xmlns=\"http://tempuri.org/\" /></soap:Body></soap:Envelope>"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request addValue:@"http://tempuri.org/GetTiposNodosMap" forHTTPHeaderField:@"SOAPAction"];
    
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@", string);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
    }];
    
    [operation start];
}

-(void)getTopoSublinea
{
    NSURL *baseURL = [NSURL URLWithString:@"http://www.infobustussam.com:9001/services/estructura.asmx"];
    
    NSString *soapBody = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><GetTopoSublinea xmlns=\"http://tempuri.org/\"><label>%@</label><sublinea>1</sublinea></GetTopoSublinea></soap:Body></soap:Envelope>", @"01"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request addValue:@"http://tempuri.org/GetTopoSublinea" forHTTPHeaderField:@"SOAPAction"];
    
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@", string);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
    }];
    
    [operation start];
}

-(void)searchNode
{
    NSURL *baseURL = [NSURL URLWithString:@"http://www.infobustussam.com:9001/services/estructura.asmx"];
    
    NSString *soapBody = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><SearchNode xmlns=\"http://tempuri.org/\"><substring>%@</substring></SearchNode></soap:Body></soap:Envelope>", @"01"];    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request addValue:@"http://tempuri.org/SearchNode" forHTTPHeaderField:@"SOAPAction"];
    
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@", string);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
    }];
    
    [operation start];
}

//Update the mapview
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:NO];
}

//Here draw and update the polylines
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor redColor];
    polylineView.lineWidth = 3.0;
    
    return polylineView;
}

- (NSString *)deviceLocation {
    return [NSString stringWithFormat:@"latitude: %f longitude: %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
}
- (NSString *)deviceLat {
    return [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.latitude];
}
- (NSString *)deviceLon {
    return [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.longitude];
}
- (NSString *)deviceAlt {
    return [NSString stringWithFormat:@"%f", self.locationManager.location.altitude];
}

//Method when we get the coordinates and draw the polyline
- (void)drawRoute:(NSArray *)path
{
    NSInteger numberOfSteps = path.count;
    
    CLLocationCoordinate2D coordinates[numberOfSteps];
    for (NSInteger index = 0; index < numberOfSteps; index++) {
        CLLocation *location = [path objectAtIndex:index];
        CLLocationCoordinate2D coordinate = location.coordinate;
        
        coordinates[index] = coordinate;
    }
    
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
    [self.mapView addOverlay:polyLine];
}

//Methods for XML Parser
- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict
{
    self.element = elementName;
}

- (void)parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string
{
    if([self.element isEqualToString:@"xcoord"]){
        self.currentLon = [NSNumber numberWithInt:string.intValue];
    } else if([self.element isEqualToString:@"ycoord"]){
        self.currentLat = [NSNumber numberWithInt:string.intValue];
    } else if([self.element isEqualToString:@"x"]){
        self.currentLon = [NSNumber numberWithInt:string.intValue];
    } else if([self.element isEqualToString:@"y"]){
        self.currentLat = [NSNumber numberWithInt:string.intValue];
    }
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"xcoord"]){
        [self.arrayLon addObject:self.currentLon];
    } else if ([elementName isEqualToString:@"ycoord"]){
        [self.arrayLat addObject:self.currentLat];
    } else if([self.element isEqualToString:@"x"]){
        [self.arrayLon addObject:self.currentLon];
    } else if([self.element isEqualToString:@"y"]){
        [self.arrayLat addObject:self.currentLat];
    }
    self.element = nil;
}

@end
