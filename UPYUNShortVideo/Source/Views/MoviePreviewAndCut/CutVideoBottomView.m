//
//  CutVideoBottomView.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2017/3/13.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "CutVideoBottomView.h"
#import "TuSDKFramework.h"

/**
 视频裁剪页面底部栏视图
 */

@interface CutVideoBottomView ()<VideoClipViewDelegate>
{
    UILabel *_centerIntervalLabel;
    UILabel *_startTimeLabel;
    UILabel *_endTimeLabel;
   
    CGFloat startTime;
    CGFloat endTime;
}

@end


@implementation CutVideoBottomView

- (void)setTimeInterval:(CGFloat)timeInterval
{
    _timeInterval = timeInterval;
    if (endTime == 0) {
        _endTimeLabel.text = [self formatterTime:timeInterval];
        _centerIntervalLabel.text = [self formatterTime:timeInterval];
    }
    endTime = timeInterval;

    if (_clipView) {
        _clipView.timeInterval = timeInterval;
        
    }
}

- (void)setCurrentTime:(CGFloat)currentTime
{
    _currentTime = currentTime;
    if (_clipView) {
        _clipView.currentTime = currentTime;
    }
}

- (void)setThumbnails:(NSArray<UIImage *> *)thumbnails
{
    _thumbnails = thumbnails;
    if (_clipView) {
        _clipView.thumbnails = thumbnails;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createBottomView];
    }
    return self;
}

- (void)createBottomView
{
    // 时间间隔label
    _centerIntervalLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
    _centerIntervalLabel.center = CGPointMake(self.lsqGetSizeWidth/2, 32);
    _centerIntervalLabel.textAlignment = NSTextAlignmentCenter;
    _centerIntervalLabel.font = [UIFont systemFontOfSize:18];
    _centerIntervalLabel.text = NSLocalizedString(@"lsq_video_time_default", @"00:00");
    _centerIntervalLabel.textColor = kCustomYellowColor;
    [self addSubview:_centerIntervalLabel];
    
    // 开始时间label
    _startTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, _centerIntervalLabel.lsqGetOriginY + _centerIntervalLabel.lsqGetSizeHeight + 2, 150, 20)];
    _startTimeLabel.font = [UIFont systemFontOfSize:15];
    _startTimeLabel.textColor = lsqRGB(159, 160, 160);
    _startTimeLabel.text = NSLocalizedString(@"lsq_video_time_default",@"00:00");
    [self addSubview:_startTimeLabel];
    
    // 结束时间label
    _endTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.lsqGetSizeWidth - 170, _startTimeLabel.lsqGetOriginY, 150, 20)];
    _endTimeLabel.font = [UIFont systemFontOfSize:15];
    _endTimeLabel.textAlignment = NSTextAlignmentRight;
    _endTimeLabel.textColor = lsqRGB(159, 160, 160);
    _endTimeLabel.text = NSLocalizedString(@"lsq_video_time_default", @"00:00");
    [self addSubview:_endTimeLabel];

    _clipView = [[VideoClipView alloc]initWithFrame:CGRectMake(0, 0, self.lsqGetSizeWidth, 64)];
    _clipView.center = CGPointMake(self.lsqGetSizeWidth/2, self.lsqGetSizeHeight/2 + 20);
    _clipView.timeInterval = self.timeInterval;
    _clipView.clipDelegate = self;
    _clipView.minCutTime = 1.0;
    [self addSubview:_clipView];
}

- (NSString *)formatterTime:(CGFloat)second
{
    NSInteger integerSecond = (NSInteger)round(second);
    // 注意：最小单位为秒
    int theMinute = (int)(integerSecond / 60);
    int theSecond = integerSecond % 60;
    
    NSString *formatterTime = [NSString stringWithFormat:@"%02d:%02d",theMinute,theSecond];
    return formatterTime;
}

#pragma mark -- VideoClipViewDelegate

- (void)chooseTimeWith:(CGFloat)time withState:(lsqClipViewStyle)isStartStatus
{
    if (isStartStatus == lsqClipViewStyleLeft) {
        _startTimeLabel.text = [self formatterTime:time];
        startTime = time;
        self.currentTime = time;
    }else if(isStartStatus == lsqClipViewStyleRight){
        _endTimeLabel.text = [self formatterTime:time];
        endTime = time;
    }
    
    _centerIntervalLabel.text = [self formatterTime:endTime-startTime];
    
    if (_slipChangeTimeBlock) {
        self.slipChangeTimeBlock(time,isStartStatus);
    }
}


// 拖动结束事件
- (void)slipEndEvent
{
    if (_slipEndBlock) {
        self.slipEndBlock();
    }
}

// 拖动开始事件
- (void)slipBeginEvent
{
    if (_slipBeginBlock) {
        self.slipBeginBlock();
    }
}

@end


