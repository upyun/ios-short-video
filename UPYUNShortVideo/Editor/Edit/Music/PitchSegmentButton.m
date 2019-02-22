//
//  PitchSegmentButton.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/9/26.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "PitchSegmentButton.h"
#import "Constants.h"

@implementation PitchSegmentButton

- (void)commonInit {
    [super commonInit];
    self.style = SegmentButtonStylePlain;
    self.cornerRadius = 1;
    self.buttonTitles = @[kPitchTitles];
    self.selectedIndex = 2;
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:.1];
    self.selectedBackgroundColor = lsqRGBA(51, 51, 51, 0.5);
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:lsqRGB(255, 204, 0) forState:UIControlStateSelected];
}

/**
 选择特殊声效

 @param selectedIndex 声效对应的索引
 */
- (void)setSelectedIndex:(NSInteger)selectedIndex {
    [super setSelectedIndex:selectedIndex];
    switch (selectedIndex) {
        case 0:{
            // 怪兽声效
            _pitchType = TuSDKSoundPitchMonster;
        } break;
        case 1:{
            // 大叔声效
            _pitchType = TuSDKSoundPitchUncle;
        } break;
        case 2:{
            // 原声声效（无特效）
            _pitchType = TuSDKSoundPitchNormal;
        } break;
        case 3:{
            // 少女声效
            _pitchType = TuSDKSoundPitchGirl;
        } break;
        case 4:{
            // 萝莉声效
            _pitchType = TuSDKSoundPitchLolita;
        } break;
        default:{} break;
    }
}

@end
