//
//  TileStickerListView.m
//  TuSDKVideoDemo
//
//  Created by sprint on 2019/3/5.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import "StickerImageListView.h"
#import "StickerImageItemView.h"

@interface StickerImageListView () {
    NSArray *_tileImageNames;
}
@end

@implementation StickerImageListView

+ (Class)listItemViewClass {
    return [StickerImageItemView class];
}

- (void)commonInit {
    [super commonInit];
    [self setupData];
}

- (void)setupData {
    
    _tileImageNames = @[@"10342-sticker",@"10344-sticker",@"10345-sticker",@"10346-sticker",@"10348-sticker",@"10347-sticker",@"10343-sticker",@"10341-sticker"];
    
    // 配置 UI
    typeof(self)weakSelf = self;
    [self addItemViewsFromXIBWithCount:_tileImageNames.count config:^(HorizontalListView *listView, NSUInteger index, StickerImageItemView *itemView) {        
        itemView.stickerimage = [UIImage imageNamed:weakSelf->_tileImageNames[index]];
        
    }];
    
}

- (void)itemViewDidTap:(StickerImageItemView *)itemView; {
    [super itemViewDidTap:itemView];
    [_delegate tileStickerListView:self didSelectedItemView:itemView];
}

@end
