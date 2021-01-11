//
//  EditRationListItemView.m
//  TuSDKVideoDemo
//
//  Created by sprint on 2019/3/1.
//  Copyright © 2019 TuSDK. All rights reserved.
//

#import "EditRatioListItemView.h"
#import "TuSDKFramework.h"


@interface EditRatioListItemView ()

@property (weak, nonatomic) IBOutlet UILabel *rationTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *ratioImageView;


@end

@implementation EditRatioListItemView

- (void)setModel:(EditRationModel *)model;{
    _model = model;
    _ratioImageView.image = [UIImage imageNamed:model.iconName];
    _rationTitleLabel.text = NSLocalizedStringFromTable(model.title, @"VideoDemo", @"无需国际化");
}

- (void)setSelected:(BOOL)selected;{
    [super setSelected:selected];
    _ratioImageView.image = selected ?  [UIImage imageNamed:self.model.selectedIconName] : [UIImage imageNamed:self.model.iconName];
    _rationTitleLabel.textColor = selected ? [UIColor lsqClorWithHex:@"#ffcc00"] : [UIColor whiteColor];
}

@end


@implementation EditRationModel



@end

