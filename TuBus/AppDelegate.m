//
//  AppDelegate.m
//  TuBus
//
//  Created by Daniel Martin Jimenez on 7/6/15.
//  Copyright (c) 2015 Daniel Martin Jimenez. All rights reserved.
//
#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import <MoPub/MoPub.h>
#import "UIColor+MyColor.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //CONFIGURAR EL COLOR DE LA NAVBAR
    [[UINavigationBar appearance] setBarTintColor:[UIColor customColor]];
    
    //CONFIGURAR EL TEXTO DE LA NAVBAR
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIColor whiteColor], NSForegroundColorAttributeName,
                                      [UIColor blackColor], NSForegroundColorAttributeName,
                                      [UIFont fontWithName:@"OpenSans-Light" size:21], NSFontAttributeName,
                                      nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes: textTitleOptions];    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTranslucent:NO];
    
    //QUITA EL VALOR BACK Y EL TITULO DE LA NAVBAR
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)                                                          forBarMetrics:UIBarMetricsDefault];
    
    //VALORES DE LA STATUSBAR EN BLANCO
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //[Fabric with:@[TwitterKit]];
    [Fabric with:@[MoPubKit, TwitterKit]];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
