//
//  MCMyCrowdFundingsVC.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/11.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    MyCFShowTypeSuccessed,
    MyCFShowTypeFailed,
    MyCFShowTypeContinue,
} MyCFShowType;

typedef enum : NSUInteger {
    MCCFRelationShipMine,
    MCCFRelationShipMySupport,
    MCCFRelationShipMyAttention
} MCCFRelationShip;

@interface MCMyCrowdFundingsVC : UIViewController
@property (nonatomic, assign) MCCFRelationShip cfRelationShip;
@end

@class MCCrowdFunding;
@interface MCMyCrowdFundingCell : UITableViewCell
- (void)updateContentWithCrowdFunding:(MCCrowdFunding *)crowdF state:(MyCFShowType)showType;
@end
