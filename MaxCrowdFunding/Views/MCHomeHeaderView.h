//
//  MCHomeHeaderView.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/11.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MCTappedBannerBlock)(NSInteger index);

@interface MCHomeHeaderView : UIView

@property (nonatomic, copy) dispatch_block_t showDreamCFBlock;
@property (nonatomic, copy) dispatch_block_t showProductCFBlock;
@property (nonatomic, copy) MCTappedBannerBlock bannerBlock;

- (void)updateContentWithCrowdFundings:(NSArray *)crowdFudings;

@end

@interface MCHomeButton : UIButton

@end
