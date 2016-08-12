//
//  MCCFDetailCells.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/13.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCCFDetailCells.h"
#import "MCCFReward.h"
#import "MCSupportInfo.h"
#import "MCCFTrends.h"
#import "MCCrowdFunding.h"
#import "UITextView+Placeholder.h"
#import "UIView+CustomBorder.h"

NSString * const kMailCostInfo = @"mailCost";
NSString * const kDeliverTimeInfo = @"deliverTime";

@interface MCDetailTimeCell ()
@property (nonatomic, strong) UILabel *mailCostLabel;
@property (nonatomic, strong) UILabel *deliverTimeLabel;
@end

@implementation MCDetailTimeCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self.contentView addSubview:self.mailCostLabel];
    [self.contentView addSubview:self.deliverTimeLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat borderX = 15;
    CGFloat borderY = 10;
    CGFloat labelW = width - borderX * 2;
    CGFloat labelH = (height - borderY * 3) / 2;
    self.mailCostLabel.frame = CGRectMake(borderX, borderY, labelW, labelH);
    self.deliverTimeLabel.frame = CGRectMake(borderX, borderY * 2 + labelH, labelW, labelH);
}

- (void)updateContentWithDic:(NSDictionary *)dic {
    NSString *mailInfo = [NSString stringWithFormat:@"运费:  %@", dic[kMailCostInfo]];
    self.mailCostLabel.attributedText = [self attributedStringFromPlainTxt:mailInfo grayTxt:@"运费:"];
    
    NSString *deliverInfo = [NSString stringWithFormat:@"发货时间:  %@", dic[kDeliverTimeInfo]];
    self.deliverTimeLabel.attributedText = [self attributedStringFromPlainTxt:deliverInfo grayTxt:@"发货时间:"];
}

- (NSAttributedString *)attributedStringFromPlainTxt:(NSString *)plainTxt grayTxt:(NSString *)grayTxt {
    NSRange range = [plainTxt rangeOfString:plainTxt];
    NSRange grayRange = [plainTxt rangeOfString:grayTxt];
    NSRange blackRange = NSMakeRange(grayRange.location + grayRange.length, range.length - grayRange.length);
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:plainTxt];
    [attributedStr setAttributes:@{
           NSFontAttributeName: [UIFont systemFontOfSize:15],
           NSForegroundColorAttributeName: UIColorFromRGBA(52, 55, 59, 0.5)
                                   } range:grayRange];
    [attributedStr setAttributes:@{
           NSFontAttributeName: [UIFont systemFontOfSize:15],
           NSForegroundColorAttributeName: UIColorFromRGBA(52, 55, 59, 1)
                                   } range:blackRange];
    
    return attributedStr;
}

#pragma mark - getters
- (UILabel *)mailCostLabel {
    if (!_mailCostLabel) {
        _mailCostLabel = [[UILabel alloc] init];
    }
    return _mailCostLabel;
}

- (UILabel *)deliverTimeLabel {
    if (!_deliverTimeLabel) {
        _deliverTimeLabel = [[UILabel alloc] init];
    }
    return _deliverTimeLabel;
}
@end



#pragma mark - MCDetailRewardCell
@interface MCDetailRewardCell ()
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *supportNumLabel;
@property (nonatomic, strong) UILabel *rewardDesLabel;
@end

@implementation MCDetailRewardCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self.contentView addSubview:self.imgView];
    [self.contentView addSubview:self.supportNumLabel];
    [self.contentView addSubview:self.rewardDesLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat borderX = 15;
    CGFloat borderY = 10;
    CGFloat imgH = height - borderY * 2;
    self.imgView.frame = CGRectMake(borderX, borderY, imgH, imgH);
    
    CGFloat labelX = CGRectGetMaxX(self.imgView.frame) + 10;
    CGFloat labelW = width - labelX - borderX;
    CGFloat numLabelH = 20;
    self.supportNumLabel.frame = CGRectMake(labelX, borderY, labelW, numLabelH);
    
    CGFloat desLableY = CGRectGetMaxY(self.supportNumLabel.frame) + 3;
    CGFloat desLabelH = imgH - numLabelH - 3;
    self.rewardDesLabel.frame = CGRectMake(labelX, desLableY, labelW, desLabelH);
    
    [self addBottomBorderWithColor:UIColorFromRGBA(216, 216, 216, 0.8) width:1];
}

- (void)updateContentWithReward:(MCCFReward *)reward photo:(NSString *)photo {
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:photo] placeholderImage:ImageNamed(@"")];
    
    NSString *numString = [NSString stringWithFormat:@"支持%ld元", (long)reward.supportMoney];
    NSString *keyWord = [NSString stringWithFormat:@"%ld", (long)reward.supportMoney];
    self.supportNumLabel.attributedText = [self attributedStringForSupportMoenyInfo:numString keyWord:keyWord];
    
    self.rewardDesLabel.text = reward.rewardDes;
}

- (NSAttributedString *)attributedStringForSupportMoenyInfo:(NSString *)supportNumInfo keyWord:(NSString *)keyWord {
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:supportNumInfo attributes:@{
                NSFontAttributeName: [UIFont systemFontOfSize:15],
                NSForegroundColorAttributeName: UIColorFromRGBA(52, 55, 59, 1)
        }];
    
    NSRange redRange = [supportNumInfo rangeOfString:keyWord];
    [attributedStr setAttributes:@{
            NSForegroundColorAttributeName: UIColorFromRGBA(233, 48, 48, 1)
                                   } range:redRange];
    
    return attributedStr;
}

#pragma mark - getters
- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
    }
    return _imgView;
}

- (UILabel *)supportNumLabel {
    if (!_supportNumLabel) {
        _supportNumLabel = [[UILabel alloc] init];
    }
    return _supportNumLabel;
}

- (UILabel *)rewardDesLabel {
    if (!_rewardDesLabel) {
        _rewardDesLabel = [[UILabel alloc] init];
        _rewardDesLabel.font = [UIFont systemFontOfSize:13];
        _rewardDesLabel.textColor = UIColorFromRGBA(52, 55, 59, 0.5);
        _rewardDesLabel.numberOfLines = 0;
    }
    return _rewardDesLabel;
}

@end



#pragma mark - MCProductDetailCell
@interface MCProductDetailCell ()
@property (nonatomic, strong) UILabel *projectDetailLabel;
@property (nonatomic, strong) UIView *imgContainer;
@property (nonatomic, strong) MCCrowdFunding *crowdFunding;
@end

@implementation MCProductDetailCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self.contentView addSubview:self.self.projectDetailLabel];
    [self.contentView addSubview:self.imgContainer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat border = 15;
    CGFloat imgH = 230;
    CGFloat contentW = width - border * 2;
    
    CGFloat containerH = (imgH + border) * self.crowdFunding.photos.count;
    CGFloat containerY = height - containerH;
    self.imgContainer.frame = CGRectMake(border, containerY, contentW, containerH);
    
    NSArray *photos = self.crowdFunding.photos;
    for (NSInteger i = 0; i < photos.count; i ++) {
        UIImageView *imgView = [self.imgContainer viewWithTag:(i + 1000)];
        CGFloat imgY = (border + imgH) * i;
        imgView.frame = CGRectMake(0, imgY, contentW, imgH);
        
        NSString *photoURL = photos[i];
        [imgView sd_setImageWithURL:[NSURL URLWithString:photoURL] placeholderImage:ImageNamed(@"")];
    }
    
    CGFloat labelH = height - border * 2 - containerH;
    self.projectDetailLabel.frame = CGRectMake(border, border, contentW, labelH);
}

- (void)updateContentWithCrowdFunding:(MCCrowdFunding *)crowdFunding {
    NSString *proDes = crowdFunding.projectDes;
    self.projectDetailLabel.text = proDes;
    
    self.crowdFunding = crowdFunding;
    [self setNeedsLayout];
}

+ (CGFloat)rowHeightForCrowdFunding:(MCCrowdFunding *)crowdFunding {
    NSString *proDes = crowdFunding.projectDes;
    
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat contentW = width - 15 * 2;
    CGRect rect = [proDes boundingRectWithSize:CGSizeMake(contentW, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}
                                       context:nil];
    CGFloat rowHeight = 15 * 2 + rect.size.height + (230 + 15) * crowdFunding.photos.count;
    return rowHeight;
}

#pragma mark - getters
- (UILabel *)projectDetailLabel {
    if (!_projectDetailLabel) {
        _projectDetailLabel = [[UILabel alloc] init];
        _projectDetailLabel.font = [UIFont systemFontOfSize:12];
        _projectDetailLabel.textColor = UIColorFromRGBA(52, 55, 59, 0.8);
        _projectDetailLabel.numberOfLines = 0;
    }
    return _projectDetailLabel;
}

- (UIView *)imgContainer {
    if (!_imgContainer) {
        _imgContainer = [[UIView alloc] init];
        _imgContainer.clipsToBounds = YES;
        
        for (NSInteger i = 0; i <= 3; i ++) {
            UIImageView *imgView = [[UIImageView alloc] init];
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            imgView.clipsToBounds = YES;
            imgView.tag = 1000 + i;
            
            [_imgContainer addSubview:imgView];
        }
    }
    return _imgContainer;
}

@end



#pragma mark - MCProductTrendCell
@interface MCProductTrendCell ()
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *stateView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIView *imgContainer;

@property (nonatomic, strong) NSArray *trendPhotos;
@property (nonatomic, assign) BOOL isLatest;
@property (nonatomic, assign) BOOL isFirst;
@end

@implementation MCProductTrendCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.clipsToBounds = YES;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.stateView];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.imgContainer];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.stateView.backgroundColor = [UIColor whiteColor];
    self.trendPhotos = nil;
    for (UIImageView *imgView in self.imgContainer.subviews) {
        if ([imgView isKindOfClass:[UIImageView class]]) {
            imgView.image = nil;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat border = 15;
    CGFloat timeLableW = 40;
    CGFloat timeLabelH = 16;
    self.timeLabel.frame = CGRectMake(border - 5, border, timeLableW, timeLabelH);
    
    CGFloat stateViewX = CGRectGetMaxX(self.timeLabel.frame) + 2;
    CGFloat stateViewW = 10;
    CGFloat stateViewY = border + (timeLabelH - stateViewW) / 2;
    self.stateView.frame = CGRectMake(stateViewX, stateViewY, stateViewW, stateViewW);
    
    CGFloat contentX = CGRectGetMaxX(self.stateView.frame) + 4;
    CGFloat contentW = width - contentX - border;
    CGFloat contentH = _trendPhotos.count ? height - border * 2 - 70 + 10 : height - border * 2;
    self.contentLabel.frame = CGRectMake(contentX, border, contentW, contentH);
    
    CGFloat imgContainerH = 70;
    CGFloat imgContainerY = height - 5 - imgContainerH;
    CGFloat imgContainerW = width - contentX;
    self.imgContainer.frame = CGRectMake(contentX, imgContainerY, imgContainerW, imgContainerH);
    if (self.trendPhotos.count) {
        CGFloat imgW = (imgContainerW - (_trendPhotos.count - 1)) / self.trendPhotos.count;
        imgW = imgW > 70 ? 70 : imgW;
        for (NSInteger i = 0; i < self.trendPhotos.count; i ++) {
            CGFloat imgX = (imgW + 1) * i;
            UIImageView *imgView = [self.imgContainer viewWithTag:(i + 1000)];
            imgView.frame = CGRectMake(imgX, 0, imgW, imgContainerH);
            
            NSString *imgURL = self.trendPhotos[i];
            [imgView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:ImageNamed(@"")];
        }
    }
    
    CGFloat lineW = 1;
    CGFloat lineX = CGRectGetMidX(self.stateView.frame);
    CGFloat lineY = 0;
    CGFloat lineH = height;
    if (self.isLatest) {
        lineY = CGRectGetMaxY(self.stateView.frame);
        lineH = height - lineY;
    } else if (self.isFirst) {
        lineH = CGRectGetMinY(self.stateView.frame);
    } else {
    }
    self.lineView.frame = CGRectMake(lineX, lineY, lineW, lineH);
}

- (void)updateContentWithTrend:(MCCFTrends *)trend isLatest:(BOOL)latest isFirst:(BOOL)isFirst {
    
    NSArray *photos = trend.photos;
    self.isLatest = latest;
    self.isFirst = isFirst;
    self.trendPhotos = photos;
    [self setNeedsLayout];
    
    self.contentLabel.text = trend.trendContent;
    
    NSString *timeInfo;
    if (latest) {
        timeInfo = @"最新";
        self.timeLabel.textColor = UIColorFromRGBA(59, 163, 255, 1);
        self.stateView.backgroundColor = UIColorFromRGBA(59, 163, 255, 1);
        self.stateView.layer.borderColor = UIColorFromRGBA(59, 163, 255, 0.5).CGColor;
        self.stateView.layer.borderWidth = 2;
    } else {
        timeInfo = [self timeInfoFromDate:trend.createdAt];
        self.timeLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
        self.stateView.backgroundColor = [UIColor whiteColor];
        self.stateView.layer.borderWidth = 1;
        self.stateView.layer.borderColor = UIColorFromRGBA(216, 216, 216, 1).CGColor;
    }
    self.timeLabel.text = timeInfo;
}

- (NSString *)timeInfoFromDate:(NSDate *)date {
    NSDate *dateNow = [NSDate date];
    NSTimeInterval interval = [dateNow timeIntervalSinceDate:date];
    
    NSString *result;
    if (interval > 24 * 3600) {
        NSInteger day = interval / (24 * 3600);
        result = [NSString stringWithFormat:@"%ld天前", (long)day];
    } else if (interval > 3600) {
        NSInteger hours = interval / 3600;
        result = [NSString stringWithFormat:@"%ld小时前", (long)hours];
    } else {
        NSInteger mins = interval / 60;
        result = [NSString stringWithFormat:@"%ld分钟前", (long)mins];
    }
    
    return result;
}


+ (CGFloat)rowHeightForTrend:(MCCFTrends *)trend {
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat contentW = width - 15 * 2 - 50;
    CGRect rect = [trend.trendContent boundingRectWithSize:CGSizeMake(contentW, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}
                                       context:nil];
    CGFloat rowHeight = 15 * 2 + rect.size.height;
    
    if (trend.photos.count) {
        rowHeight = rowHeight + 15 + 70;
    }
    
    return rowHeight;
}

#pragma mark - getters
- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _timeLabel;
}

- (UIView *)stateView {
    if (!_stateView) {
        _stateView = [[UIView alloc] init];
        _stateView.layer.cornerRadius = 10 / 2;
        _stateView.backgroundColor = [UIColor whiteColor];
    }
    return _stateView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorFromRGBA(216, 216, 216, 0.5);
    }
    return _lineView;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:13];
        _contentLabel.textColor = UIColorFromRGBA(52, 55, 59, 0.8);
        _contentLabel.textAlignment = NSTextAlignmentJustified;
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (UIView *)imgContainer {
    if (!_imgContainer) {
        _imgContainer = [[UIView alloc] init];
        _imgContainer.clipsToBounds = YES;
        
        for (NSInteger i = 0; i <= 3; i ++) {
            UIImageView *imgView = [[UIImageView alloc] init];
            imgView.contentMode = UIViewContentModeScaleAspectFill;
            imgView.clipsToBounds = YES;
            imgView.tag = 1000 + i;
            [_imgContainer addSubview:imgView];
        }
    }
    return _imgContainer;
}

@end

#pragma mark - MCDetailSupporterCell
@interface MCDetailSupporterCell ()
@property (nonatomic, strong) UIImageView *userIconView;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *rightTimeLabel;
@end

@implementation MCDetailSupporterCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self.contentView addSubview:self.userIconView];
    [self.contentView addSubview:self.infoLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.rightTimeLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat borderX = 15;
    CGFloat borderY = 10;
    CGFloat iconW = 30;
    self.userIconView.frame = CGRectMake(borderX, borderY, iconW, iconW);
    
    CGFloat timeW = 50;
    CGFloat timeX = width - borderX - timeW;
    self.rightTimeLabel.frame = CGRectMake(timeX, borderY, timeW, iconW);
    
    CGFloat labelX = CGRectGetMaxX(self.userIconView.frame) + 10;
    CGFloat labelW = width - labelX - borderX - timeW - 10;
    self.infoLabel.frame = CGRectMake(labelX, borderY, labelW, iconW);
    
    CGFloat contentY = CGRectGetMaxY(self.infoLabel.frame) + 5;
    CGFloat contentH = height - contentY - borderY;
    CGFloat contentW = width - labelX - borderX;
    self.contentLabel.frame = CGRectMake(labelX, contentY, contentW, contentH);
    
    [self addBottomBorderWithColor:UIColorFromRGBA(216, 216, 216, 0.8) width:1];
}

- (void)updateContentWithSupportInfo:(MCSupportInfo *)supportInfo {
    MLUser *supporter = supportInfo.supportUser;
    
    [self.userIconView sd_setImageWithURL:[NSURL URLWithString:supporter[@"iconUrl"]] placeholderImage:ImageNamed(@"")];
    
    self.contentLabel.text = supportInfo.content;
    
    self.infoLabel.attributedText = [self attributedStringWithName:supporter.username moneyNum:supportInfo.supportMoney];
    
    self.rightTimeLabel.text = [self timeInfoFromDate:supportInfo.createdAt];
}

- (NSAttributedString *)attributedStringWithName:(NSString *)name moneyNum:(NSInteger)moneyNum {
    NSString *plainTxt = [NSString stringWithFormat:@"%@ 支持了%ld元", name, (long)moneyNum];
    NSRange redRange = [plainTxt rangeOfString:[NSString stringWithFormat:@"%ld", (long)moneyNum]];
    NSMutableAttributedString *mAttributedStr = [[NSMutableAttributedString alloc] initWithString:plainTxt attributes:@{
                NSFontAttributeName: [UIFont systemFontOfSize:15],
                NSForegroundColorAttributeName: UIColorFromRGBA(52, 55, 59, 1)}];
    
    [mAttributedStr setAttributes:@{
            NSForegroundColorAttributeName: UIColorFromRGBA(233, 48, 48, 1)
                                    } range:redRange];
    return mAttributedStr;
}

- (NSString *)timeInfoFromDate:(NSDate *)date {
    NSDate *dateNow = [NSDate new];
    NSTimeInterval interval = [dateNow timeIntervalSinceDate:date];
    
    NSString *timeInfo;
    if (interval > 24 * 3600) {
        NSInteger day = interval / (24 * 3600);
        timeInfo = [NSString stringWithFormat:@"%ld天前", (long)day];
    } else if (interval > 3600) {
        NSInteger hours = interval / 3600;
        timeInfo = [NSString stringWithFormat:@"%ld小时前", (long)hours];
    } else {
        NSInteger mins = interval / 60;
        timeInfo = [NSString stringWithFormat:@"%ld分钟前", (long)mins];
    }
    return timeInfo;
}

#pragma mark - getters
- (UIImageView *)userIconView {
    if (!_userIconView) {
        _userIconView = [[UIImageView alloc] init];
        _userIconView.contentMode = UIViewContentModeScaleAspectFill;
        _userIconView.layer.cornerRadius = 30 / 2;
        _userIconView.clipsToBounds = YES;
    }
    return _userIconView;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
    }
    return _infoLabel;
}

- (UILabel *)rightTimeLabel {
    if (!_rightTimeLabel) {
        _rightTimeLabel = [[UILabel alloc] init];
        _rightTimeLabel.textColor = UIColorFromRGBA(52, 55, 59, 0.3);
        _rightTimeLabel.font = [UIFont systemFontOfSize:11];
        _rightTimeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _rightTimeLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

@end



#pragma mark - MCDetailLimitNumCell
@interface MCDetailLimitNumCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cutButton;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UILabel *numLabel;
@end

@implementation MCDetailLimitNumCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.cutButton];
    [self.contentView addSubview:self.addButton];
    [self.contentView addSubview:self.numLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat borderX = 15;
    CGFloat borderY = 10;
    CGFloat labelH = height - borderY * 2;
    self.titleLabel.frame = CGRectMake(borderX, borderY, 40, labelH);
    
    CGFloat btnW = 21;
    CGFloat btnY = (height - btnW) / 2;
    CGFloat addBtnX = width - borderX - btnW;
    self.addButton.frame = CGRectMake(addBtnX, btnY, btnW, btnW);
    
    CGFloat numLabelW = 30;
    CGFloat numLabelX = width - borderX - btnW - numLabelW;
    self.numLabel.frame = CGRectMake(numLabelX, borderY, numLabelW, labelH);
    
    CGFloat cutBtnX = CGRectGetMinX(self.numLabel.frame) - btnW;
    self.cutButton.frame = CGRectMake(cutBtnX, btnY, btnW, btnW);
}



#pragma mark - actions
- (void)addButtonAction:(UIButton *)sender {
    NSLog(@"add");
    
    NSInteger count = [self.numLabel.text integerValue];
    count ++;
    self.numLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
    
    if ([self.delegate respondsToSelector:@selector(limitCellNumberDidChanged:)]) {
        [self.delegate limitCellNumberDidChanged:count];
    }
}

- (void)cutButtonAction:(UIButton *)sender {
    NSLog(@"cut");
    NSInteger count = [self.numLabel.text integerValue];
    
    if (count <= 1) {
        return;
    }
    
    count --;
    self.numLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
    
    if ([self.delegate respondsToSelector:@selector(limitCellNumberDidChanged:)]) {
        [self.delegate limitCellNumberDidChanged:count];
    }
}

#pragma mark - getters
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.text = @"数量";
    }
    return _titleLabel;
}

- (UILabel *)numLabel {
    if (!_numLabel) {
        _numLabel = [[UILabel alloc] init];
        _numLabel.font = [UIFont systemFontOfSize:17];
        _numLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
        _numLabel.textAlignment = NSTextAlignmentCenter;
        _numLabel.text = @"1";
    }
    return _numLabel;
}

- (UIButton *)cutButton {
    if (!_cutButton) {
        _cutButton = [[UIButton alloc] init];
        [_cutButton setImage:ImageNamed(@"icn_zhichi_subtract") forState:UIControlStateNormal];
        _cutButton.layer.cornerRadius = 21 / 2;
        _cutButton.clipsToBounds = YES;
        [_cutButton addTarget:self action:@selector(cutButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cutButton;
}

- (UIButton *)addButton {
    if (!_addButton) {
        _addButton = [[UIButton alloc] init];
        [_addButton setImage:ImageNamed(@"icn_zhichi_add") forState:UIControlStateNormal];
        _addButton.layer.cornerRadius = 21 / 2;
        _addButton.clipsToBounds = YES;
        [_addButton addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addButton;
}

@end



#pragma mark - MCDetailTextFieldCell
@interface MCDetailTextFieldCell () <UITextFieldDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *textField;
@end

@implementation MCDetailTextFieldCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.textField];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat borderX = 15;
    CGFloat borderY = 10;
    CGFloat contentH = height - borderY * 2;
    CGFloat labelW = 70;
    self.titleLabel.frame = CGRectMake(borderX, borderY, labelW, contentH);
    
    CGFloat fieldX = CGRectGetMaxX(self.titleLabel.frame) + 3;
    CGFloat fieldW = width - fieldX - borderX;
    self.textField.frame = CGRectMake(fieldX, borderY, fieldW, contentH);
}


- (NSInteger)supportMoneyCount {
    return [self.textField.text integerValue];
}

#pragma mark - UITextField delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldCellDidEditWithSupportMoeny:)]) {
        NSInteger supportMoeny = [textField.text integerValue];
        [self.delegate textFieldCellDidEditWithSupportMoeny:supportMoeny];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - getters
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
        _titleLabel.text = @"支付金额:";
    }
    return _titleLabel;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.delegate = self;
        _textField.placeholder = @"请输入金额";
        _textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _textField;
}
@end



#pragma mark - MCDetailTextViewCell
@interface MCDetailTextViewCell () <UITextViewDelegate>
@property (nonatomic, strong) UITextView *textView;
@end

@implementation MCDetailTextViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self.contentView addSubview:self.textView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat startX = 15;
    CGFloat startY = 10;
    self.textView.frame = CGRectMake(startX, startY, width - startX * 2, height - startY * 2);
}

- (NSString *)inputString {
    return self.textView.text;
}


#pragma mark - UITextView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {

}

#pragma mark - getters
- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.font = [UIFont systemFontOfSize:15];
        _textView.textColor = UIColorFromRGBA(52, 55, 59, 1);
        _textView.delegate = self;
        _textView.placeholder = @"对发起人说点什么, 鼓励一下吧!";
        _textView.placeholderLabel.font = [UIFont systemFontOfSize:15];
        _textView.placeholderLabel.textColor = UIColorFromRGBA(52, 55, 59, 0.5);
    }
    return _textView;
}

@end
