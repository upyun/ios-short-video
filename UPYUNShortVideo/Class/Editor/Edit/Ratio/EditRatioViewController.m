//
//  EditRatioViewController.m
//  TuSDKVideoDemo
//
//  Created by sprint on 2019/3/1.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import "EditRatioViewController.h"
#import "EditRatioListView.h"

@interface EditRatioViewController ()<EditRationListViewDelegate>
{
    
    __weak IBOutlet EditRatioListView *_ratioListView;
    __weak IBOutlet NSLayoutConstraint *_rationListViewBottomConstraints;
    CGFloat _outputRatio;
}
@end

@implementation EditRatioViewController

+ (CGFloat)bottomPreviewOffset {
    return 132;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"tu_裁剪", @"VideoDemo", @"裁剪");
    _outputRatio = self.movieEditor.options.outputSizeOptions.outputRatio;
    
    for (int i = 0; i<_ratioListView.itemCount; i++) {
        EditRatioListItemView *itemView =  (EditRatioListItemView *)[_ratioListView itemViewAtIndex:i];
        if (itemView.model.ratio == self.movieEditor.options.outputSizeOptions.outputRatio)
            [_ratioListView setSelectedIndex:i];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _rationListViewBottomConstraints.constant = self.bottomNavigationBar.frame.size.height;
}

- (BOOL)shouldShowPlayButton {
    return YES;
}

/**
 取消按钮事件
 
 @param sender 取消按钮
 */
- (void)cancelButtonAction:(UIButton *)sender {
    [super cancelButtonAction:sender];
    [self.movieEditor updateOutputRatio:_outputRatio];
}


@end

@implementation EditRatioViewController(EditRationListViewDelegate)

-(void)editRatioListView:(EditRatioListView *)rationListView didSelectedItemView:(EditRatioListItemView *)itemView {
    
    [self.movieEditor updateOutputRatio:itemView.model.ratio];
}

@end
