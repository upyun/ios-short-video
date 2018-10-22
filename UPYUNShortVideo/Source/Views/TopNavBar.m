//
//  TopNavBar.m
//  TuSDKVideoDemo
//
//  Created by wen on 2017/5/27.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "TopNavBar.h"

@interface TopNavBar ()
{
    BOOL _addInfos;
}
@end

@implementation TopNavBar

/**
 向view添加 title、左侧系列按钮、右侧系列按钮
 
 @param title 中间显示的 title
 @param leftButtons 左侧系列按钮，参数为字符串，若为图片，请在图片名后添加图片后缀(.png或.jpg)，若无固定后缀，则显示传入的字符串
 @param rightButtons 右侧系列按钮，参数同上
 */
- (void)addTopBarInfoWithTitle:(NSString *)title leftButtonInfo:(NSArray<NSString *> *)leftButtons rightButtonInfo:(NSArray<NSString *> *)rightButtons;
{
    if (_addInfos) return;
    
    [self addInfoWithTitle:title leftButtonInfo:leftButtons rightButtonInfo:rightButtons];
    
    _addInfos = true;
}

// 在一定基数上，左侧按钮tag依次为：0 1 2 ...  右侧按钮tag依次为：... 12 11 10  基数为10
- (void)addInfoWithTitle:(NSString *)title leftButtonInfo:(NSArray<NSString *> *)leftButtons rightButtonInfo:(NSArray<NSString *> *)rightButtons;
{
    // title
    if (title != nil) {
        _centerTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 120, self.bounds.size.height)];
        _centerTitleLabel.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        _centerTitleLabel.text = title;
        _centerTitleLabel.textAlignment = NSTextAlignmentCenter;
        _centerTitleLabel.textColor = lsqRGB(62, 62, 57);
        [self addSubview:_centerTitleLabel];
    }
    // 按钮与按钮之间的间隔
    CGFloat btnInterval = 18;
    // 按钮左右边距
    CGFloat btnMargin = 0;
    
    // 初始化左侧系列按钮
    if (leftButtons != nil) {
        CGFloat btnCenterY = self.bounds.size.height/2;
        CGFloat btnCenterX = btnMargin;
        
        for (int i = 0; i < leftButtons.count; i ++) {
            NSString *btnInfo = leftButtons[i];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            
            if ([btnInfo containsString:@".png"] || [btnInfo containsString:@".jpg"]) {
                UIImage *btnImage = nil;
                CGFloat btnHeight = 36;
                CGFloat btnWidth = 0;
                if (i == 0) {
                    // 第一个按钮默认就是返回按钮，可根据需求不同进行逻辑更改
                    if ([btnInfo containsString:@"+"]) {
                        NSString *titleStr = [[btnInfo componentsSeparatedByString:@"+"] lastObject];
                        btnInfo = [[btnInfo componentsSeparatedByString:@"+"] firstObject];
                        btnImage = [UIImage imageNamed:btnInfo];
                        btnWidth = [self coculateWidthWithSize:btnImage.size withPositiveHeight:btnHeight];
                        btnWidth = btnWidth + [titleStr lsqColculateTextSizeWithFont:btn.titleLabel.font maxWidth:100 maxHeihgt:btnHeight].width;
                        
                        [btn setTitle:titleStr forState:UIControlStateNormal];
                        [btn setTitleColor:lsqRGB(244, 161, 24) forState:UIControlStateNormal];
                    }else{
                        btnImage = [UIImage imageNamed:btnInfo];
                        btnHeight = 44;
                        btnWidth = [self coculateWidthWithSize:btnImage.size withPositiveHeight:btnHeight];
                        btnWidth = (btnWidth < btnHeight)?btnHeight:btnWidth;
                    }
                }else{
                    btnImage = [UIImage imageNamed:btnInfo];
                    btnHeight = 36;
                    btnWidth = [self coculateWidthWithSize:btnImage.size withPositiveHeight:btnHeight];
                    btnWidth = (btnWidth < btnHeight)?btnHeight:btnWidth;
                }
                btnCenterX = btnCenterX + btnWidth/2;
                
                btn.frame = CGRectMake(0, 0, btnWidth, btnHeight);
                btn.center = CGPointMake(btnCenterX, btnCenterY);
                btn.tag = i ;
                [btn addTarget:self action:@selector(leftBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [btn setImage:btnImage forState:UIControlStateNormal];
                
                btnCenterX = btnCenterX + btnWidth/2 + btnInterval;
            }else{
                
                btn.tag = i;
                [btn addTarget:self action:@selector(leftBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [btn setTitle:btnInfo forState:UIControlStateNormal];
                [btn setTitleColor:lsqRGB(244, 161, 24) forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont systemFontOfSize:13];
                CGFloat btnWidth = [btnInfo lsqColculateTextSizeWithFont:btn.titleLabel.font maxWidth:200 maxHeihgt:200].width;
                btnCenterX = btnCenterX + btnWidth/2;
                
                btn.frame = CGRectMake(0, 0, btnWidth, 36);
                btn.center = CGPointMake(btnCenterX, btnCenterY);
                btnCenterX = btnCenterX + btnWidth/2 + btnInterval;
            }
            btn.adjustsImageWhenHighlighted = NO;
            [self addSubview:btn];
        }
    }
    
    // 初始化右侧系列按钮
    if (rightButtons != nil) {
        CGFloat btnCenterY = self.bounds.size.height/2;
        CGFloat btnCenterX = self.bounds.size.width - 12;
        
        for (int i = 0; i < rightButtons.count; i ++) {
            NSString *btnInfo = rightButtons[i];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            
            if ([btnInfo containsString:@".png"] || [btnInfo containsString:@".jpg"]) {
                UIImage *btnImage = [UIImage imageNamed:btnInfo];
                CGFloat btnHeight = 44;
                CGFloat btnWidth = [self coculateWidthWithSize:btnImage.size withPositiveHeight:btnHeight];
                btnCenterX = btnCenterX - btnWidth/2;
                
                btn.frame = CGRectMake(0, 0, btnWidth, btnHeight);
                btn.center = CGPointMake(btnCenterX, btnCenterY);
                btn.tag = i + lsqRightTopBtnFirst;
                [btn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [btn setImage:btnImage forState:UIControlStateNormal];
                
                btnCenterX = btnCenterX - btnWidth/2 - btnInterval;
            }else{
                
                btn.tag = i + lsqRightTopBtnFirst;
                [btn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [btn setTitle:btnInfo forState:UIControlStateNormal];
                [btn setTitleColor:lsqRGB(244, 161, 24) forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont systemFontOfSize:17];
                CGFloat btnWidth = [btnInfo lsqColculateTextSizeWithFont:btn.titleLabel.font maxWidth:200 maxHeihgt:200].width;
                btnCenterX = btnCenterX - btnWidth/2;
                
                btn.frame = CGRectMake(0, 0, btnWidth, 36);
                btn.center = CGPointMake(btnCenterX, btnCenterY);
                
                btnCenterX = btnCenterX - btnWidth/2 - btnInterval;
            }
            btn.adjustsImageWhenHighlighted = NO;
            [self addSubview:btn];
        }
    }
}

// 移除所有控件
- (void)removeAllInfos;
{
    if (!_addInfos) return;
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}


// 按钮点击事件
- (void)leftBtnClicked:(UIButton *)btn;
{
    btn.selected = !btn.selected;
    if ([_topBarDelegate respondsToSelector:@selector(onLeftButtonClicked:navBar:)]) {
        [_topBarDelegate onLeftButtonClicked:btn navBar:self];
    }

}

- (void)rightBtnClicked:(UIButton *)btn;
{
    btn.selected = !btn.selected;
    if ([_topBarDelegate respondsToSelector:@selector(onRightButtonClicked:navBar:)]) {
        [_topBarDelegate onRightButtonClicked:btn navBar:self];
    }

}
// 根据图片宽高比定高计算宽度
- (CGFloat)coculateWidthWithSize:(CGSize)originSize withPositiveHeight:(CGFloat)height;
{
    return height * (originSize.width/originSize.height);
}

/**
 改变某个按钮的是否可点击状态，以及图片
 
 @param index 是第几个按钮 左侧系列按钮依次为 0、1、2； 右侧按钮依次为 2、1、0； 注：该index,与按钮实际的tag值无关
 @param isLeftBtn 是否为左侧系列按钮
 @param changeImage 新的按钮图片，为 nil，则不改变图片
 @param enabled 是否可点击，YES：表示可响应点击
 */
- (void)changeBtnStateWithIndex:(NSInteger)index isLeftbtn:(BOOL)isLeftBtn withImage:(UIImage*)changeImage withEnabled:(BOOL)enabled;
{
    NSInteger btnTag = index;
    if (isLeftBtn) {
        btnTag = btnTag ;
    }else{
        btnTag = btnTag + lsqRightTopBtnFirst;
    }
    
    for (UIButton *btn in self.subviews) {
        if (btn.tag == btnTag) {
            btn.enabled = enabled;
            if (changeImage != nil) {
                [btn setImage:changeImage forState:UIControlStateNormal];
            }
        }
    }
}

@end
