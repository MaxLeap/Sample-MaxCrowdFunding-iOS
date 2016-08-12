//
//  MCCFDetailHeaderView.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/12.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCCFDetailHeaderView.h"
#import "MCProgressView.h"
#import "MCCrowdFunding.h"
#import "UIView+CustomBorder.h"

static CGFloat kUserIconW = 30.0f;

@interface MCCFDetailHeaderView ()
@property (nonatomic, strong) UIImageView *preImageView;
@property (nonatomic, strong) UIImageView *userIconView;
@property (nonatomic, strong) UILabel *nameAndTimeLabel;
@property (nonatomic, strong) UILabel *rightTimeLabel;
@property (nonatomic, strong) UILabel *productNameLabel;
@property (nonatomic, strong) MCProgressView *progressView;
@property (nonatomic, strong) MCDetailNumView *targetNumView;
@property (nonatomic, strong) MCDetailNumView *completeNumView;
@property (nonatomic, strong) MCDetailNumView *supportNumView;
@end

@implementation MCCFDetailHeaderView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self addSubview:self.preImageView];
    [self addSubview:self.userIconView];
    [self addSubview:self.nameAndTimeLabel];
    [self addSubview:self.rightTimeLabel];
    [self addSubview:self.productNameLabel];
    [self addSubview:self.progressView];
    
    self.targetNumView = [[MCDetailNumView alloc] init];
    self.completeNumView = [[MCDetailNumView alloc] init];
    self.supportNumView = [[MCDetailNumView alloc] init];
    [self addSubview:self.targetNumView];
    [self addSubview:self.completeNumView];
    [self addSubview:self.supportNumView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    
    CGFloat preImgH = 200;
    self.preImageView.frame = CGRectMake(0, 0, width, preImgH);
    
    CGFloat border = 15;
    CGFloat contentStartY = preImgH + border;
    self.userIconView.frame = CGRectMake(border, contentStartY, kUserIconW, kUserIconW);
    
    CGFloat rightTimeLabelW = 70;
    CGFloat rightTimeLabelX = width - border - rightTimeLabelW;
    self.rightTimeLabel.frame = CGRectMake(rightTimeLabelX, contentStartY, rightTimeLabelW, kUserIconW);
    
    CGFloat nameAndTimeLabelX = CGRectGetMaxX(self.userIconView.frame) + 10;
    CGFloat nameAndTimeLabelW = width - nameAndTimeLabelX - border - rightTimeLabelW - 5;
    self.nameAndTimeLabel.frame = CGRectMake(nameAndTimeLabelX, contentStartY, nameAndTimeLabelW, kUserIconW);
    
    CGFloat pNameLabelY = CGRectGetMaxY(self.userIconView.frame) + 10;
    CGFloat pNameLabelH = 25;
    self.productNameLabel.frame = CGRectMake(border, pNameLabelY, width - border * 2, pNameLabelH);
    
    CGFloat progressY = CGRectGetMaxY(self.productNameLabel.frame) + 12;
    CGFloat progressH = 15;
    self.progressView.frame = CGRectMake(border, progressY, width - border * 2, progressH);
    
    CGFloat numViewY = CGRectGetMaxY(self.progressView.frame) + 8;
    CGFloat numViewW = width / 3;
    CGFloat numViewH = 46;
    self.targetNumView.frame = CGRectMake(0, numViewY, numViewW, numViewH);
    self.completeNumView.frame = CGRectMake(numViewW, numViewY, numViewW, numViewH);
    self.supportNumView.frame = CGRectMake(numViewW * 2, numViewY, numViewW, numViewH);
    
    [self.targetNumView addRightBorderWithColor:UIColorFromRGBA(216, 216, 216, 0.5) width:1 excludePoint:10 edgeType:ExcludeAllPoint];
    [self.completeNumView addRightBorderWithColor:UIColorFromRGBA(216, 216, 216, 0.5) width:1 excludePoint:10 edgeType:ExcludeAllPoint];
}

- (void)updateDetailInfoWithCrowdFunding:(MCCrowdFunding *)crowdFunding {
    NSArray *photos = crowdFunding.photos;
    NSString *firstPhotoURL = photos.count > 0 ? photos.firstObject : @"";
    [self.preImageView sd_setImageWithURL:[NSURL URLWithString:firstPhotoURL] placeholderImage:ImageNamed(@"")];
    
    MLUser *publisher = crowdFunding.publisher;
    NSString *userIcon = publisher[@"iconUrl"];
    [self.userIconView sd_setImageWithURL:[NSURL URLWithString:userIcon] placeholderImage:ImageNamed(@"")];
    
    NSString *publisherName = publisher.username;
    NSDate *createDate = crowdFunding.createdAt;
    self.nameAndTimeLabel.attributedText = [self attributedStringFromUserName:publisherName createDate:createDate];
    
    NSDate *endDate = crowdFunding.endDate;
    self.rightTimeLabel.attributedText = [self attributedStringFromEndDate:endDate];
    
    self.productNameLabel.text = crowdFunding.projectName;
    
    CGFloat progress = (CGFloat)crowdFunding.completeNum / (CGFloat)crowdFunding.targetNum;
    [self updateProgress:progress];
    
    NSString *targetInfo = [NSString stringWithFormat:@"%ld元", (long)crowdFunding.targetNum];
    [self.targetNumView updateContentTopTxt:@"目标金额" bottomTxt:targetInfo];
    
    NSString *completeInfo = [NSString stringWithFormat:@"%ld元", (long)crowdFunding.completeNum];
    [self.completeNumView updateContentTopTxt:@"已筹金额" bottomTxt:completeInfo];
    
    NSString *supportInfo = [NSString stringWithFormat:@"%ld人", (long)crowdFunding.supportUserCount];
    [self.supportNumView updateContentTopTxt:@"支持人数" bottomTxt:supportInfo];
}

- (void)updateProgress:(CGFloat)progress {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:0.5];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressView setProgress:progress animated:YES];
        });
    });
}

- (NSAttributedString *)attributedStringFromEndDate:(NSDate *)endDate {
    NSDate *dateNow = [NSDate date];
    
    NSTimeInterval timeInterval = [endDate timeIntervalSinceDate:dateNow];
    
    if (timeInterval <= 0) {
        NSString *plainTxt = @"已结束筹款";
        return [[NSAttributedString alloc] initWithString:plainTxt
                                               attributes:@{
                    NSFontAttributeName : [UIFont systemFontOfSize:11],
                    NSForegroundColorAttributeName: UIColorFromRGBA(52, 55, 59, 0.6)}];
    }
    
    NSString *plainTxt = @"";
    NSRange blueRange;
    if (timeInterval >= 24 * 3600) {
        NSInteger day = timeInterval / (24 * 3600);
        plainTxt = [NSString stringWithFormat:@"剩余%ld天", (long)day];
        blueRange = [plainTxt rangeOfString:[NSString stringWithFormat:@"%ld", (long)day]];
    } else if (timeInterval >= 3600) {
        NSInteger hours = timeInterval / (3600);
        plainTxt = [NSString stringWithFormat:@"剩余%ld小时", (long)hours];
        blueRange = [plainTxt rangeOfString:[NSString stringWithFormat:@"%ld", (long)hours]];
    } else {
        NSInteger mins = timeInterval / 60;
        plainTxt = [NSString stringWithFormat:@"剩余%ld小时", (long)mins];
        blueRange = [plainTxt rangeOfString:[NSString stringWithFormat:@"%ld", (long)mins]];
    }
    
    NSMutableAttributedString *mAttributedStr = [[NSMutableAttributedString alloc] initWithString:plainTxt attributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:12],
            NSForegroundColorAttributeName: UIColorFromRGBA(52, 55, 59, 1)}];
    [mAttributedStr setAttributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:16],
            NSForegroundColorAttributeName: UIColorFromRGBA(59, 163, 255, 1)
                                    } range:blueRange];
    
    return mAttributedStr;
}

- (NSAttributedString *)attributedStringFromUserName:(NSString *)userName createDate:(NSDate *)createDate {
    NSString *dateStr = [[createDate description] substringToIndex:10];
    
    NSString *txt = [NSString stringWithFormat:@"%@  %@", userName, dateStr];
    NSRange nameRange = [txt rangeOfString:userName];
    NSRange dateRange = [txt rangeOfString:dateStr];
    NSMutableAttributedString *mAttributedStr = [[NSMutableAttributedString alloc] initWithString:txt];
    [mAttributedStr setAttributes:@{
                NSFontAttributeName: [UIFont systemFontOfSize:14],
                NSForegroundColorAttributeName: UIColorFromRGBA(52, 55, 59, 1)
                                    } range:nameRange];
    [mAttributedStr setAttributes:@{
                NSFontAttributeName: [UIFont systemFontOfSize:11],
                NSForegroundColorAttributeName: UIColorFromRGBA(52, 55, 59, 0.3)
                                    } range:dateRange];
    
    return mAttributedStr;
}


#pragma mark - getters
- (UIImageView *)preImageView {
    if (!_preImageView) {
        _preImageView = [[UIImageView alloc] init];
        _preImageView.contentMode = UIViewContentModeScaleAspectFill;
        _preImageView.clipsToBounds = YES;
    }
    return _preImageView;
}

- (UIImageView *)userIconView {
    if (!_userIconView) {
        _userIconView = [[UIImageView alloc] init];
        _userIconView.layer.cornerRadius = kUserIconW / 2;
        _userIconView.clipsToBounds = YES;
    }
    return _userIconView;
}

- (UILabel *)nameAndTimeLabel {
    if (!_nameAndTimeLabel) {
        _nameAndTimeLabel = [[UILabel alloc] init];
    }
    return _nameAndTimeLabel;
}

- (UILabel *)rightTimeLabel {
    if (!_rightTimeLabel) {
        _rightTimeLabel = [[UILabel alloc] init];
        _rightTimeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _rightTimeLabel;
}

- (UILabel *)productNameLabel {
    if (!_productNameLabel) {
        _productNameLabel = [[UILabel alloc] init];
        _productNameLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
        _productNameLabel.font = [UIFont systemFontOfSize:17];
    }
    return _productNameLabel;
}

- (MCProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[MCProgressView alloc] init];
    }
    return _progressView;
}
@end


#pragma MARK - MCDetailNumView
@interface MCDetailNumView ()
@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UILabel *bottomLabel;
@end

@implementation MCDetailNumView

- (id)init {
    if (self = [super init]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self addSubview:self.topLabel];
    [self addSubview:self.bottomLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat labelH = (height - 3 * 2 - 5) / 2;
    self.topLabel.frame = CGRectMake(0, 3, width, labelH);
    self.bottomLabel.frame = CGRectMake(0, 3 + labelH + 5, width, labelH);
}

- (void)updateContentTopTxt:(NSString *)topTxt bottomTxt:(NSString *)bottomTxt {
    self.topLabel.text = topTxt;
    self.bottomLabel.text = bottomTxt;
}

#pragma mark - getters
- (UILabel *)topLabel {
    if (!_topLabel) {
        _topLabel = [[UILabel alloc] init];
        _topLabel.font = [UIFont systemFontOfSize:13];
        _topLabel.textColor = UIColorFromRGBA(52, 55, 59, 0.5);
        _topLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _topLabel;
}

- (UILabel *)bottomLabel {
    if (!_bottomLabel) {
        _bottomLabel = [[UILabel alloc] init];
        _bottomLabel.font = [UIFont systemFontOfSize:16];
        _bottomLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _bottomLabel;
}

@end
