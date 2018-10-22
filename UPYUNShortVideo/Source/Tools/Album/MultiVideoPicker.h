//
//  MultiVideoPicker.h
//  MultiVideoPicker
//
//  Created by bqlin on 2018/6/19.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface MultiVideoPicker : UIViewController

+ (instancetype)picker;

- (NSMutableArray<NSURL *> *)allSelectedAssets;

@end
