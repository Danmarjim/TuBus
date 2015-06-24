//
//  TBTwitterController.m
//  TuBus
//
//  Created by Daniel Martin Jimenez on 24/6/15.
//  Copyright (c) 2015 Daniel Martin Jimenez. All rights reserved.
//

#import "TBTwitterController.h"

@interface TBTwitterController ()

@end

@implementation TBTwitterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Timeline de Tussam";
    
    [[Twitter sharedInstance] logInGuestWithCompletion:^(TWTRGuestSession *guestSession, NSError *error) {
        if (guestSession) {
            TWTRAPIClient *APIClient = [[Twitter sharedInstance] APIClient];
            TWTRUserTimelineDataSource *userTimelineDataSource = [[TWTRUserTimelineDataSource alloc] initWithScreenName:@"@Angry_Tussam" APIClient:APIClient];
            self.dataSource = userTimelineDataSource;
        } else {
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];
}

@end
