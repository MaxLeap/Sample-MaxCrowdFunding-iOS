//
//  MCCFDetailHeaderView.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/12.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCCrowdFunding;
@interface MCCFDetailHeaderView : UIView
- (void)updateDetailInfoWithCrowdFunding:(MCCrowdFunding *)crowdFunding;
@end

@interface MCDetailNumView : UILabel
- (void)updateContentTopTxt:(NSString *)topTxt bottomTxt:(NSString *)bottomTxt;
@end