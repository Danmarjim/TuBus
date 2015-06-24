//
//  UIColor+MyColor.m
//  CIVIS
//
//  Created by Daniel Martin Jimenez on 8/5/15.
//  Copyright (c) 2015 Daniel Martin Jimenez. All rights reserved.
//

#import "UIColor+MyColor.h"

@implementation UIColor (MyColor)

+ (instancetype)customColor
{
    return [UIColor colorWithRed:250.0/255.0 green:88.0/255.0 blue:88.0/255.0 alpha:1.0];
}

+ (instancetype)customColorTextAlert
{
    return [UIColor colorWithRed:49.0/255.0 green:49.0/255.0 blue:49.0/255.0 alpha:0.5];
}

@end
