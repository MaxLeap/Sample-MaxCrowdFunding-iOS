//
//  MCHomeCFCell.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/11.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCHomeCFCell.h"
#import "MCCrowdFunding.h"

@interface MCHomeCFCell ()
@property (nonatomic, strong) UIImageView *preImageView;
@property (nonatomic, strong) UIImageView *typeIndicatorView;
@property (nonatomic, strong) UILabel *cfTitleLabel;
@property (nonatomic, strong) UILabel *tagetLabel;
@property (nonatomic, strong) UILabel *completeLabel;
// progress
@property (nonatomic, strong) UIProgressView *pregressView;
@property (nonatomic, strong) UILabel *progressLabel;
@end

@implementation MCHomeCFCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self.contentView addSubview:self.preImageView];
    [self.contentView addSubview:self.typeIndicatorView];
    [self.contentView addSubview:self.cfTitleLabel];
    [self.contentView addSubview:self.tagetLabel];
    [self.contentView addSubview:self.completeLabel];
    
    // progress
    [self.contentView addSubview:self.pregressView];
    [self.contentView addSubview:self.progressLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat border = 10;
    CGFloat imgH = height - border * 2;
    CGFloat imgW = 140;
    self.preImageView.frame = CGRectMake(border, border, imgW, imgH);
    
    CGFloat indicatorW = 35;
    self.typeIndicatorView.frame = CGRectMake(border, border, indicatorW, indicatorW);
    
    CGFloat labelX = CGRectGetMaxX(self.preImageView.frame) + 10;
    CGFloat labelW = width - labelX - border;
    CGFloat titleLabelH = 42;
    self.cfTitleLabel.frame = CGRectMake(labelX, border, labelW, titleLabelH);
    
    CGFloat numLabelH = 20;
    CGFloat completeLabelY = CGRectGetMaxY(self.preImageView.frame) - numLabelH;
    self.completeLabel.frame = CGRectMake(labelX, completeLabelY, labelW, numLabelH);
    
    CGFloat targetLabelY = CGRectGetMinY(self.completeLabel.frame) - 3 - numLabelH;
    self.tagetLabel.frame = CGRectMake(labelX, targetLabelY, labelW, numLabelH);
    
    // progress
    CGFloat progressY = CGRectGetMaxY(self.cfTitleLabel.frame) + 10;
    CGFloat progressH = 15;
    CGFloat progressLabelW = 25;
    CGFloat progressLabelX = width - border - progressLabelW;
    self.progressLabel.frame = CGRectMake(progressLabelX, progressY - progressH / 2, progressLabelW, progressH);
    
    CGFloat progressViewW = width - labelX - border - progressLabelW - 5;
    self.pregressView.frame = CGRectMake(labelX, progressY, progressViewW, progressH);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.typeIndicatorView.hidden = NO;
    self.pregressView.hidden = NO;
    self.progressLabel.hidden = NO;
}

- (void)updateContentWithCrowdFunding:(MCCrowdFunding *)crowdFunding showProgress:(BOOL)showProgress {
    NSArray *photos = crowdFunding.photos;
    NSString *preImageURL = @"";
    if (photos.count) {
        preImageURL = photos.firstObject;
    }
    [self.preImageView sd_setImageWithURL:[NSURL URLWithString:preImageURL] placeholderImage:ImageNamed(@"")];
    
    self.cfTitleLabel.text = crowdFunding.projectName;
    BOOL isDreamCF = crowdFunding.isDreamCF;
    self.typeIndicatorView.image = isDreamCF ? ImageNamed(@"bg_tag_list_mengxiang") : ImageNamed(@"bg_tag_list_chanpin");
    
    NSInteger targetNum = crowdFunding.targetNum;
    NSString *targetInfo = [NSString stringWithFormat:@"目标金额: ￥%ld", (long)targetNum];
    self.tagetLabel.text = targetInfo;
    
    NSInteger completeNum = crowdFunding.completeNum;
    NSString *completeInfo = [NSString stringWithFormat:@"已筹金额: ￥%ld", (long)completeNum];
    self.completeLabel.attributedText = [self attributedStringFromCompleteInfo:completeInfo];
    
    CGFloat progress = (CGFloat)completeNum / targetNum;
    progress = progress < 0 ? 0 : progress;
    progress = progress > 1 ? 1 : progress;
    [self.pregressView setProgress:progress animated:YES];
    NSString *progressPercent = [NSString stringWithFormat:@"%.0f%@", progress * 100, @"%"];
    self.progressLabel.text = progressPercent;
    
    if (showProgress) {
        self.typeIndicatorView.hidden = YES;
    } else {
        self.progressLabel.hidden = YES;
        self.pregressView.hidden = YES;
    }
}

- (NSAttributedString *)attributedStringFromCompleteInfo:(NSString *)completeInfo {
    NSRange range = [completeInfo rangeOfString:completeInfo];
    NSRange range1 = [completeInfo rangeOfString:@"￥"];
    
    NSRange txtRange = NSMakeRange(range.location, range1.location - 1);
    NSRange numRange = NSMakeRange(range1.location, range.length - range1.location);
    NSMutableAttributedString *mAttributeStr = [[NSMutableAttributedString alloc] initWithString:completeInfo];
    [mAttributeStr setAttributes:@{
               NSFontAttributeName: [UIFont systemFontOfSize:11],
               NSForegroundColorAttributeName: UIColorFromRGBA(52, 55, 59, 0.3)
                                   } range:txtRange];
    [mAttributeStr setAttributes:@{
               NSFontAttributeName: [UIFont systemFontOfSize:15],
               NSForegroundColorAttributeName: UIColorFromRGBA(52, 55, 59, 1)
                                   } range:numRange];
    return mAttributeStr;
}

#pragma mark - getters 
- (UIImageView *)preImageView {
    if (!_preImageView) {
        _preImageView = [[UIImageView alloc] init];
    }
    return _preImageView;
}

- (UIImageView *)typeIndicatorView {
    if (!_typeIndicatorView) {
        _typeIndicatorView = [[UIImageView alloc] init];
    }
    return _typeIndicatorView;
}

- (UILabel *)cfTitleLabel {
    if (!_cfTitleLabel) {
        _cfTitleLabel = [[UILabel alloc] init];
        _cfTitleLabel.numberOfLines = 0;
        _cfTitleLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
        _cfTitleLabel.font = [UIFont systemFontOfSize:15];
    }
    return _cfTitleLabel;
}

- (UILabel *)tagetLabel {
    if (!_tagetLabel) {
        _tagetLabel = [[UILabel alloc] init];
        _tagetLabel.textColor = UIColorFromRGBA(52, 55, 59, 0.3);
        _tagetLabel.font = [UIFont systemFontOfSize:11];
    }
    return _tagetLabel;
}

- (UILabel *)completeLabel {
    if (!_completeLabel) {
        _completeLabel = [[UILabel alloc] init];
    }
    return _completeLabel;
}

// pregress
- (UIProgressView *)pregressView {
    if (!_pregressView) {
        _pregressView = [[UIProgressView alloc] init];
        _pregressView.progressTintColor = UIColorFromRGBA(4, 195, 173, 1);
    }
    return _pregressView;
}

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.font = [UIFont systemFontOfSize:11];
        _progressLabel.textColor = UIColorFromRGBA(52, 55, 59, 0.3);
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _progressLabel;
}
@end
