//
//  MovieEditerBottomBar.m
//  TuSDKVideoDemo
//
//  Created by wen on 2017/4/25.
//  Copyright © 2017年 TuSDK. All rights reserved.
//

#import "MovieEditerBottomBar.h"
#import "RecorderView.h"
#import "BottomButtonView.h"

@interface MovieEditerBottomBar ()<FilterViewEventDelegate, MVViewClickDelegate, DubViewClickDelegate, TuSDKICSeekBarDelegate, BottomButtonViewDelegate>{
    // 底部按钮以及分割线的父视图
    UIView *_bottomDisplayView;
    // 底部按钮View
    BottomButtonView *_bottomButtonView;
    
    // 音量调节 View
    UIView *_volumeBackView;
    // 原音音量 数值显示 UILabel
    UILabel * _oringinArgLabel;
    // 配音音量 数值显示 UILabel
    UILabel * _audioArgLabel;
    
    // 记录初始化之初的frame
    CGRect _initFrame;
    // 记录如果现实MV视图，需要调节的参数高度
    CGFloat _adjustHeight;
    // 原音音量
    CGFloat _originVolume;
    // 配音音量
    CGFloat _audioVolume;
}

// 录音View
@property (nonatomic, strong) RecorderView *recorderView;

@end

@implementation MovieEditerBottomBar

#pragma mark - setter getter 方法
- (void)setVideoFilters:(NSArray<NSString *> *)videoFilters
{
    _videoFilters = videoFilters;
    if (_filterView) {
        [_filterView createFilterWith:videoFilters];
        _filterView.beautyParamView.hidden = NO;
        _filterView.filterChooseView.hidden = YES;
    }
}

#pragma mark - 视图布局方法
- (instancetype)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        _audioVolume = 0.5;
        _originVolume = 0.5;
        _initFrame = frame;

        [self initBottomButton];
        [self initContentView];
        [self initVolumeView];
    }
    return self;
}

// 初始化底部按钮视图
- (void)initBottomButton;
{
    // 底部按钮 + 线条 背景View
    _bottomDisplayView = [[UIView alloc]initWithFrame:CGRectMake(0, self.lsqGetSizeHeight - 60, self.lsqGetSizeWidth, 60)];
    [self addSubview:_bottomDisplayView];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0 , self.lsqGetSizeWidth, 1)];
    line.backgroundColor = lsqRGB(230, 230, 230);
    [_bottomDisplayView addSubview:line];
    
    // 底部按钮
    NSArray *normalImageNames = @[@"style_default_1.5.0_btn_beauty_unselected", @"style_default_1.5.0_btn_beauty_unclected", @"style_default_1.5.0_btn_mv_unselected",@"style_default_1.7.0_sound_default"];
    NSArray *selectImageNames = @[@"style_default_1.5.0_btn_beauty", @"style_default_1.5.0_btn_filter", @"style_default_1.5.0_btn_mv", @"style_default_1.7.0_sound_selected"];
    NSArray *titles = @[NSLocalizedString(@"lsq_filter_beautyArg", @"美颜"), NSLocalizedString(@"lsq_movieEditor_filterBtn", @"滤镜"), NSLocalizedString(@"lsq_movieEditor_MVBtn", @"MV"), NSLocalizedString(@"lsq_movieEditor_dubBtn", @"配音")];
    
    _bottomButtonView = [[BottomButtonView alloc]initWithFrame:CGRectMake(0, 7, _bottomDisplayView.lsqGetSizeWidth, 50)];
    _bottomButtonView.clickDelegate = self;
    _bottomButtonView.selectedTitleColor = HEXCOLOR(0x22bbf4);
    _bottomButtonView.normalTitleColor = [UIColor lsqClorWithHex:@"#9fa0a0"];
    [_bottomButtonView initButtonWith:normalImageNames selectImageNames:selectImageNames With:titles];
    [_bottomDisplayView addSubview:_bottomButtonView];
}

// 初始化视图调节内容
- (void)initContentView;
{
    // 调节内容 背景view
    _contentBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _bottomDisplayView.lsqGetSizeWidth, _bottomDisplayView.lsqGetOriginY)];
    _contentBackView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_contentBackView];
    
    // 滤镜显示 View
    _filterView = [[FilterView alloc]initWithFrame:CGRectMake(0, 0, _bottomDisplayView.lsqGetSizeWidth , _bottomDisplayView.lsqGetOriginY )];
    _filterView.filterEventDelegate = self;
    _filterView.isHiddenEyeChinParam = YES;
    // 注： currentFilterTag 基于200 即： = 200 + 滤镜列表中某滤镜的对应下标
    _filterView.currentFilterTag = 200;
    [_contentBackView addSubview:_filterView];
    
    // MV View
    _mvView = [[MVScrollView alloc]initWithFrame:CGRectMake(0, 12, _bottomDisplayView.lsqGetSizeWidth - 11, self.lsqGetSizeHeight*0.35)];
    _mvView.mvDelegate = self;
    _mvView.hidden = YES;
    [_contentBackView addSubview:_mvView];
    
    _adjustHeight = _bottomDisplayView.lsqGetOriginY - 12 - self.lsqGetSizeHeight*0.35 - 12;
    
    // 配音 View
    _dubView = [[DubScrollView alloc]initWithFrame:_mvView.frame];
    _dubView.dubDelegate = self;
    _dubView.hidden = YES;
    [_contentBackView addSubview:_dubView];

}

- (void)initVolumeView;
{
    _volumeBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.lsqGetSizeWidth, 100)];
    _volumeBackView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _volumeBackView.hidden = true;
    [self addSubview:_volumeBackView];
    
    CGFloat parameterHeight = 30;
    
    // 原音强度
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, parameterHeight)];
    nameLabel.center = CGPointMake(30, _volumeBackView.lsqGetSizeHeight*0.3);
    nameLabel.textColor = HEXCOLOR(0x22bbf4);
    nameLabel.font = [UIFont systemFontOfSize:12];
    nameLabel.text = NSLocalizedString(@"lsq_movieEditor_orignVolume_title", @"原音强度");
    nameLabel.textAlignment = NSTextAlignmentRight;
    nameLabel.adjustsFontSizeToFitWidth = YES;
    [_volumeBackView addSubview:nameLabel];
    
    _oringinArgLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 45, parameterHeight)];
    _oringinArgLabel.center = CGPointMake(_volumeBackView.lsqGetSizeWidth - 22, nameLabel.center.y);
    _oringinArgLabel.text = @"0%";
    _oringinArgLabel.textColor = HEXCOLOR(0x22bbf4);
    _oringinArgLabel.font = [UIFont systemFontOfSize:14];
    _oringinArgLabel.textAlignment = NSTextAlignmentLeft;
    [_volumeBackView addSubview:_oringinArgLabel];

    CGFloat seekBarX = nameLabel.lsqGetOriginX + nameLabel.lsqGetSizeWidth + 5;
    TuSDKICSeekBar *seekBar = [TuSDKICSeekBar initWithFrame:CGRectMake(seekBarX, nameLabel.lsqGetOriginY, self.lsqGetSizeWidth - seekBarX - 10 - _oringinArgLabel.lsqGetSizeWidth , parameterHeight)];
    seekBar.delegate = self;
    seekBar.progress = 0.5;
    seekBar.aboveView.backgroundColor = HEXCOLOR(0x22bbf4);
    seekBar.belowView.backgroundColor = lsqRGB(217, 217, 217);
    seekBar.dragView.backgroundColor = HEXCOLOR(0x22bbf4);
    _oringinArgLabel.text = [NSString stringWithFormat:@"%d%%",(int)(_originVolume*100)];
    seekBar.tag = 101;
    [_volumeBackView addSubview: seekBar];
    
    // 配音强度
    UILabel *audioNameLabel = [[UILabel alloc]initWithFrame:nameLabel.bounds];
    audioNameLabel.center = CGPointMake(30, _volumeBackView.lsqGetSizeHeight*0.7);
    audioNameLabel.textColor = HEXCOLOR(0x22bbf4);
    audioNameLabel.font = [UIFont systemFontOfSize:12];
    audioNameLabel.text = NSLocalizedString(@"lsq_movieEditor_dubVolume_title", @"配音强度");
    audioNameLabel.textAlignment = NSTextAlignmentRight;
    audioNameLabel.adjustsFontSizeToFitWidth = YES;
    [_volumeBackView addSubview:audioNameLabel];
    
    _audioArgLabel = [[UILabel alloc]initWithFrame:_oringinArgLabel.bounds];
    _audioArgLabel.center = CGPointMake(_volumeBackView.lsqGetSizeWidth - 22, audioNameLabel.center.y);
    _audioArgLabel.text = @"0%";
    _audioArgLabel.textColor = HEXCOLOR(0x22bbf4);
    _audioArgLabel.font = [UIFont systemFontOfSize:14];
    _audioArgLabel.textAlignment = NSTextAlignmentLeft;
    [_volumeBackView addSubview:_audioArgLabel];
    
    TuSDKICSeekBar *audioSeekBar = [TuSDKICSeekBar initWithFrame:CGRectMake(seekBarX, audioNameLabel.lsqGetOriginY, seekBar.lsqGetSizeWidth, parameterHeight)];
    audioSeekBar.delegate = self;
    audioSeekBar.progress = 0.5;
    audioSeekBar.aboveView.backgroundColor = HEXCOLOR(0x22bbf4);
    audioSeekBar.belowView.backgroundColor = lsqRGB(217, 217, 217);
    audioSeekBar.dragView.backgroundColor = HEXCOLOR(0x22bbf4);
    _audioArgLabel.text = [NSString stringWithFormat:@"%d%%",(int)(_audioVolume*100)];
    audioSeekBar.tag = 102;
    [_volumeBackView addSubview: audioSeekBar];
}

// 切换按钮时 调整底部栏整体布局
- (void)adjustLayout
{
    if (_mvView.hidden && _dubView.hidden) {
        if (!CGRectEqualToRect(self.frame, _initFrame)) {
            CGRect lastFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y + _volumeBackView.lsqGetSizeHeight, self.bounds.size.width, self.bounds.size.height - _volumeBackView.lsqGetSizeHeight);
            self.frame = _initFrame;
            [_contentBackView lsqSetOriginY:_contentBackView.lsqGetOriginY - _volumeBackView.lsqGetSizeHeight];
            [_contentBackView lsqSetSizeHeight:_contentBackView.lsqGetSizeHeight + _adjustHeight];
            [_bottomDisplayView lsqSetOriginY:_bottomDisplayView.lsqGetOriginY + _adjustHeight - _volumeBackView.lsqGetSizeHeight];
            
            if ([self.bottomBarDelegate respondsToSelector:@selector(movieEditorBottom_adjustFrameWithMVDisplayed:lastFrame:newFrame:)]) {
                [self.bottomBarDelegate movieEditorBottom_adjustFrameWithMVDisplayed:NO lastFrame:lastFrame newFrame:_initFrame];
            }
        }
    }else{
        if (CGRectEqualToRect(self.frame, _initFrame)) {
            
            [self lsqSetOriginY:_initFrame.origin.y + _adjustHeight - _volumeBackView.lsqGetSizeHeight];
            [self lsqSetSizeHeight:_initFrame.size.height - _adjustHeight + _volumeBackView.lsqGetSizeHeight];
            [_contentBackView lsqSetOriginY:_contentBackView.lsqGetOriginY + _volumeBackView.lsqGetSizeHeight];
            [_contentBackView lsqSetSizeHeight:_contentBackView.lsqGetSizeHeight - _adjustHeight];
            [_bottomDisplayView lsqSetOriginY:_bottomDisplayView.lsqGetOriginY - _adjustHeight + _volumeBackView.lsqGetSizeHeight];
            
            CGRect rect = CGRectMake(self.frame.origin.x, self.frame.origin.y + _volumeBackView.lsqGetSizeHeight, self.bounds.size.width, self.bounds.size.height - _volumeBackView.lsqGetSizeHeight);
            if ([self.bottomBarDelegate respondsToSelector:@selector(movieEditorBottom_adjustFrameWithMVDisplayed:lastFrame:newFrame:)]) {
                [self.bottomBarDelegate movieEditorBottom_adjustFrameWithMVDisplayed:YES lastFrame:_initFrame newFrame:rect];
            }
        }
    }
}

#pragma mark - 自定义调用方法
// 刷新滤镜 item 的显示
- (void)refreshFilterParameterViewWith:(NSString *)filterDescription filterArgs:(NSArray *)args;
{
    [_filterView refreshAdjustParameterViewWith:filterDescription filterArgs:args];
}

#pragma mark - BottomButtonViewDelegate
// 底部按钮点击事件
- (void)bottomButton:(BottomButtonView *)bottomButtonView clickIndex:(NSInteger)index;
{
    if (index == 0) {
        // 点击美颜
        _filterView.hidden = NO;
        _mvView.hidden = YES;
        _dubView.hidden = YES;
        _volumeBackView.hidden = YES;

        _filterView.beautyParamView.hidden = NO;
        _filterView.filterChooseView.hidden = YES;
        
    }else if (index == 1) {
        // 点击滤镜
        _filterView.hidden = NO;
        _mvView.hidden = YES;
        _dubView.hidden = YES;
        _volumeBackView.hidden = YES;
        
        _filterView.beautyParamView.hidden = YES;
        _filterView.filterChooseView.hidden = NO;

    }else if (index == 2){
        // 点击 MV
        _mvView.hidden = NO;
        _volumeBackView.hidden = YES;
        _filterView.hidden = YES;
        _dubView.hidden = YES;
        
    }else if (index == 3){
        // 点击 配音
        _dubView.hidden = NO;
        _volumeBackView.hidden = NO;
        _mvView.hidden = YES;
        _filterView.hidden = YES;
    }
    
    [self adjustLayout];
}

#pragma mark - FilterViewEventDelegate
// 改变滤镜参数
- (void)filterViewParamChanged;
{
    if ([self.bottomBarDelegate respondsToSelector:@selector(movieEditorBottom_filterViewParamChanged)]) {
        [self.bottomBarDelegate movieEditorBottom_filterViewParamChanged];
    }
}

// 切换滤镜
- (void)filterViewSwitchFilterWithCode:(NSString *)filterCode;
{
    if ([self.bottomBarDelegate respondsToSelector:@selector(movieEditorBottom_filterViewSwitchFilterWithCode:)]) {
        [self.bottomBarDelegate movieEditorBottom_filterViewSwitchFilterWithCode:filterCode];
    }
}

#pragma mark -  StickerViewClickDelegate
// 切换选中的 MV item 
- (void)clickMVListViewWith:(TuSDKMVStickerAudioEffectData *)mvData
{
    if (!_mvView.hidden && _dubView.collectionView.indexPathsForSelectedItems.count > 0 && _dubView.collectionView.indexPathsForSelectedItems[0].row != 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [_dubView selectItemWithIndex:indexPath];
    }
    if ([self.bottomBarDelegate respondsToSelector:@selector(movieEditorBottom_clickStickerMVWith:)]) {
        [self.bottomBarDelegate movieEditorBottom_clickStickerMVWith:mvData];
    }
}

#pragma mark - DubViewClickDelegate
// 点击选择新的音乐
- (void)clickDubListViewWith:(NSURL *)audioURL;
{
    if (!_dubView.hidden && _mvView.collectionView.indexPathsForSelectedItems.count > 0 && _mvView.collectionView.indexPathsForSelectedItems[0].row != 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [_mvView selectItemWithIndex:indexPath];
    }

    if ([self.bottomBarDelegate respondsToSelector:@selector(movieEditorBottom_clickAudioWith:)]) {
        if (audioURL) {
            TuSDKMediaAudioEffectData *audioEffect = [[TuSDKMediaAudioEffectData alloc]initWithAudioURL:audioURL];
            [self.bottomBarDelegate movieEditorBottom_clickAudioWith:audioEffect];
        }else{
            [self.bottomBarDelegate movieEditorBottom_clickAudioWith:nil];
        }

    }
}

- (void)displayRecorderView;
{
    if (!_recorderView) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        _recorderView = [[RecorderView alloc]initWithFrame:CGRectMake(0, self.lsqGetSizeHeight - screenSize.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _recorderView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _recorderView.recorderDuration = self.videoDuration;
        MovieEditerBottomBar __weak *wSelf = self;
        _recorderView.recorderCompletedHandler = ^(NSString *resultPath) {
            if (resultPath) {
                [wSelf clickDubListViewWith:[NSURL fileURLWithPath:resultPath]];
            }else{
                [wSelf clickDubListViewWith:nil];
            }
        };
    }
    [self addSubview:_recorderView];

}

#pragma mark - TuSDKICSeekBarDelegate
- (void)onTuSDKICSeekBar:(TuSDKICSeekBar *)seekbar changedProgress:(CGFloat)progress;
{
    if (seekbar.tag == 101) {
        // 原音音量调节
        _originVolume = progress;
        _oringinArgLabel.text = [NSString stringWithFormat:@"%d%%",(int)(progress*100)];
    }else if (seekbar.tag == 102){
        // 配音音量调节
        _audioVolume = progress;
        _audioArgLabel.text = [NSString stringWithFormat:@"%d%%",(int)(progress*100)];
    }
    
    if ([self.bottomBarDelegate respondsToSelector:@selector(movieEditorBottom_changeVolumeLevel:index:)]) {
        [self.bottomBarDelegate movieEditorBottom_changeVolumeLevel:progress index:seekbar.tag - 101];
    }
}

@end
