//
//  TileStickerListView.h
//  TuSDKVideoDemo
//
//  Created by sprint on 2019/3/5.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import "HorizontalListView.h"
#import "StickerImageItemView.h"

@protocol TileStickerListViewDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface StickerImageListView : HorizontalListView

@property  (nonatomic,weak) IBOutlet id<TileStickerListViewDelegate> delegate;

@end


@protocol TileStickerListViewDelegate <NSObject>

@required
- (void)tileStickerListView:(StickerImageListView *)stickerListView didSelectedItemView:(StickerImageItemView *)itemView;

@end

NS_ASSUME_NONNULL_END
