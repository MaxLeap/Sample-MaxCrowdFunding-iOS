//
//  MCHomeHeaderView.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/11.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCHomeHeaderView.h"
#import "UIView+CustomBorder.h"
#import "MCCrowdFunding.h"

@interface MCHomeHeaderView () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIView *btnContainer;
@property (nonatomic, strong) MCHomeButton *dreamBtn;
@property (nonatomic, strong) MCHomeButton *productBtn;
@end

@implementation MCHomeHeaderView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self addSubview:self.scrollView];
    [self addSubview:self.pageControl];
    [self addSubview:self.btnContainer];
    [self.btnContainer addSubview:self.dreamBtn];
    [self.btnContainer addSubview:self.productBtn];
    
//    self.scrollView.backgroundColor = [UIColor greenColor];
//    self.pageControl.backgroundColor = [UIColor orangeColor];
//    self.btnContainer.backgroundColor = [UIColor redColor];
//    self.dreamBtn.backgroundColor = [UIColor blueColor];
//    self.productBtn.backgroundColor = [UIColor magentaColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat scrollH = height * 0.8;
    self.scrollView.frame = CGRectMake(0, 0, width, scrollH);
    
    CGFloat pageControlH = 30;
    self.pageControl.frame = CGRectMake(0, scrollH - pageControlH, width, pageControlH);
    
    CGFloat contanierH = height - scrollH;
    self.btnContainer.frame = CGRectMake(0, scrollH, width, contanierH);
    CGFloat btnW = width / 2;
    self.dreamBtn.frame = CGRectMake(0, 0, btnW, contanierH);
    self.productBtn.frame = CGRectMake(btnW, 0, btnW, contanierH);
    
    [self.dreamBtn addRightBorderWithColor:UIColorFromRGBA(216, 216, 216, 0.5) width:1 excludePoint:15 edgeType:ExcludeAllPoint];
}

- (void)updateContentWithCrowdFundings:(NSArray *)crowdFudings {
    
    NSInteger cfCount = crowdFudings.count;
    self.pageControl.numberOfPages = cfCount;
    
    CGFloat width = CGRectGetWidth(self.scrollView.frame);
    CGFloat height = CGRectGetHeight(self.scrollView.frame);
    
    self.scrollView.contentSize = CGSizeMake(width * cfCount, height);
    
    NSInteger i = 0;
    for (MCCrowdFunding *cf in crowdFudings) {
        CGFloat imgX = width * i;
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(imgX, 0, width, height)];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        
        NSArray *photos = cf.photos;
        if (photos.count) {
            NSString *firstPhoto = photos.firstObject;
            NSURL *imgURL = [NSURL URLWithString:firstPhoto];
            [imgView sd_setImageWithURL:imgURL placeholderImage:ImageNamed(@"")];
        }
        
        [self.scrollView addSubview:imgView];
        
        i ++;
        
        imgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        [imgView addGestureRecognizer:tapGesture];
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *)gesture {
    NSInteger page = self.pageControl.currentPage;
//    NSLog(@"tapped page = %d", page);
    if (self.bannerBlock) {
        self.bannerBlock(page);
    }
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat scrollW = CGRectGetWidth(self.scrollView.frame);
    NSInteger page = offsetX / scrollW;
    self.pageControl.currentPage = page;
}

#pragma mark - actions
- (void)dreamButtonAction:(UIButton *)sender {
    if (self.showDreamCFBlock) {
        self.showDreamCFBlock();
    }
}

- (void)productButtonAction:(UIButton *)sender {
    if (self.showProductCFBlock) {
        self.showProductCFBlock();
    }
}


#pragma mark - getters
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.hidesForSinglePage = YES;
//        _pageControl.pageIndicatorTintColor = [UIColor colorWithPatternImage:[ImageNamed(@"btn_banner_scroll bar_normal") stretchableImageWithLeftCapWidth:3 topCapHeight:3]];
//        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithPatternImage:[ImageNamed(@"btn_banner_scroll bar_selected") stretchableImageWithLeftCapWidth:3 topCapHeight:3]];
    }
    return _pageControl;
}

- (UIView *)btnContainer {
    if (!_btnContainer) {
        _btnContainer = [[UIView alloc] init];
        _btnContainer.backgroundColor = [UIColor whiteColor];
    }
    return _btnContainer;
}

- (MCHomeButton *)dreamBtn {
    if (!_dreamBtn) {
        _dreamBtn = [[MCHomeButton alloc] init];
        [_dreamBtn addTarget:self action:@selector(dreamButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_dreamBtn setImage:ImageNamed(@"icn_homepage_aixin") forState:UIControlStateNormal];
        [_dreamBtn setTitle:@"梦想" forState:UIControlStateNormal];
        [_dreamBtn setTitleColor:UIColorFromRGBA(52, 55, 59, 1) forState:UIControlStateNormal];
    }
    return _dreamBtn;
}

- (MCHomeButton *)productBtn {
    if (!_productBtn) {
        _productBtn = [[MCHomeButton alloc] init];
        [_productBtn addTarget:self action:@selector(productButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_productBtn setImage:ImageNamed(@"icn_homepage_chanpin") forState:UIControlStateNormal];
        [_productBtn setTitle:@"产品" forState:UIControlStateNormal];
        [_productBtn setTitleColor:UIColorFromRGBA(52, 55, 59, 1) forState:UIControlStateNormal];
    }
    return _productBtn;
}

@end


@implementation MCHomeButton

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat imgW = 23;
    CGFloat imgY = 10;
    CGFloat imgX = (width - imgW) / 2;
    self.imageView.frame = CGRectMake(imgX, imgY, imgW, imgW);
    
    CGFloat titleY = CGRectGetMaxY(self.imageView.frame) + 3;
    CGFloat titleH = height - titleY - 3;
    self.titleLabel.frame = CGRectMake(0, titleY, width, titleH);
    
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:12];
}

@end
