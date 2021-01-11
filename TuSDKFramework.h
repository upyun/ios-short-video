//
//  TuSDKFramework.h
//  TuSDKVideoDemo
//
//  Created by Yanlin on 3/5/16.
//  Copyright © 2016 TuSDK. All rights reserved.
//


//#import "TuSDK.h"
#import <TuSDK/TuSDK.h>
#import <TuSDKVideo/TuSDKVideo.h>
#import <TuSDKFace/TuSDKFace.h>

#import "UPYUNConfig.h"


#define HEXCOLOR(rgbvalue) [UIColor colorWithRed:(CGFloat)((rgbvalue&0xFF0000)>>16)/255.0 green:(CGFloat)((rgbvalue&0xFF00)>>8)/255.0 blue:(CGFloat)(rgbvalue&0xFF)/255.0 alpha:1]
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)
#define RANDOMCOLOR [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0]

#define UPWeakObj(o) __weak typeof(o) o##Weak = o;
#define UPStrongObj(o) __strong typeof(o) o = o##Weak;
