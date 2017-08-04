//
//  CustomTuSDKCPRegionHandler.m
//  TuSDKDemo
//
//  Created by Lasque on 16/6/2.
//  Copyright © 2016年 Lasque. All rights reserved.
//

#import "CustomTuSDKCPRegionHandler.h"

@implementation CustomTuSDKCPRegionDefaultHandler

/**
 *  选区范围百分比
 */
- (CGRect)rectPercent;
{
    NSUInteger topBarHeight = 74;
    CGRect rect = [UIScreen mainScreen].bounds;
    return CGRectMake(0, topBarHeight/rect.size.height, 1.0, (rect.size.width)/rect.size.height);
}

@end
