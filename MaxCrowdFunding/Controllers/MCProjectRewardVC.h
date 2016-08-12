//
//  MCProjectRewardVC.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/6.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCCFReward;

@protocol MCProjectAddRewardDelegate <NSObject>
- (void)addRewardVCDidEndAddReward:(NSArray *)rewards;
@end

@interface MCProjectRewardVC : UIViewController
@property (nonatomic, weak) id<MCProjectAddRewardDelegate> delegate;
@property (nonatomic, strong) NSArray *editRewards;
@end

@interface MCProjectRewardDesCell : UITableViewCell
- (void)updateContentWithReward:(MCCFReward *)reward;
@end

@interface MCProjectAddRewardCell : UITableViewCell
- (void)updateTitle:(NSString *)title;
@end
