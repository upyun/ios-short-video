//
//  TransitionHorizontalListItemView.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2019/6/19.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import "TransitionHorizontalListItemView.h"

@implementation TransitionHorizontalListItemView

- (void)layoutSubviews {
    CGSize size = self.bounds.size;
    self.thumbnailView.frame = CGRectMake(5, 0, size.width - 10, size.height - 12);
    const CGFloat labelHeight = 16;
    self.titleLabel.frame = CGRectMake(0, size.height - labelHeight, size.width, labelHeight);
    self.selectedImageView.frame = self.thumbnailView.frame;
    self.touchButton.frame = self.bounds;
}

@end
