//
//  TBStopController.m
//  TuBus
//
//  Created by Daniel Martin Jimenez on 10/6/15.
//  Copyright (c) 2015 Daniel Martin Jimenez. All rights reserved.
//

#import "TBStopController.h"
#import "AFNetworking.h"

@interface TBStopController ()

@property NSXMLParser *parser;
@property NSString *element;

//Stop properties
@property NSNumber *currentMinutos;
@property NSNumber *currentMetros;

@end

@implementation TBStopController

static UILabel *label;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"TuBus";
    
    //Dismiss keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    //Not Editable response TextFields
    [_valueDistanceFirst setEnabled:NO];
    [_valueDistanceSecond setEnabled:NO];
    [_valueTimeFirst setEnabled:NO];
    [_valueTimeSecond setEnabled:NO];
    
    self.stopArrayMinutes = [[NSMutableArray alloc] init];
    self.stopArrayDistance = [[NSMutableArray alloc] init];
    
    
    //Servicio para obtener todas las lineas operativas de TUSSAM
    [self getLines];
    
    //Servicio para obtener los tiempo dada una parada y una linea
    //[self getParadas];
    
}

-(void)getParadas
{
    NSURL *baseURL = [NSURL URLWithString:@"http://www.infobustussam.com:9001/services/dinamica.asmx"];
    
    NSString *soapBody = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><XGetPasoParada xmlns=\"http://tempuri.org/\"><parada>%@</parada><status>1</status></XGetPasoParada></soap:Body></soap:Envelope>", @"053"];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request addValue:@"http://tempuri.org/XGetPasoParada" forHTTPHeaderField:@"SOAPAction"];
    
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // do whatever you'd like here; for example, if you want to convert
        // it to a string and log it, you might do something like:
        
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@", string);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
    }];
    
    
    [operation start];
}

-(void)getLines
{
    NSURL *baseURL = [NSURL URLWithString:@"http://www.infobustussam.com:9001/services/estructura.asmx"];
    
    NSString *soapBody = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><GetLineas xmlns=\"http://tempuri.org/\" /></soap:Body></soap:Envelope>"];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request addValue:@"http://tempuri.org/GetLineas" forHTTPHeaderField:@"SOAPAction"];
    
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // do whatever you'd like here; for example, if you want to convert
        // it to a string and log it, you might do something like:
        
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@", string);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
    }];
    
    
    [operation start];
}

-(IBAction)doService
{
    [self loadData];
}

-(void)loadData
{
    [self.stopArrayDistance removeAllObjects];
    [self.stopArrayMinutes removeAllObjects];
    
    NSURL *baseURL = [NSURL URLWithString:@"http://www.infobustussam.com:9001/services/dinamica.asmx"];
    
    NSString *soapBody = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body><GetPasoParada xmlns=\"http://tempuri.org/\"><linea>%@</linea><parada>%@</parada><status>1</status></GetPasoParada></soap:Body></soap:Envelope>", self.valueLine.text, self.valueStop.text];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request addValue:@"http://tempuri.org/GetPasoParada" forHTTPHeaderField:@"SOAPAction"];
    
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // do whatever you'd like here; for example, if you want to convert
        // it to a string and log it, you might do something like:
        
        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        self.parser = [[NSXMLParser alloc] initWithData:data];
        self.parser.delegate = self;
        [self.parser parse];
        
        //Get the values from xml and display on the screen.
        
        [self.valueTimeFirst setText:[NSString stringWithFormat:@"%@", [self.stopArrayMinutes objectAtIndex:0]]];
        [self.valueTimeSecond setText:[NSString stringWithFormat:@"%@", [self.stopArrayMinutes objectAtIndex:1]]];
        [self.valueDistanceFirst setText:[NSString stringWithFormat:@"%@", [self.stopArrayDistance objectAtIndex:0]]];
        [self.valueDistanceSecond setText:[NSString stringWithFormat:@"%@", [self.stopArrayDistance objectAtIndex:1]]];
        
        NSLog(@"%@", string);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
    }];
    
    
    [operation start];
}

//Method for dismiss KEYBOARD

-(void)dismissKeyboard
{
    [_valueLine resignFirstResponder];
    [_valueStop resignFirstResponder];
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
    if([self.element isEqualToString:@"minutos"]){
        self.currentMinutos = [NSNumber numberWithInt:string.intValue];
    } else if([self.element isEqualToString:@"metros"]){
        self.currentMetros = [NSNumber numberWithInt:string.intValue];
    }
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"minutos"]){
        [self.stopArrayMinutes addObject:self.currentMinutos];
    } else if ([elementName isEqualToString:@"metros"]){
        [self.stopArrayDistance addObject:self.currentMetros];
    }
    self.element = nil;
}

@end
