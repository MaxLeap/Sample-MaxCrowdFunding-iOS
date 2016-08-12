//
//  MCProjectRewardDesVC.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/6.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCCFReward.h"

@protocol MCProjectRewardDesDelegate <NSObject>
- (void)didEndEditRewardDes:(MCCFReward *)reward isAdd:(BOOL)isAdd;
@end

@interface MCProjectRewardDesVC : UIViewController
@property (nonatomic, weak) id<MCProjectRewardDesDelegate> delegate;
@property (nonatomic, strong) MCCFReward *editReward;
@end


@class MCProjectRewardCell;
@protocol MCProjectRewardCellProtocol <NSObject>
- (void)rewardCell:(MCProjectRewardCell *)cell didBeginEdit:(UIView *)editView;
- (void)rewardCell:(MCProjectRewardCell *)cell didEndEdit:(UIView *)endView;
@end

@interface MCProjectRewardCell : UITableViewCell
@property (nonatomic, weak) id<MCProjectRewardCellProtocol> delegate;
- (void)updateContentWithContent:(NSDictionary *)content isTextField:(BOOL)isTextField;

- (NSDictionary *)contentInfo;
@end
