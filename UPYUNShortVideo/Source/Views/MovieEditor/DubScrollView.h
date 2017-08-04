//
//  DubScrollView.h
//  TuSDKVideoDemo
//
//  Created by wen on 04/07/2017.
//  Copyright © 2017 TuSDK. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 配音设置 相关代理方法
 @param stickGroup 贴纸组对象
 */
@protocol DubViewClickDelegate <NSObject>

/**
 点击选择新的音乐
 
 @param mvData 音乐的URL
 */
- (void)clickDubListViewWith:(NSURL *)audioURL;

/**
 显示录制界面
 */
- (void)displayRecorderView;

@end


#pragma mark - DubScrollView

// 配音栏 view
@interface DubScrollView : UIView

// 配音 事件代理
@property (nonatomic, assign) id<DubViewClickDelegate> dubDelegate;
// collectionView 对象
@property (nonatomic, strong) UICollectionView *collectionView;


// 选中某一个cell
- (void)selectItemWithIndex:(NSIndexPath *)indexPath;
@end
