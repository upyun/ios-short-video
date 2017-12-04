//
//  UPEditorSettingVC.m
//  UPYUNShortVideo
//
//  Created by lingang on 2017/11/10.
//  Copyright © 2017年 upyun. All rights reserved.
//

#import "UPEditorSettingVC.h"
#import "TopNavBar.h"
#import "MoviePreviewAndCutViewController.h"
#import "UPSettingConfig.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface UPEditorSettingVC ()<TopNavBarDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
// 录制相机顶部控制栏视图
@property (nonatomic, strong) TopNavBar *topBar;
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, copy) NSMutableArray* textFiledArray;
@property (nonatomic, assign) NSUInteger inputTag;

@property (nonatomic, assign) int watermarkPosition;

@end

@implementation UPEditorSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _watermarkPosition = 0;
    _inputTag = 10000;
    _textFiledArray = [NSMutableArray array];
    [self setupView];
    [self setupDismisKeyboard];

    [self configInput];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 基础配置方法
// 隐藏状态栏 for IOS7
- (BOOL)prefersStatusBarHidden;
{
    return YES;
}

// 是否允许旋转 IOS5
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

// 是否允许旋转 IOS6
-(BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - 视图布局方法

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationBarHidden:YES animated:NO];
    [self setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)setupView {
    // 默认相机顶部控制栏
    _topBar = [[TopNavBar alloc]initWithFrame:CGRectMake(0, 0, self.view.lsqGetSizeWidth, 44)];
    _topBar.backgroundColor = [UIColor whiteColor];
    _topBar.topBarDelegate = self;
    
    NSString *backBtnTitle = [NSString stringWithFormat:@"video_style_default_btn_back.png+%@",NSLocalizedString(@"lsq_go_back", @"返回")];
    [_topBar addTopBarInfoWithTitle:@"编辑配置"
                     leftButtonInfo:@[backBtnTitle]
                    rightButtonInfo:@[NSLocalizedString(@"lsq_next_step", @"下一步")]];
    [self.view addSubview:_topBar];
    
    
    
    NSArray *title = @[@"清晰度", @"分辨率", @"帧码率"];
    
    
    
//    _scrollView = [[UIScrollView alloc ] initWithFrame:CGRectMake(0, 50, self.view.lsqGetSizeWidth, self.view.lsqGetSizeHeight - 50)];
//    //    _scrollView.pagingEnabled = YES;
//    _scrollView.backgroundColor = HEXCOLOR(0xe7e7e7);
//    _scrollView.showsVerticalScrollIndicator = NO;
//    _scrollView.showsHorizontalScrollIndicator = NO;
//
//    [self.view addSubview: _scrollView];
//    CGSize newSize = CGSizeMake(self.view.frame.size.width, title.count * 110 + 100) ;
//    [_scrollView setContentSize:newSize];
    
    for (int i = 0; i < title.count; i++) {
        [self initView:i withTitle:title[i]];
    }
}

- (void)setupDismisKeyboard {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    tap.delegate = self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    /// 不拦截任何手势
    [self dismissKeyboard];
    return NO;
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
    
    
    NSTimeInterval animationDuration = 0.30f;
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    
    [UIView setAnimationDuration:animationDuration];
    
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    
    self.view.frame = rect;
    
    [UIView commitAnimations];
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info;
{
    UPEditorSettingVC *wSelf = self;
    [picker dismissViewControllerAnimated:NO completion:^{
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        
        /// 从相册中上传视频,图片等
        
        //        NSString *saveKey = [NSString stringWithFormat:@"short_video_lib_test_%d.mp4", arc4random() % 10];
        //        [[UPYUNConfig sharedInstance] uploadFilePath:url.path saveKey:saveKey success:^(NSHTTPURLResponse *response, NSDictionary *responseBody) {
        //            [[TuSDK shared].messageHub showSuccess:@"上传成功"];
        //            NSLog(@"file url：http://%@.b0.upaiyun.com/%@",[UPYUNConfig sharedInstance].DEFAULT_BUCKET, saveKey);
        //        } failure:^(NSError *error, NSHTTPURLResponse *response, NSDictionary *responseBody) {
        //            [[TuSDK shared].messageHub showSuccess:@"上传失败"];
        //            NSLog(@"上传失败 error：%@", error);
        //            NSLog(@"上传失败 code=%ld, responseHeader：%@", (long)response.statusCode, response.allHeaderFields);
        //            NSLog(@"上传失败 message：%@", responseBody);
        //        } progress:^(int64_t completedBytesCount, int64_t totalBytesCount) {
        //        }];
        
        
        // 开启视频编辑导入视频
        MoviePreviewAndCutViewController *vc = [MoviePreviewAndCutViewController new];
        vc.inputURL = url;
        vc.config = [self getConfigInput];
        [wSelf.navigationController pushViewController:vc animated:YES];
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [picker dismissModalViewControllerAnimated];
}


- (void)onLeftButtonClicked:(UIButton*)btn navBar:(TopNavBar *)navBar{
    // 返回按钮
    //    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 右侧按钮点击事件
 
 @param btn 按钮对象
 @param navBar 导航条
 */
- (void)onRightButtonClicked:(UIButton*)btn navBar:(TopNavBar *)navBar;
{
    switch (btn.tag) {
        case lsqRightTopBtnFirst: {
            
            UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
                ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
                ipc.mediaTypes = @[(NSString *)kUTTypeMovie];
            }
            ipc.allowsEditing = NO;
            ipc.delegate = self;
            
            [self presentViewController:ipc animated:YES completion:nil];
            
        }
            break;
            
        default:
            break;
    }
    
}


- (void)configInput {
    UPSettingConfig *config = [UPSettingConfig defaultConfig];
    
    [(UITextField *)[_textFiledArray objectAtIndex:0] setText:[NSString stringWithFormat:@"%.0f", config.outputSize.width]];
    [(UITextField *)[_textFiledArray objectAtIndex:1] setText:[NSString stringWithFormat:@"%.0f", config.outputSize.height]];
    [(UITextField *)[_textFiledArray objectAtIndex:2] setText:[NSString stringWithFormat:@"%lu", (unsigned long)config.lsqVideoBitRate]];
    [(UITextField *)[_textFiledArray objectAtIndex:3] setText:[NSString stringWithFormat:@"%d", config.frameRate]];
    
}

- (UPSettingConfig *)getConfigInput {
    UPSettingConfig *config = [[UPSettingConfig alloc] init];

    int width = [(UITextField *)[_textFiledArray objectAtIndex:0] text].intValue;
    int heigth = [(UITextField *)[_textFiledArray objectAtIndex:1] text].intValue;
    config.outputSize = CGSizeMake(width, heigth);
    config.lsqVideoBitRate = [(UITextField *)[_textFiledArray objectAtIndex:2] text].intValue;
    config.frameRate = [(UITextField *)[_textFiledArray objectAtIndex:3] text].intValue;
    
    return config;
}


- (void)initView:(int)type withTitle:(NSString *)title{
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 50+ 10 + type * (110), self.view.bounds.size.width - 20, 100)];
    bgView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, 60, 24)];
    titleLabel.text = title;
    titleLabel.textColor = HEXCOLOR(0x323333);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [bgView addSubview:titleLabel];
    
    if (type == 0) {
        UIView *buttonView = [self makeButtonView:@[@"低清", @"标清", @"高清", @"超清"]];
        buttonView.frame = CGRectMake(0, 50, self.view.frame.size.width, 40);
        [bgView addSubview:buttonView];
    } else if (type == 1) {
        
        UIView *inputLeftView = [self makeInputView:@"宽度" des:@"px"];
        inputLeftView.frame = CGRectMake(16, 60, self.view.frame.size.width/2, 30);
        [bgView addSubview:inputLeftView];
        UIView *inputRigthView = [self makeInputView:@"高度" des:@"px"];
        inputRigthView.frame = CGRectMake(self.view.frame.size.width/2, 60, self.view.frame.size.width/2, 30);
        [bgView addSubview:inputRigthView];
    } else if (type == 2) {
        
        UIView *inputLeftView = [self makeInputView:@"码率" des:@"Kbps"];
        inputLeftView.frame = CGRectMake(16, 60, self.view.frame.size.width/2, 30);
        [bgView addSubview:inputLeftView];
        UIView *inputRigthView = [self makeInputView:@"帧率" des:@"fps"];
        inputRigthView.frame = CGRectMake(self.view.frame.size.width/2, 60, self.view.frame.size.width/2, 30);
        [bgView addSubview:inputRigthView];
    }
    
    [self.view addSubview:bgView];
}

- (UIView *)makeButtonView:(NSArray *)titles {
    UIView *buttonView = [UIView new];
    
    int space = 10;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    int buttonWidth = (screenSize.width - 20 * (titles.count + 1)) /titles.count;
    
    for (int i =0; i < titles.count; i++) {
        UIButton *button = [UIButton new];
        button.frame = CGRectMake(16+i*(buttonWidth+space), 0, buttonWidth, 40);
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
        [button setTitleColor:HEXCOLOR(0x323333) forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        [button setBackgroundImageColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundImageColor:HEXCOLOR(0x22bbf4) forState:UIControlStateSelected];
        button.tag = i + 100;
        if (i == 1) {
            button.selected = YES;
        }
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 2;
        button.layer.borderColor = HEXCOLOR(0xe7e7e7).CGColor;
        button.layer.borderWidth = 1;
        
        
        [button addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [buttonView addSubview:button];
    }
    
    
    return buttonView;
}


- (UIView *)makeInputView:(NSString *)title des:(NSString *)des {
    
    UIView *inputView = [UIView new];
    
    UILabel *detailLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    detailLable.text = title;
    detailLable.font = [UIFont systemFontOfSize:14];
    detailLable.textColor = HEXCOLOR(0x323333);
    detailLable.textAlignment = NSTextAlignmentLeft;
    [inputView addSubview:detailLable];
    
    UITextField *minTextfield = [[UITextField alloc] initWithFrame:CGRectMake(30, 0, 80, 20)];
    minTextfield.font = [UIFont systemFontOfSize:16];
    minTextfield.delegate = self;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    minTextfield.leftView = paddingView;
    minTextfield.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 19, 80, 1)];
    line.backgroundColor = HEXCOLOR(0xdcdcdc);
    [minTextfield addSubview:line];
    
    minTextfield.tag = _inputTag;
    _inputTag ++;
    
    [_textFiledArray addObject:minTextfield];
    
    
    [inputView addSubview:minTextfield];
    
    UILabel *lastLable = [[UILabel alloc] initWithFrame:CGRectMake(30+80, 0, 40, 20)];
    lastLable.text = des;
    lastLable.font = [UIFont systemFontOfSize:14];
    lastLable.textColor = HEXCOLOR(0x323333);
    lastLable.textAlignment = NSTextAlignmentLeft;
    [inputView addSubview:lastLable];
    
    return inputView;
}

- (void)selectAction:(UIButton *)button {
    
    for (UIView *view in button.superview.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [(UIButton *)view setSelected:NO];
        }
    }
    button.selected = YES;
    
    int width = 0;
    int heigth = 0;
    int fps = 30;
    int bitrate = 0;
    
    switch (button.tag) {
        case 100:{
            width = 640;
            heigth = 360;
            fps = 15;
            bitrate = 384;
            break;
        }
        case 101:{
            width = 864;
            heigth = 480;
            fps = 20;
            bitrate = 512;
            break;
        }
        case 102:{
            width = 1280;
            heigth = 720;
            fps = 25;
            bitrate = 1152;
            break;
        }
        case 103:{
            width = 1920;
            heigth = 1080;
            fps = 30;
            bitrate = 2560;
            break;
        }
    }
    
    [[_textFiledArray objectAtIndex:0] setText:[NSString stringWithFormat:@"%d", width]];
    [[_textFiledArray objectAtIndex:1] setText:[NSString stringWithFormat:@"%d", heigth]];
    [[_textFiledArray objectAtIndex:2] setText:[NSString stringWithFormat:@"%d", bitrate]];
    [[_textFiledArray objectAtIndex:3] setText:[NSString stringWithFormat:@"%d", fps]];
    
}


#pragma mark---UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    NSLog(@"textFieldDidBeginEditing");
    
    CGRect rect = [textField convertRect: textField.bounds toView:self.view];
    CGFloat heights = self.view.frame.size.height;
    
    // 当前点击textfield的坐标的Y值 + 当前点击textFiled的高度 - （屏幕高度- 键盘高度 - 键盘上tabbar高度）
    
    // 在这一部 就是了一个 当前textfile的的最大Y值 和 键盘的最全高度的差值，用来计算整个view的偏移量
    
    int offset = rect.origin.y + 42- ( heights - 216.0-35.0);//键盘高度216
    
    NSTimeInterval animationDuration = 0.30f;
    
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    
    [UIView setAnimationDuration:animationDuration];
    
    float width = self.view.frame.size.width;
    
    float height = self.view.frame.size.height;
    
    if(offset > 0) {
        CGRect rect = CGRectMake(0.0f, -offset,width,height);
        self.view.frame = rect;
    }
    
    [UIView commitAnimations];
}

@end
