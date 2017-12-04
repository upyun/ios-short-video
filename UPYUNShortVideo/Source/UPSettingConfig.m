//
//  UPSettingConfig.m
//  UPYUNShortVideo
//
//  Created by lingang on 2017/11/10.
//  Copyright © 2017年 upyun. All rights reserved.
//

#import "UPSettingConfig.h"

@implementation UPSettingConfig


+ (UPSettingConfig *)defaultConfig {
    UPSettingConfig *config = [[UPSettingConfig alloc] init];
    
    config.minRecordingTime = 2;
    config.maxRecordingTime = 30;
    
    int width = 864;
    int heigth = 480;
    config.outputSize = CGSizeMake(width, heigth);
    config.lsqVideoBitRate = 512;
    config.frameRate = 20;
    config.watermarkPosition = 4;
    
    return config;
}

@end
