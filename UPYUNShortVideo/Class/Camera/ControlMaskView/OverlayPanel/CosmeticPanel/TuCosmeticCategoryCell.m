//
//  TuCosmeticCategoryCell.m
//  TuSDKVideoDemo
//
//  Created by 刘鹏程 on 2020/10/21.
//  Copyright © 2020 TuSDK. All rights reserved.
//

#import "TuCosmeticCategoryCell.h"
#import "TuSDKFramework.h"
#import "TuCosmeticConfig.h"
//大分类Category模型
@implementation TuCosmeticHeaderData
- (instancetype)init
{
    if (self = [super init])
    {
        _cosmeticExistType = TuCosmeticTypeNone;
    }
    return self;
}

- (void)setCosmeticCode:(NSString *)cosmeticCode
{
    _cosmeticCode = cosmeticCode;
}

- (void)setCosmeticSelectType:(TuCosmeticSelectType)cosmeticSelectType
{
    _cosmeticSelectType = cosmeticSelectType;
}

- (void)setCosmeticExistType:(TuCosmeticType)cosmeticExistType
{
    _cosmeticExistType = cosmeticExistType;
}

@end

//category下细分模型
@implementation TuCosmeticItemData
- (instancetype)init
{
    if (self = [super init])
    {
        _stickerName = @"not";
    }
    return self;
}

- (void)setItemCode:(NSString *)itemCode
{
    _stickerName = itemCode;
}

- (void)setCosmeticSelectType:(TuCosmeticSelectType)cosmeticSelectType
{
    _cosmeticSelectType = cosmeticSelectType;
}

- (void)setCosmeticCode:(NSString *)cosmeticCode
{
    _cosmeticCode = cosmeticCode;
}

@end

@implementation TuCosmeticLipStickData

- (instancetype)init
{
    if (self = [super init])
    {
        _lipStickType = TuCosmeticLipSticktWaterWet;
    }
    return self;
}

- (void)setItemCode:(NSString *)itemCode
{
    _itemCode = itemCode;
}

- (void)setCosmeticCode:(NSString *)cosmeticCode
{
    _cosmeticCode = cosmeticCode;
}

- (void)setLipStickType:(TuCosmeticLipSticktType)lipStickType
{
    _lipStickType = lipStickType;
}

@end


@implementation TuCosmeticEyeBrowData

- (instancetype)init
{
    if (self = [super init])
    {
        _eyeBrowType = TuCosmeticEyeBrowFog;
    }
    return self;
}

- (void)setItemCode:(NSString *)itemCode
{
    _itemCode = itemCode;
}

- (void)setCosmeticCode:(NSString *)cosmeticCode
{
    _cosmeticCode = cosmeticCode;
}

- (void)setEyeBrowType:(TuCosmeticEyeBrowType)eyeBrowType
{
    _eyeBrowType = eyeBrowType;
}

@end

@interface TuCosmeticCategoryCell()
{
    UILabel *_titleLabel;
    UIImageView *_thumbnailView;
    UIImageView *_selectImageView;
    UIView *_pointView;
    //标记线
    UIView *_leftLineView;
    //选中点
    UIView *_selectPointView;
    
}

@end

@implementation TuCosmeticCategoryCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self initWithSubViews];
    }
    return self;
}

- (void)initWithSubViews
{
    _thumbnailView = [[UIImageView alloc] init];
    _thumbnailView.contentMode = UIViewContentModeScaleAspectFit;
    _thumbnailView.layer.masksToBounds = YES;
    [self addSubview:_thumbnailView];
    
    _selectImageView = [[UIImageView alloc] init];
    _selectImageView.layer.masksToBounds = YES;
    _selectImageView.backgroundColor = [UIColor colorWithRed:255 / 255.f green:204 / 255.f blue:0 alpha:0.75];
    _selectImageView.image = [UIImage imageNamed:@"sele_ic"];
    [self addSubview:_selectImageView];
    _selectImageView.hidden = YES;
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:10];
    _titleLabel.textColor = [UIColor colorWithWhite:1 alpha:0.35];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];

    
    _selectPointView = [[UIView alloc] init];
    _selectPointView.backgroundColor = [UIColor colorWithRed:255 / 255.f green:204 / 255.f blue:0 alpha:1];
    _selectPointView.layer.cornerRadius = 2.f;
    [self addSubview:_selectPointView];
    _selectPointView.hidden = YES;
    
    _leftLineView = [[UIView alloc] init];
    _leftLineView.hidden = YES;
    _leftLineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    [self addSubview:_leftLineView];
    
    
    _pointView = [[UIView alloc] init];
    _pointView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    _pointView.layer.cornerRadius = 3;
    _pointView.hidden = YES;
    [self addSubview:_pointView];
}

- (void)layoutSubviews
{
    CGSize size = self.bounds.size;
    const CGFloat labelHeight = 22;
    const CGFloat imageWidth = 40;
    
    CGFloat margin = 0;
    CGFloat labelWidth = size.width;
    CGFloat titleMinX = 0;

    _thumbnailView.frame = CGRectMake(size.width / 2 - imageWidth / 2 + margin, 12, imageWidth, imageWidth);
    _titleLabel.frame = CGRectMake(titleMinX, CGRectGetHeight(_thumbnailView.frame) + CGRectGetMinY(_thumbnailView.frame), labelWidth, labelHeight);
    
    _thumbnailView.layer.cornerRadius = imageWidth / 2;
    
    _selectImageView.frame = _thumbnailView.frame;
    _selectImageView.layer.cornerRadius = _thumbnailView.layer.cornerRadius;
    
    _selectPointView.frame = CGRectMake(size.width / 2 - 2, CGRectGetMaxY(_titleLabel.frame), 4, 4);
    
    _leftLineView.frame = CGRectMake(size.width - 6, imageWidth / 2 + 0, 1, 28);
    
    _pointView.frame = CGRectMake(0, 0, 6, 6);
    _pointView.center = _thumbnailView.center;
}

//口红等大分类
- (void)setData:(TuCosmeticHeaderData *)data
{
    _data = data;
    
    _selectImageView.hidden = _pointView.hidden = YES;
    
    _leftLineView.hidden = YES;
    
    _thumbnailView.hidden = _titleLabel.hidden = NO;

    if ([data.cosmeticCode isEqualToString:@"reset"])
    {
        _thumbnailView.image = [UIImage imageNamed:@"makeup_not_ic"];
        _titleLabel.text = NSLocalizedStringFromTable(@"tu_cosmeticReset", @"VideoDemo", @"美妆");
        _selectPointView.hidden = YES;
    }
    else if ([data.cosmeticCode isEqualToString:@"point"])
    {
        _titleLabel.text = @"";
        _thumbnailView.hidden = _selectImageView.hidden = _leftLineView.hidden = _selectPointView.hidden = YES;

        _pointView.hidden = NO;
    }
    else
    {
        NSString *thumbName = [NSString stringWithFormat:@"makeup_%@_ic", data.cosmeticCode];
        _thumbnailView.image = [UIImage imageNamed:thumbName];
        
        NSString *titleName = [NSString stringWithFormat:@"tu_%@", data.cosmeticCode];
        _titleLabel.text = NSLocalizedStringFromTable(titleName, @"VideoDemo", @"美妆");
        if (_data.cosmeticSelectType == TuCosmeticSelectTypeUnselected)
        {
            _selectPointView.hidden = data.cosmeticExistType == TuCosmeticTypeNone ? YES : NO;
        }
        else
        {
            _thumbnailView.hidden = _titleLabel.hidden = _selectPointView.hidden = YES;
        }
    }
}

//小分类
- (void)setItemData:(TuCosmeticItemData *)itemData
{
    _itemData = itemData;
    NSString *imagePath;
    
    _selectPointView.hidden = _leftLineView.hidden = _pointView.hidden = YES;
    _titleLabel.hidden = NO;
    if ([itemData.stickerName isEqualToString:@"back"])
    {
        //收起按钮
        NSString *thumbName = [NSString stringWithFormat:@"makeup_%@_ic", itemData.stickerName];
        
        NSString *titleName = [NSString stringWithFormat:@"tu_%@", itemData.cosmeticCode];
        _titleLabel.text = NSLocalizedStringFromTable(titleName, @"VideoDemo", @"美妆");
        
        _thumbnailView.image = [UIImage imageNamed:thumbName];
        
        _thumbnailView.hidden = NO;
        _selectImageView.hidden = YES;
    }
    else if ([itemData.stickerName isEqualToString:@"reset"])
    {
        //重置按钮
        NSString *thumbName = [NSString stringWithFormat:@"%@_ic", itemData.stickerName];
        
        NSString *titleName = [NSString stringWithFormat:@"tu_%@", itemData.stickerName];
        _titleLabel.text = NSLocalizedStringFromTable(titleName, @"VideoDemo", @"美妆");
        _thumbnailView.image = [UIImage imageNamed:thumbName];
        
        _thumbnailView.hidden = NO;
        _selectImageView.hidden = YES;
    
    }
    else if ([itemData.stickerName isEqualToString:@"point"])
    {
        _titleLabel.text = @"";
        _thumbnailView.hidden = _selectImageView.hidden = _leftLineView.hidden = _selectPointView.hidden = YES;

        _pointView.hidden = NO;
    }
    else
    {
        NSString *thumbName = itemData.stickerName;
        
        if ([itemData.cosmeticCode isEqualToString:@"lipstick"])
        {
            _titleLabel.text = NSLocalizedStringFromTable(itemData.stickerName, @"VideoDemo", @"美妆");
        }
        else if ([itemData.cosmeticCode isEqualToString:@"eyebrow"])
        {
            NSString *titleName = [NSString stringWithFormat:@"tu_%@", itemData.stickerName];
            _titleLabel.text = NSLocalizedStringFromTable(titleName, @"VideoDemo", @"美妆");
            if (_eyeBrowData.eyeBrowType == TuCosmeticEyeBrowFog)
            {
                thumbName = [thumbName stringByAppendingString:@"a"];
            }
            else
            {
                thumbName = [thumbName stringByAppendingString:@"b"];
            }
        }
        else
        {
            NSArray *eyeLinerArray = [TuCosmeticConfig dataSetWithCosmeticCode:itemData.cosmeticCode];
            NSInteger stickerIndex = [eyeLinerArray indexOfObject:itemData.stickerName];
            _titleLabel.text = [NSString stringWithFormat:@"%ld", stickerIndex - 3];
        }
        
        imagePath = [[NSBundle mainBundle] pathForResource:thumbName ofType:@"jpg"];
        _thumbnailView.image = [UIImage imageWithContentsOfFile:imagePath];
        
        if (itemData.cosmeticSelectType == TuCosmeticSelectTypeUnselected)
        {
            _thumbnailView.hidden = NO;
            _selectImageView.hidden = YES;
        }
        else
        {
            _thumbnailView.hidden = YES;
            _selectImageView.hidden = NO;
        }
    }
}

//口红类型
- (void)setLipStickData:(TuCosmeticLipStickData *)lipStickData
{
    _thumbnailView.hidden = _titleLabel.hidden = NO;
    _selectImageView.hidden = _selectPointView.hidden = _pointView.hidden = YES;
    _leftLineView.hidden = NO;
    
    _lipStickData = lipStickData;
    NSString *thumbName;
    
    if (lipStickData.lipStickType == TuCosmeticLipSticktWaterWet)
    {
        //水润
        _titleLabel.text = NSLocalizedStringFromTable(@"tu_水润", @"VideoDemo", @"美妆");
        thumbName = @"lipstick_water_ic";
    }
    else if (lipStickData.lipStickType == TuCosmeticLipSticktMoist)
    {
        //滋润
        _titleLabel.text = NSLocalizedStringFromTable(@"tu_滋润", @"VideoDemo", @"美妆");
        thumbName = @"lipstick_moist_ic";
    }
    else
    {
        //雾面
        _titleLabel.text = NSLocalizedStringFromTable(@"tu_雾面", @"VideoDemo", @"美妆");
        thumbName = @"lipstick_matte_ic";
    }
    _thumbnailView.image = [UIImage imageNamed:thumbName];
    
}

//眉毛类型
- (void)setEyeBrowData:(TuCosmeticEyeBrowData *)eyeBrowData
{
    _thumbnailView.hidden = _titleLabel.hidden = NO;
    _selectImageView.hidden = _selectPointView.hidden = _pointView.hidden = YES;
    _leftLineView.hidden = NO;
    
    _eyeBrowData = eyeBrowData;
    
    NSString *thumbName;
    if (_eyeBrowData.eyeBrowType == TuCosmeticEyeBrowFog)
    {
        thumbName = @"makeup_eyebrow_ic";
        _titleLabel.text = NSLocalizedStringFromTable(@"tu_雾眉", @"VideoDemo", @"美妆");
    }
    else
    {
        thumbName = @"eyebrow_root_ic";
        _titleLabel.text = NSLocalizedStringFromTable(@"tu_雾根眉", @"VideoDemo", @"美妆");
    }
    _thumbnailView.image = [UIImage imageNamed:thumbName];
}


@end
