//
//  MCProgressView.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/11.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCProgressView.h"

static CGFloat kTrackHeight = 3.0;
static CGFloat kProgressLabelW = 30.0f;
static CGFloat kProgressLabelH = 15.0f;

@interface MCProgressView ()
@property (nonatomic, strong) UIView *trackView;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, assign) CGFloat progress;
@end

@implementation MCProgressView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self addSubview:self.trackView];
    [self addSubview:self.progressView];
    [self addSubview:self.progressLabel];
    
    [self setProgress:0 animated:NO];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat trackW = width;
    CGFloat trackY = (height - kTrackHeight) / 2;
    self.trackView.frame = CGRectMake(0, trackY, trackW, kTrackHeight);
    
    CGFloat progressW = width * _progress;
    self.progressView.frame = CGRectMake(0, trackY, progressW, kTrackHeight);
    
    CGFloat labelY = (height - kProgressLabelH) / 2;
    CGFloat labelX = progressW - kProgressLabelW / 2;
    self.progressLabel.frame = CGRectMake(labelX, labelY, kProgressLabelW, kProgressLabelH);
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    progress = progress < 0 ? 0 : progress;
    progress = progress > 1 ? 1 : progress;
    
    _progress = progress;
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat progressW = width * progress;
    CGFloat labelX = progressW - kProgressLabelW / 2;
    CGFloat labelY = (height - kProgressLabelH) / 2;
    CGFloat trackY = (height - kTrackHeight) / 2;
    
    if (animated) {
        [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.58 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.progressView.frame = CGRectMake(0, trackY, progressW, kTrackHeight);
            self.progressLabel.frame = CGRectMake(labelX, labelY, kProgressLabelW, kProgressLabelH);
            self.progressLabel.text = [NSString stringWithFormat:@"%.0f%@", progress * 100, @"%"];
        } completion:^(BOOL finished) {
            [self setNeedsLayout];
        }];
    } else {
        self.progressLabel.text = [NSString stringWithFormat:@"%.0f%@", progress * 100, @"%"];
        self.progressView.frame = CGRectMake(0, trackY, progressW, kTrackHeight);
        self.progressLabel.frame = CGRectMake(labelX, labelY, kProgressLabelW, kProgressLabelH);
        
        [self setNeedsLayout];
    }
}


#pragma mark - getters
- (UIView *)trackView {
    if (!_trackView) {
        _trackView = [[UIView alloc] init];
        _trackView.backgroundColor = UIColorFromRGBA(216, 216, 216, 1);
        _trackView.layer.cornerRadius = kTrackHeight / 2;
        _trackView.clipsToBounds = YES;
    }
    return _trackView;
}

- (UIView *)progressView {
    if (!_progressView) {
        _progressView = [[UIView alloc] init];
        _progressView.layer.cornerRadius = kTrackHeight / 2;
        _progressView.clipsToBounds = YES;
        _progressView.backgroundColor = UIColorFromRGBA(0, 197, 167, 1);
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 0);
        NSArray *colors = @[(id)UIColorFromRGBA(0, 197, 167, 1).CGColor, (id)UIColorFromRGBA(59, 163, 255, 1).CGColor];
        gradientLayer.colors = colors;
        gradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), kProgressLabelH);
        [_progressView.layer addSublayer:gradientLayer];
    }
    return _progressView;
}

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.backgroundColor = [UIColor whiteColor];
        _progressLabel.textColor = UIColorFromRGBA(59, 163, 255, 1);
        _progressLabel.font = [UIFont systemFontOfSize:11];
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.adjustsFontSizeToFitWidth = YES;
        
        _progressLabel.clipsToBounds = YES;
        _progressLabel.layer.cornerRadius = kProgressLabelH / 2;
        _progressLabel.layer.borderColor = UIColorFromRGBA(59, 163, 255, 1).CGColor;
        _progressLabel.layer.borderWidth = 1;
    }
    return _progressLabel;
}
@end
