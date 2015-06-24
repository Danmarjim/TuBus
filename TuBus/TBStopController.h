//
//  TBStopController.h
//  TuBus
//
//  Created by Daniel Martin Jimenez on 10/6/15.
//  Copyright (c) 2015 Daniel Martin Jimenez. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "APITussam.h"
#import "CustomIOSAlertView.h"
#import "UIColor+MyColor.h"
#import "MBProgressHUD.h"

@interface TBStopController : UIViewController <NSXMLParserDelegate, CustomIOSAlertViewDelegate>

@property (nonatomic, strong) CustomIOSAlertView *alertView;

@property (weak, nonatomic) IBOutlet UITextField *valueLine;
@property (weak, nonatomic) IBOutlet UITextField *valueStop;

@property (weak, nonatomic) IBOutlet UITextField *valueTimeFirst;
@property (weak, nonatomic) IBOutlet UITextField *valueDistanceFirst;
@property (weak, nonatomic) IBOutlet UITextField *valueTimeSecond;
@property (weak, nonatomic) IBOutlet UITextField *valueDistanceSecond;

@property (nonatomic, strong) NSMutableArray *stopArrayMinutes;
@property (nonatomic, strong) NSMutableArray *stopArrayDistance;


@end
