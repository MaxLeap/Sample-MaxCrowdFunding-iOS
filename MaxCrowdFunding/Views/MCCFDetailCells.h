//
//  MCCFDetailCells.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/13.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>


extern NSString * const kMailCostInfo;
extern NSString * const kDeliverTimeInfo;

@interface MCDetailTimeCell : UITableViewCell
- (void)updateContentWithDic:(NSDictionary *)dic;
@end


@class MCCFReward;
@interface MCDetailRewardCell : UITableViewCell
- (void)updateContentWithReward:(MCCFReward *)reward photo:(NSString *)photo;
@end

// product detail cell
@class MCCrowdFunding;
@interface MCProductDetailCell : UITableViewCell
- (void)updateContentWithCrowdFunding:(MCCrowdFunding *)crowdFunding;

+ (CGFloat)rowHeightForCrowdFunding:(MCCrowdFunding *)crowdFunding;
@end

@class MCCFTrends;
@interface MCProductTrendCell : UITableViewCell
- (void)updateContentWithTrend:(MCCFTrends *)trend isLatest:(BOOL)latest isFirst:(BOOL)isFirst;

+ (CGFloat)rowHeightForTrend:(MCCFTrends *)trend;
@end

@class MCSupportInfo;
@interface MCDetailSupporterCell : UITableViewCell
- (void)updateContentWithSupportInfo:(MCSupportInfo *)supportInfo;
@end

// MCSupportCFVC
@protocol MCLimitCellDelegate <NSObject>
- (void)limitCellNumberDidChanged:(NSInteger)num;
@end
@interface MCDetailLimitNumCell : UITableViewCell
@property (nonatomic, weak) id<MCLimitCellDelegate> delegate;
@property (nonatomic, assign) NSInteger limitCount;
@end


@protocol MCDetailFieldCellDelegate <NSObject>
- (void)textFieldCellDidEditWithSupportMoeny:(NSInteger)supportMoeny;
@end
@interface MCDetailTextFieldCell : UITableViewCell
@property (nonatomic, weak) id<MCDetailFieldCellDelegate> delegate;
- (NSInteger)supportMoneyCount;
@end



@interface MCDetailTextViewCell : UITableViewCell
- (NSString *)inputString;
@end

