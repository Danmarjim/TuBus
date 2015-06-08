//
//  ViewController.m
//  TuBus
//
//  Created by Daniel Martin Jimenez on 7/6/15.
//  Copyright (c) 2015 Daniel Martin Jimenez. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property NSXMLParser *parser;
@property NSString *element;

//Stop properties
@property NSNumber *currentMinutos;
@property NSNumber *currentMetros;

@end

@implementation ViewController

static UILabel *label;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    list = [NSMutableArray new];
    soap = [[SOAPEngine alloc] init];
    
    soap.userAgent = @"SOAPEngine";
    //soap.licenseKey = @"eJJDzkPK9Xx+p5cOH7w0Q+AvPdgK1fzWWuUpMaYCq3r1mwf36Ocw6dn0+CLjRaOiSjfXaFQBWMi+TxCpxVF/FA==";
    soap.delegate = self;
    soap.actionNamespaceSlash = YES;
    
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)doService
{
    [self loadData];
}

-(void)loadData
{
    [soap setValue:_valueLine.text forKey:@"linea"];
    [soap setValue:_valueStop.text forKey:@"parada"];
    [soap setIntegerValue:1 forKey:@"status"];
    
    [soap requestURL:@"http://www.infobustussam.com:9001/services/dinamica.asmx"
          soapAction:@"http://tempuri.org/GetPasoParada"];
}

#pragma mark - SOPAEngine delegates

- (void)soapEngine:(SOAPEngine *)soapEngine didFailWithError:(NSError *)error {
    
    //NSString *msg = [NSString stringWithFormat:@"ERROR: %@", error.localizedDescription];
}

- (void)soapEngine:(SOAPEngine *)soapEngine didFinishLoading:(NSString *)stringXML
{
    NSDictionary *result = [soapEngine dictionaryValue];
    list = [[NSMutableArray alloc] initWithArray:[result valueForKey:@"Hola"]];
    
    if (list.count > 0) {
        label = [[UILabel alloc] initWithFrame:(CGRect){0, 0, 320, 50}];
        label.backgroundColor = [UIColor yellowColor];
        [self.view addSubview:label];
        [label setText:[[list firstObject] valueForKey:@"Lineas"]];
    } else {
        
        NSLog(@"%@", stringXML);
    }
    
    NSLog(@"%@", stringXML);
    
    NSData *data = [stringXML dataUsingEncoding:NSUTF8StringEncoding];
    
    self.parser = [[NSXMLParser alloc] initWithData:data];
    self.parser.delegate = self;
    [self.parser parse];
    
    //Recoger los valores parseados del xml y mostrarlos por pantalla.
    
    [self.valueTimeFirst setText:[NSString stringWithFormat:@"%@", [self.stopArrayMinutes objectAtIndex:0]]];
    [self.valueTimeSecond setText:[NSString stringWithFormat:@"%@", [self.stopArrayMinutes objectAtIndex:1]]];
    [self.valueDistanceFirst setText:[NSString stringWithFormat:@"%@", [self.stopArrayDistance objectAtIndex:0]]];
    [self.valueDistanceSecond setText:[NSString stringWithFormat:@"%@", [self.stopArrayDistance objectAtIndex:1]]];
}

- (BOOL)soapEngine:(SOAPEngine *)soapEngine didReceiveResponseCode:(NSInteger)statusCode
{
    // 200 is response Ok, 500 Server error
    // see http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
    // for more response codes
    if (statusCode != 200 && statusCode != 500) {
        //NSString *msg = [NSString stringWithFormat:@"ERROR: received status code %li", (long)statusCode];
        return NO;
    }
    
    return YES;
}

- (NSMutableURLRequest*)soapEngine:(SOAPEngine *)soapEngine didBeforeSendingURLRequest:(NSMutableURLRequest *)request
{
    // use this delegate for personalize the header of the request
    // eg: [request setValue:@"my-value" forHTTPHeaderField:@"my-header-field"];
    
    NSLog(@"%@", [request allHTTPHeaderFields]);
    
    NSString *xml = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSASCIIStringEncoding];
    NSLog(@"%@", xml);
    
    return request;
}

- (NSString *)soapEngine:(SOAPEngine *)soapEngine didBeforeParsingResponseString:(NSString *)stringXML
{
    // use this delegate for change the xml response before parsing it.
    return stringXML;
}

-(void)dismissKeyboard
{
    [_valueLine resignFirstResponder];
    [_valueStop resignFirstResponder];
}

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
