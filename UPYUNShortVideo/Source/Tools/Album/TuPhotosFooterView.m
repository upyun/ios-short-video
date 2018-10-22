//
//  TuPhotosFooterView.m
//  VideoAlbumDemo
//
//  Created by wen on 24/10/2017.
//  Copyright © 2017 wen. All rights reserved.
//

#import "TuPhotosFooterView.h"

@interface TuPhotosFooterView ()

@property (weak, nonatomic) UILabel *label;

@end

@implementation TuPhotosFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = CGRectMake(0, 0, width, height);
    [self addSubview:label];
    _label = label;
}

- (void)setTotal:(NSInteger)total
{
    _total = total;
    
    NSString *str;
    str = [NSString stringWithFormat:@"共%ld个视频",total];
    _label.text = str;
}

@end

