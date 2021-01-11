//
//  EditTileStickerListItemView.m
//  TuSDKVideoDemo
//
//  Created by sprint on 2019/3/5.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import "StickerImageItemView.h"

@interface StickerImageItemView(){
 
    __weak IBOutlet UIImageView *_imageView;
    
}
@end

@implementation StickerImageItemView

/**
 设置当前自定义贴纸图片

 @param stickerimage 贴纸图片
 */
- (void)setStickerimage:(UIImage *)stickerimage;
{
    _stickerimage = stickerimage;
    [_imageView setImage:stickerimage];
}

-(void)itemViewDidTouchDown;
{
    _imageView.layer.borderWidth = 1;
    _imageView.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)itemViewDidTouchUp;{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_imageView.layer.borderWidth = 0;
    });
}

@end
