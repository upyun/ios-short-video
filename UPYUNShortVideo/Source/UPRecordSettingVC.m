//
//  UPRecordSettingVC.m
//  UPYUNShortVideo
//
//  Created by lingang on 2017/11/10.
//  Copyright © 2017年 upyun. All rights reserved.
//

#import "UPRecordSettingVC.h"
#import "TopNavBar.h"
#import "RecordCameraViewController.h"
#import "UPSettingConfig.h"

@interface UPRecordSettingVC () <TopNavBarDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate>


// 录制相机顶部控制栏视图
@property (nonatomic, strong) TopNavBar *topBar;
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, copy) NSMutableArray<UITextField *>* textFiledArray;
@property (nonatomic, assign) NSUInteger inputTag;

@property (nonatomic, assign) int watermarkPosition;


@end

@implementation UPRecordSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _watermarkPosition = 4;
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
    [_topBar addTopBarInfoWithTitle:@"拍摄配置"
                        leftButtonInfo:@[backBtnTitle]
                       rightButtonInfo:@[NSLocalizedString(@"lsq_next_step", @"下一步")]];
    [self.view addSubview:_topBar];
    
    
    
    NSArray *title = @[@"时长", @"清晰度", @"分辨率", @"帧码率", @"水印"];
    
    
    
    _scrollView = [[UIScrollView alloc ] initWithFrame:CGRectMake(0, 50, self.view.lsqGetSizeWidth, self.view.lsqGetSizeHeight - 50)];
//    _scrollView.pagingEnabled = YES;
    _scrollView.backgroundColor = HEXCOLOR(0xe7e7e7);
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    [self.view addSubview: _scrollView];
    CGSize newSize = CGSizeMake(self.view.frame.size.width, title.count * 110 + 100) ;
    [_scrollView setContentSize:newSize];
    
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
            // 下一步按钮
            
            UPSettingConfig *config = [self getConfigInput];
            
            if ( config.minRecordingTime > 10 || config.minRecordingTime < 1) {
                [[TuSDK shared].messageHub showError:@"最小时长应该在 1-10 秒之间"];
                return;
            }
            
            if (config.maxRecordingTime > 600 || config.maxRecordingTime < 10) {
                [[TuSDK shared].messageHub showError:@"最大时长应该在 10-600 秒之间"];
                return;
            }
            
            if (config.outputSize.width <= 0 || config.outputSize.height <= 0) {
                [[TuSDK shared].messageHub showError:@"长宽不应该为0"];
                return;
            }
            
            
            RecordCameraViewController *vc = [RecordCameraViewController new];
            vc.inputRecordMode = lsqRecordModeKeep;
            vc.settingConfig = config;
            
            [self.navigationController pushViewController:vc animated:YES];
            
//            [self.navigationController pushViewController:vc animated:true];
        }
            break;
            
        default:
            break;
    }
    
}


- (void)configInput {
    UPSettingConfig *config = [UPSettingConfig defaultConfig];
    
    [[_textFiledArray objectAtIndex:0] setText:[NSString stringWithFormat:@"%.0f", config.minRecordingTime]];
    [[_textFiledArray objectAtIndex:1] setText:[NSString stringWithFormat:@"%.0f", config.maxRecordingTime]];
    [[_textFiledArray objectAtIndex:2] setText:[NSString stringWithFormat:@"%.0f", config.outputSize.width]];
    [[_textFiledArray objectAtIndex:3] setText:[NSString stringWithFormat:@"%.0f", config.outputSize.height]];
    [[_textFiledArray objectAtIndex:4] setText:[NSString stringWithFormat:@"%lu", (unsigned long)config.lsqVideoBitRate]];
    [[_textFiledArray objectAtIndex:5] setText:[NSString stringWithFormat:@"%d", config.frameRate]];
    
    
    
    
}

- (UPSettingConfig *)getConfigInput {
    
    
    
    
    
    UPSettingConfig *config = [[UPSettingConfig alloc] init];
    config.minRecordingTime = [[_textFiledArray objectAtIndex:0] text].intValue;
    config.maxRecordingTime = [[_textFiledArray objectAtIndex:1] text].intValue;
    

    
    
    
    int width = [[_textFiledArray objectAtIndex:2] text].intValue;
    int heigth = [[_textFiledArray objectAtIndex:3] text].intValue;
    config.outputSize = CGSizeMake(width, heigth);
    config.lsqVideoBitRate = [[_textFiledArray objectAtIndex:4] text].intValue;
    config.frameRate = [[_textFiledArray objectAtIndex:5] text].intValue;
    config.watermarkPosition = _watermarkPosition;
    
    return config;
}


- (void)initView:(int)type withTitle:(NSString *)title{
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 10 + type * (110), self.view.bounds.size.width - 20, 100)];
    bgView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, 60, 24)];
    titleLabel.text = title;
    titleLabel.textColor = HEXCOLOR(0x323333);
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [bgView addSubview:titleLabel];
    
    if (type == 0) {
        UIView *inputLeftView = [self makeInputView:@"最小" des:@"s"];
        inputLeftView.frame = CGRectMake(16, 60, self.view.frame.size.width/2, 30);
        [bgView addSubview:inputLeftView];
        UIView *inputRigthView = [self makeInputView:@"最大" des:@"s"];
        
        inputRigthView.frame = CGRectMake(self.view.frame.size.width/2, 60, self.view.frame.size.width/2, 30);
        [bgView addSubview:inputRigthView];
    } else if (type == 1) {
        
        UIView *buttonView = [self makeButtonView:@[@"低清", @"标清", @"高清", @"超清"]];
        buttonView.frame = CGRectMake(0, 50, self.view.frame.size.width, 40);
        [bgView addSubview:buttonView];
    } else if (type == 2) {
        
        UIView *inputLeftView = [self makeInputView:@"宽度" des:@"px"];
        inputLeftView.frame = CGRectMake(16, 60, self.view.frame.size.width/2, 30);
        [bgView addSubview:inputLeftView];
        UIView *inputRigthView = [self makeInputView:@"高度" des:@"px"];
        inputRigthView.frame = CGRectMake(self.view.frame.size.width/2, 60, self.view.frame.size.width/2, 30);
        [bgView addSubview:inputRigthView];
    } else if (type == 3) {
        
        UIView *inputLeftView = [self makeInputView:@"码率" des:@"Kbps"];
        inputLeftView.frame = CGRectMake(16, 60, self.view.frame.size.width/2, 30);
        [bgView addSubview:inputLeftView];
        UIView *inputRigthView = [self makeInputView:@"帧率" des:@"fps"];
        inputRigthView.frame = CGRectMake(self.view.frame.size.width/2, 60, self.view.frame.size.width/2, 30);
        [bgView addSubview:inputRigthView];
    } else if (type == 4) {
        UIView *buttonView = [self makeWaterMarkButtonView];
        buttonView.frame = CGRectMake(16, 50, self.view.frame.size.width, 120);
        bgView.frame = CGRectMake(10, 10 + type * (110), self.view.bounds.size.width - 20, 180);
        [bgView addSubview:buttonView];
    }

    [_scrollView addSubview:bgView];
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

- (UIView *)makeWaterMarkButtonView{
    UIView *buttonView = [UIView new];
    UILabel *detailLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    detailLable.text = @"方位";
    detailLable.font = [UIFont systemFontOfSize:14];
    detailLable.textColor = HEXCOLOR(0x323333);
    detailLable.textAlignment = NSTextAlignmentLeft;
    [buttonView addSubview:detailLable];
    
    
    int space = 10;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    int buttonWidth = (self.view.frame.size.width - 40 - 46) / 3;
    UIView *gridButtonView = [[UIView alloc] initWithFrame:CGRectMake(46, 0, buttonWidth *3, 40 *3)];

    
    for (int i =0; i < 9; i++) {
        UIButton *button = [UIButton new];
        
        int lineX = i %3;
        int lineY = i/3;
        
        button.frame = CGRectMake(lineX*(buttonWidth), lineY * 40, buttonWidth, 40);
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitleColor:HEXCOLOR(0xe7e7e7) forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        [button setBackgroundImageColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundImageColor:HEXCOLOR(0x22bbf4) forState:UIControlStateSelected];
        button.tag = i + 1000;
        
        if (i == 0) {
            button.selected = YES;
        }
        [button addTarget:self action:@selector(selectWaterMarkAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        if (i%2 != 0) {
            button.enabled = NO;
            button.backgroundColor = [UIColor lightGrayColor];
        }
        
        [gridButtonView addSubview:button];
    }
    
    gridButtonView.layer.borderWidth = 1;
    gridButtonView.layer.borderColor = HEXCOLOR(0xe7e7e7).CGColor;
    
    [buttonView addSubview:gridButtonView];
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
    minTextfield.textAlignment = NSTextAlignmentCenter;
    
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
    
    int vWidth = 0;
    int vHeigth = 0;
    int fps = 30;
    int bitrate = 0;
    
    switch (button.tag) {
        case 100:{
            vHeigth = 640;
            vWidth = 360;
            fps = 15;
            bitrate = 384;
            break;
        }
        case 101:{
            vHeigth = 864;
            vWidth = 480;
            fps = 20;
            bitrate = 512;
            break;
        }
        case 102:{
            vHeigth = 1280;
            vWidth = 720;
            fps = 25;
            bitrate = 1152;
            break;
        }
        case 103:{
            vHeigth = 1920;
            vWidth = 1080;
            fps = 30;
            bitrate = 2560;
            break;
        }
    }
    
    [[_textFiledArray objectAtIndex:2] setText:[NSString stringWithFormat:@"%d", vWidth]];
    [[_textFiledArray objectAtIndex:3] setText:[NSString stringWithFormat:@"%d", vHeigth]];
    [[_textFiledArray objectAtIndex:4] setText:[NSString stringWithFormat:@"%d", bitrate]];
    [[_textFiledArray objectAtIndex:5] setText:[NSString stringWithFormat:@"%d", fps]];
    
}

- (void)selectWaterMarkAction:(UIButton *)button {
    
    for (UIView *view in button.superview.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            if (view == button) {
                NSLog(@"跳过");
                continue;
            }
            [(UIButton *)view setSelected:NO];
        }
    }
    button.selected = YES;
    
    switch (button.tag) {
        case 1000:{
            _watermarkPosition = 4;
            break;
        }
        case 1002:{
            _watermarkPosition = 3;
            break;
        }
        case 1004:{
            _watermarkPosition = 5;
            break;
        }
        case 1006:{
            _watermarkPosition = 1;
            break;
        }
        case 1008:{
            _watermarkPosition = 2;
            break;
        }
    }
}

#pragma mark---UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    NSLog(@"textFieldDidBeginEditing");
    
    CGRect rect = [textField convertRect: textField.bounds toView:self.view];
    CGFloat heights = self.view.frame.size.height;
    
    // 当前点击textfield的坐标的Y值 + 当前点击textFiled的高度 - （屏幕高度- 键盘高度 - 键盘上tabbar高度）
    
    // 在这一部 就是了一个 当前textfile的的最大Y值 和 键盘的最全高度的差值，用来计算整个view的偏移量
    
    int offset = rect.origin.y + 42- ( heights - 216.0-35.0 -20);//键盘高度216
    
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
