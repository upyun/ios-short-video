//
//  MaskLayer.h
//  VideoTrimmer
//
//  Created by bqlin on 2018/6/12.
//  Copyright © 2018年 bqlin. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 遮罩图层
 */
@interface MaskLayer : CAShapeLayer

/**
 遮罩挖空的区域
 */
@property (nonatomic, assign) CGRect maskRect;

@end

/**
 外边框图层
 */
@interface BorderLayer : CAShapeLayer

/**
 添加边框的矩形
 */
@property (nonatomic, assign) CGRect borderRect;

@end
