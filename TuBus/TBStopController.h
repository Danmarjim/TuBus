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
#import <MoPub/MPAdView.h>
#import "AMSmoothAlertView.h"

@interface TBStopController : UIViewController <NSXMLParserDelegate, CustomIOSAlertViewDelegate,MPAdViewDelegate, MBProgressHUDDelegate>

@property (nonatomic, strong) CustomIOSAlertView *alertView;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, retain) MPAdView *adView;
@property (nonatomic, strong) AMSmoothAlertView * alert;

@property (weak, nonatomic) IBOutlet UITextField *valueLine;
@property (weak, nonatomic) IBOutlet UITextField *valueStop;

@property (weak, nonatomic) IBOutlet UITextField *valueTimeFirst;
@property (weak, nonatomic) IBOutlet UITextField *valueDistanceFirst;
@property (weak, nonatomic) IBOutlet UITextField *valueTimeSecond;
@property (weak, nonatomic) IBOutlet UITextField *valueDistanceSecond;

@property (nonatomic, strong) NSMutableArray *stopArrayMinutes;
@property (nonatomic, strong) NSMutableArray *stopArrayDistance;


@end
