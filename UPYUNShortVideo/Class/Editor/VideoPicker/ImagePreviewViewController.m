//
//  ImagePreviewViewController.m
//  TuSDKVideoDemo
//
//  Created by tutu on 2019/6/17.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import "ImagePreviewViewController.h"
#import "TuSDKFramework.h"

@interface ImagePreviewViewController ()

/**
 视图加载后的操作
 */
@property (nonatomic, strong) NSMutableArray<void (^)(void)> *actionsAfterViewDidLoad;


/**
 视频预览视图
 */
@property (nonatomic, strong) UIImageView *imagePreviewView;

/**
 添加按钮
 */
@property (nonatomic, weak) UIButton *addButton;

/**
 视频请求 ID
 */
@property (nonatomic, assign) PHImageRequestID assetRequestId;

@end

@implementation ImagePreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 配置 UI
    [self setupUI];
    
    // 执行 _actionsAfterViewDidLoad 存储的任务
    for (void (^action)(void) in _actionsAfterViewDidLoad) {
        action();
    }
    _actionsAfterViewDidLoad = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 取消资源请求
    [[PHImageManager defaultManager] cancelImageRequest:_assetRequestId];
    _assetRequestId = -1;
    [[TuSDK shared].messageHub dismiss];
}



- (void)setupUI {
    // 配置右上方按钮
    [self.topNavigationBar.rightButton setTitle:NSLocalizedStringFromTable(@"tu_下一步", @"VideoDemo", @"下一步") forState:UIControlStateNormal];
    
    // 视频预览视图
    UIImageView *imagePreviewView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imagePreviewView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view insertSubview:imagePreviewView atIndex:0];
    _imagePreviewView = imagePreviewView;
    
    // 添加按钮
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:addButton];
    [addButton setBackgroundImage:[UIImage imageNamed:@"edit_heckbox_unsel_max"] forState:UIControlStateNormal];
    [addButton setBackgroundImage:[UIImage imageNamed:@"edit_heckbox_sel_max"] forState:UIControlStateSelected];
    [addButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    addButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [addButton addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _addButton = addButton;
    self.selectedIndex = _selectedIndex;
    self.disableSelect = _disableSelect;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect safeBounds = self.view.bounds;
    if (@available(iOS 11.0, *)) {
        safeBounds = UIEdgeInsetsInsetRect(safeBounds, self.view.safeAreaInsets);
    }
    const CGFloat addButtonWidth = 32;
    const CGFloat addButtonMargin = 16;
    const CGRect addButtonFrame = CGRectMake(CGRectGetMaxX(safeBounds) - addButtonWidth - addButtonMargin,
                                             CGRectGetMaxY(safeBounds) - addButtonWidth - addButtonMargin,
                                             addButtonWidth, addButtonWidth);
    _addButton.frame = addButtonFrame;
}


/**
 添加在视图加载后的操作
 
 @param action 操作 Block
 */
- (void)addActionAfterViewDidLoad:(void (^)(void))action {
    if (!action) return;
    
    if (self.viewLoaded) {
        action();
    } else {
        if (!_actionsAfterViewDidLoad) {
            _actionsAfterViewDidLoad = [NSMutableArray array];
        }
        [_actionsAfterViewDidLoad addObject:action];
    }
}

#pragma mark - property

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    NSString *addButtonTitle = selectedIndex >= 0 ? @(selectedIndex + 1).description : nil;
    [_addButton setTitle:addButtonTitle forState:UIControlStateSelected];
    _addButton.selected = selectedIndex >= 0;
}

- (void)setPhAsset:(PHAsset *)phAsset {
    _phAsset = phAsset;
    _assetRequestId = -1;
    
    if (_avAsset) return;
    __weak typeof(self) weakSelf = self;
    [self addActionAfterViewDidLoad:^{
        [weakSelf preparePhAsset:phAsset completion:^(UIImage *image) {
            weakSelf.imagePreviewView.image = image;
        }];
    }];
}


/**
 当文件数量达到最大可选数时禁止选择操作
 
 @param disableSelect 是否禁止选择
 */
- (void)setDisableSelect:(BOOL)disableSelect {
    _disableSelect = disableSelect;
    _addButton.hidden = disableSelect;
}

#pragma mark - action


/**
 添加按钮事件
 
 @param sender 添加按钮
 */
- (void)addButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.addButtonActionHandler) self.addButtonActionHandler(self, sender);
}


#pragma mark - 获取视频资源

/**
 请求 PHAsset 为 AVAsset
 
 @param phAsset 输入 PHAsset
 @param completion 完成回调
 */
- (void)preparePhAsset:(PHAsset *)phAsset completion:(void (^)(UIImage *image))completion {
    __weak typeof(self) weakSelf = self;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.progressHandler = ^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
        if (weakSelf.assetRequestId <= 0) return;
        
        if (progress == 1.0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[TuSDK shared].messageHub dismiss];
            });
        } else {
            [[TuSDK shared].messageHub showProgress:progress status:@"iCloud 同步中"];
            weakSelf.view.userInteractionEnabled = NO;
        }
    };
    _assetRequestId = [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize: CGSizeMake([UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale, [UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        weakSelf.assetRequestId = -1;
        weakSelf.view.userInteractionEnabled = YES;
        if (!result) return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(result);
        });
    }];
}



@end
