//
//  ColorSlider.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/5.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "ColorSlider.h"

// 滑块宽度
static const CGFloat kThumbWidth = 16.0;
// 滑块边框宽度
static const CGFloat kThumbBorderWidth = 2.0;
// 轨道高度
static const CGFloat kTrackHeight = 2.0;

@interface ColorSlider()

/**
 轨道视图
 */
@property (nonatomic, strong) UIView *trackView;

/**
 轨道图片
 */
@property (nonatomic, strong) UIImage *trackImage;

/**
 滑块视图
 */
@property (nonatomic, strong) CAShapeLayer *thumbLayer;

@end


@implementation ColorSlider

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    _trackView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:_trackView];
    _trackImage = [UIImage imageNamed:@"edit_ic_colorbar.jpg"];
    _trackView.layer.contents = (__bridge id)(_trackImage.CGImage);
    _trackView.layer.contentsGravity = kCAGravityResize;
    
    _thumbLayer = [CAShapeLayer layer];
    [self.layer addSublayer:_thumbLayer];
    _thumbLayer.strokeColor = [UIColor whiteColor].CGColor;
    _thumbLayer.lineWidth = kThumbBorderWidth;
    _thumbLayer.fillColor = [UIColor whiteColor].CGColor;
    
    _progress = 0.5;
}

- (void)layoutSubviews {
    CGSize size = self.bounds.size;
    
    _trackView.frame = CGRectMake(kThumbWidth / 2,
                                  (size.height - kTrackHeight) / 2,
                                  size.width - kThumbWidth,
                                  kTrackHeight);
    _thumbLayer.frame = CGRectMake((size.width - kThumbWidth) / 2, (size.height - kThumbWidth) / 2, kThumbWidth, kThumbWidth);
    CGPoint position = CGPointMake(CGRectGetWidth(_trackView.bounds) * _progress + kThumbWidth/2, _thumbLayer.position.y);
    _thumbLayer.position = position;
    _thumbLayer.path = [self.class circleInRect:_thumbLayer.bounds].CGPath;
}

/**
 生成给定矩形的内切圆

 @param rect 矩形
 @return 圆形曲线
 */
+ (UIBezierPath *)circleInRect:(CGRect)rect {
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGFloat radius = center.x;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    return path;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    self.thumbLayer.fillColor = color.CGColor;
}

- (void)setProgress:(double)progress {
    _progress = progress;
    self.color = [self colorAtProgress:progress];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = touches.anyObject;
    if (touch.tapCount > 1 || touches.count > 1) return;
    
    [self updateThumbPositionWithTouch:touch animated:YES];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = touches.anyObject;
    if (touch.tapCount > 1 || touches.count > 1) return;
    
    [self updateThumbPositionWithTouch:touch animated:NO];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = touches.anyObject;
    if (touch.tapCount > 1 || touches.count > 1) return;

    [self updateThumbPositionWithTouch:touch animated:YES];
}

/**
 更新滑块位置

 @param touch 点击对象
 @param animated 是否动画更新
 */
- (void)updateThumbPositionWithTouch:(UITouch *)touch animated:(BOOL)animated {
    CGFloat touchX = [touch locationInView:self].x;
    if (touchX < kThumbWidth / 2 || touchX > CGRectGetWidth(self.bounds) - kThumbWidth / 2) return;
    
    CGPoint location = [touch locationInView:_trackView];
    CGPoint position = CGPointMake(location.x + kThumbWidth/2, _thumbLayer.position.y);
    double progress = location.x / CGRectGetWidth(_trackView.bounds);
    self.progress = progress;
    if (animated) {
        _thumbLayer.position = position;
    } else {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _thumbLayer.position = position;
        [CATransaction commit];
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

/**
 获取给定进度的颜色

 @param progress 进度
 @return 颜色
 */
- (UIColor *)colorAtProgress:(double)progress {
    if (progress < 7 / 253.0) {
        progress = 0;
    } else if (progress > 1) {
        progress = 1;
    }
    
    CGImageRef cgImage = _trackImage.CGImage;
    NSUInteger width = _trackImage.size.width;
    NSUInteger height = _trackImage.size.height;
    NSInteger pointX = (NSInteger)(_trackImage.size.width * progress);
    NSInteger pointY = (NSInteger)(_trackImage.size.height / 2.0);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // 绘制滑块的颜色
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // 计算颜色值
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    //CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

@end
