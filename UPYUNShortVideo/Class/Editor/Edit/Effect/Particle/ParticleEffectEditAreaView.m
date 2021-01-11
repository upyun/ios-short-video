//
//  ParticleEffectEditAreaView.m
//  TuSDKVideoDemo
//
//  Created by bqlin on 2018/7/13.
//  Copyright © 2018年 TuSDK. All rights reserved.
//

#import "ParticleEffectEditAreaView.h"

@implementation ParticleEffectEditAreaView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (touches.count > 1) return;
    
    if (!CGRectContainsPoint(self.bounds, [touches.anyObject locationInView:self])) return;
    
    if ([self.delegate respondsToSelector:@selector(particleEditAreaViewDidBeginEditing:)]) {
        [self.delegate particleEditAreaViewDidBeginEditing:self];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if ([self.delegate respondsToSelector:@selector(particleEditAreaViewDidEndEditing:)]) {
        [self.delegate particleEditAreaViewDidEndEditing:self];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    if ([self.delegate respondsToSelector:@selector(particleEditAreaViewDidEndEditing:)]) {
        [self.delegate particleEditAreaViewDidEndEditing:self];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    if (touches.count > 1) return;
    CGPoint location = [touches.anyObject locationInView:self];
    
    if (!CGRectContainsPoint(self.bounds, location)) return;
    
    CGSize size = self.bounds.size;
    CGPoint percentLocaiotn = CGPointMake(location.x / size.width, location.y / size.height);
    if ([self.delegate respondsToSelector:@selector(particleEditAreaView:didUpdatePercentPoint:)]) {
        [self.delegate particleEditAreaView:self didUpdatePercentPoint:percentLocaiotn];
    }
}

@end
