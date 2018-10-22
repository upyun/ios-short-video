//
//  TuSDKMovieEditor.h
//  TuSDKVideo
//
//  Created by Yanlin Qiu on 19/12/2016.
//  Copyright © 2016 TuSDK. All rights reserved.
//

#import "TuSDKVideoImport.h"
#import "TuSDKMovieEditorBase.h"
#import "TuSDKVideoResult.h"

#pragma mark - TuSDKMovieEditorDelegate

@class TuSDKMovieEditor;
@protocol TuSDKMovieEditorDelegate;
@protocol TuSDKMovieEditorMediaEffectsDelegate;

#pragma mark - TuSDKMovieEditor

/**
 *  视频编辑
 */
@interface TuSDKMovieEditor : TuSDKMovieEditorBase

/**
 *  编辑器事件委托
 */
@property (nonatomic, weak) id<TuSDKMovieEditorDelegate> delegate DEPRECATED_MSG_ATTRIBUTE("Please use loadDeleate/playDelegate/saveDelegate");

/**
 *  特效事件委托
 */
@property (nonatomic, weak) id<TuSDKMovieEditorMediaEffectsDelegate> mediaEffectsDelegate;

/**
 *  初始化
 *
 *  @param holderView 预览容器
 *  @return 对象实例
 */
- (instancetype)initWithPreview:(UIView *)holderView options:(TuSDKMovieEditorOptions *) options;


@end

/**
 *  视频编辑器事件委托
 */
@protocol TuSDKMovieEditorDelegate <NSObject>

/**
 *  视频处理完成
 *
 *  @param editor 编辑器
 *  @param result TuSDKVideoResult对象
 */
- (void)onMovieEditor:(TuSDKMovieEditor *)editor result:(TuSDKVideoResult *)result DEPRECATED_MSG_ATTRIBUTE("Please use saveDelegate");

/**
 *  视频处理出错
 *
 *  @param editor 编辑器
 *  @param error  错误对象
 */
- (void)onMovieEditor:(TuSDKMovieEditor *)editor failedWithError:(NSError*)error DEPRECATED_MSG_ATTRIBUTE("Please use saveDelegate");

@optional

/**
 *  视频播放进度通知
 *
 *  @param editor   编辑器
 *  @param progress 进度 (0~1)
 *  @param outputTime 当前播放持续时间
 */
- (void)onMovieEditor:(TuSDKMovieEditor *)editor progress:(CGFloat)progress outputTime:(CMTime)outputTime  DEPRECATED_MSG_ATTRIBUTE("Please use playDelegate");

/**
 *  滤镜改变 (如需操作UI线程， 请检查当前线程是否为主线程)
 *
 *  @param editor    编辑器
 *  @param newFilter 新的滤镜对象
 */
- (void)onMovieEditor:(TuSDKMovieEditor *)editor filterChanged:(TuSDKFilterWrap *)newFilter DEPRECATED_MSG_ATTRIBUTE("Please use mediaEffectsDelegate");

/**
 *  TuSDKMovieEditor 状态改变
 *
 *  @param editor TuSDKMovieEditor
 *  @param status 状态信息
 */
- (void)onMovieEditor:(TuSDKMovieEditor *)editor statusChanged:(lsqMovieEditorStatus) status DEPRECATED_MSG_ATTRIBUTE("Please use loadDeleate/playDelegate/saveDelegate");


@end

/**
 * 特效事件委托
 */
@protocol TuSDKMovieEditorMediaEffectsDelegate <NSObject>

@optional

/**
 当前正在应用的特效
 
 @param editor TuSDKMovieEditor
 @param mediaEffectData 正在预览特效
 @since 2.2.0
 */
- (void)onMovieEditor:(TuSDKMovieEditor *)editor didApplyingMediaEffect:(TuSDKMediaEffectData *)mediaEffectData;

/**
 特效被移除通知
 
 @param editor TuSDKMovieEditor
 @param mediaEffects 被移除的特效列表
 @since      v2.2.0
 */
- (void)onMovieEditor:(TuSDKMovieEditor *)editor didRemoveMediaEffects:(NSArray<TuSDKMediaEffectData *> *)mediaEffects;

@end

