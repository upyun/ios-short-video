//
//  CameraSpeedSegmentButton.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/24.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "CameraSpeedSegmentButton.h"

@implementation CameraSpeedSegmentButton

/**
 速率变换按钮
 */
- (void)commonInit {
    [super commonInit];
    self.style = SegmentButtonStyleSlideMask;
    self.cornerRadius = 15;
    self.buttonTitles = @[NSLocalizedStringFromTable(@"tu_极慢", @"VideoDemo", @"极慢"), NSLocalizedStringFromTable(@"tu_慢", @"VideoDemo", @"慢"), NSLocalizedStringFromTable(@"tu_标准", @"VideoDemo", @"标准"), NSLocalizedStringFromTable(@"tu_快", @"VideoDemo", @"快"), NSLocalizedStringFromTable(@"tu_极快", @"VideoDemo", @"极快")];
    self.selectedIndex = 2;
    self.backgroundColor = [UIColor colorWithRed:85/255.0 green:85/255.0 blue:85/255.0 alpha:.3];
    self.selectedBackgroundColor = [UIColor colorWithRed:255.0f/255.0f green:204.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
}

@end
