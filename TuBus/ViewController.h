//
//  ViewController.h
//  TuBus
//
//  Created by Daniel Martin Jimenez on 7/6/15.
//  Copyright (c) 2015 Daniel Martin Jimenez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SOAPEngine64/SOAPEngine.h>

@interface ViewController : UIViewController <SOAPEngineDelegate>
{
    SOAPEngine *soap;
    NSMutableArray *list;
}

@property (weak, nonatomic) IBOutlet UITextField *valueLine;
@property (weak, nonatomic) IBOutlet UITextField *valueStop;

@property (weak, nonatomic) IBOutlet UITextField *valueTimeFirst;
@property (weak, nonatomic) IBOutlet UITextField *valueDistanceFirst;
@property (weak, nonatomic) IBOutlet UITextField *valueTimeSecond;
@property (weak, nonatomic) IBOutlet UITextField *valueDistanceSecond;

@property (nonatomic, strong) NSMutableArray *stopArrayMinutes;
@property (nonatomic, strong) NSMutableArray *stopArrayDistance;

@end

