//
//  MarkableProgressView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/3.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "MarkableProgressView.h"

@interface MarkableProgressView ()

/**
 标记的进度
 */
@property (nonatomic, strong) NSMutableArray<NSNumber *> *markedProgresses;

/**
 标记图层
 */
@property (nonatomic, strong) NSMutableArray<CALayer *> *markLayers;

@end

@implementation MarkableProgressView

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        [self commonInit];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.progressTintColor = [UIColor colorWithRed:255.0f/255.0f green:204.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    self.trackTintColor = [UIColor colorWithWhite:1 alpha:0.3];
    self.progress = 0;
    
    _markedProgresses = [NSMutableArray array];
    _markLayers = [NSMutableArray array];
}

/**
 占位视图
 
 @param progress 占位进度
 */
- (CALayer *)addPlaceholder:(CGFloat)progress markWidth:(CGFloat)markWidth;
{
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = [UIColor whiteColor].CGColor;
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    layer.frame = CGRectMake(width * progress - markWidth, 0, markWidth, height);
    [self.layer addSublayer:layer];
    
    return layer;
}

#pragma mark - public

- (void)pushMark {
    [_markedProgresses addObject:@(self.progress)];
    CALayer *layer = [self addPlaceholder:self.progress markWidth:CGRectGetHeight(self.bounds)/2];
    [_markLayers addObject:layer];
}

- (void)popMark {
    if (_markedProgresses.count == 0) return;
    [_markedProgresses removeLastObject];
    [_markLayers removeLastObject];
    self.progress = _markedProgresses.lastObject.floatValue;
    [self.layer.sublayers.lastObject removeFromSuperlayer];
}

- (void)reset {
    for (CALayer *layer in _markLayers) {
        [layer removeFromSuperlayer];
    }
    _markedProgresses = [NSMutableArray array];
    _markLayers = [NSMutableArray array];
    self.progress = 0;
}

@end
