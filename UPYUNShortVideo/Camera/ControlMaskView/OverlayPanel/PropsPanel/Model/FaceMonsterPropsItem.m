//
//  FaceMonsterPropsItem.m
//  TuSDKVideoDemo
//
//  Created by sprint on 2018/12/25.
//  Copyright © 2018 TuSDK. All rights reserved.
//

#import "FaceMonsterPropsItem.h"

@implementation FaceMonsterPropsItem


/**
 加载道具封面
 
 @param thumbImageView 封面视图
 @param hander 加载完成后处理事件
 */
- (void)loadThumb:(UIImageView *)thumbImageView completed:(void (^)(BOOL))hander
{
    if (!thumbImageView) return;
    thumbImageView.image = [UIImage imageNamed:self.thumbImageName];
    if (hander)
        hander(YES);
}

/**
 返回特效对象
 
 @return TuSDKMediaEffect
 */
- (id<TuSDKMediaEffect>)effect;
{
    if (_effect || !self.item) return _effect;
    
    _effect = [[TuSDKMediaMonsterFaceEffect alloc] initWithMonsterFaceType:self.item.integerValue];
    return _effect;
}

/**
 加载特效

 @param handler 加载完成回调
 */
- (void)loadEffect:(LoadHander)handler;
{
    if (handler)handler(self.effect);
}


@end
