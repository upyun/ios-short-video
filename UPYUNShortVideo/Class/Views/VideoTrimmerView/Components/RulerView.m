//
//  RulerView.m
//  VideoTrimmer
//
//  Created by bqlin on 2018/6/12.
//  Copyright © 2018年 bqlin. All rights reserved.
//

#import "RulerView.h"

@implementation RulerView

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
    _scaleInterval = -1;
    _themeColor = [UIColor whiteColor];
}

- (void)drawRect:(CGRect)rect {
    if (_duration <= 0) return;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat width = CGRectGetWidth(self.frame);
    
    CGSize majorScaleSize = CGSizeMake(2, 7);
    CGSize minorScaleSize = CGSizeMake(1, 4);
    const CGFloat textLabelMargin = 2;
    const CGFloat majorScaleY = height - majorScaleSize.height;
    const CGFloat minorScaleY = height - minorScaleSize.height;
    
    CGFloat scaleWidth = width / self.duration * _scaleInterval;
    if (_scaleInterval < 0) {
        CGFloat contentWidth = width - _leftMargin - _rightMargin;
        // 刻度间隔过于窄时进行调整
        while (scaleWidth < 8) {
            _scaleInterval += 1;
            scaleWidth = contentWidth / self.duration * _scaleInterval;
        }
        // 刻度间隔过于宽时进行调整
        if (scaleWidth > 30) {
            _scaleInterval /= 5.0;
            scaleWidth = contentWidth / self.duration * _scaleInterval;
        }
    }
    
    NSInteger step = 0;
    for (CGFloat x = _leftMargin; x < width - _rightMargin; x += scaleWidth) {
        CGContextSetFillColorWithColor(context, self.themeColor.CGColor);
        // 每五个小刻度一个大刻度
        BOOL isMajorScale = step % 5 == 0;
        CGFloat y = isMajorScale ? majorScaleY : minorScaleY;
        CGSize size = isMajorScale ? majorScaleSize : minorScaleSize;
        if (isMajorScale) {
            // 绘制时间标签
            NSAttributedString *timeText = [self timeTextWithStep:step stepInterval:_scaleInterval];
            [timeText drawAtPoint:CGPointMake(x + size.width/2 - timeText.size.width/2, y - timeText.size.height - textLabelMargin)];
        }
        CGRect scaleRect = {{x, y,}, size};
        CGContextMoveToPoint(context, x, majorScaleY);
        // 绘制刻度
        CGContextFillRect(context, scaleRect);
        
        step++;
    }
}

/**
 大刻度时间文本

 @param step 刻度步数
 @param stepInterval 刻度步幅
 @return 时间文本
 */
- (NSAttributedString *)timeTextWithStep:(NSInteger)step stepInterval:(NSTimeInterval)stepInterval {
    //NSString *textString = [[[NSDateComponentsFormatter alloc] init] stringFromTimeInterval:step * stepInterval];
    NSString *textString = [self timeStringWithSeconds:step * stepInterval];
    NSDictionary *attributes =
    @{
      NSFontAttributeName: [UIFont systemFontOfSize:9],
      NSForegroundColorAttributeName: _themeColor
      };
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:textString attributes:attributes];
    return text.copy;
}

/**
 秒转字符串

 @param time 整数秒
 @return 时间字符串
 */
- (NSString *)timeStringWithSeconds:(NSInteger)time {
    if (isnan(time)) return nil;
    NSInteger minutes = (time / 60) % 60;
    NSInteger seconds = time % 60;
    if (minutes <= 0) return @(seconds).description;
    return [NSString stringWithFormat:@"%ld:%02ld", minutes, seconds];
}

#pragma mark - property

- (void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
    [self setNeedsDisplay];
}

@end
