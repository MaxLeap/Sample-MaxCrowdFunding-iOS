//
//  MCCFReward.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/7.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <MaxLeap/MaxLeap.h>

@interface MCCFReward : MLObject <MLSubclassing>

+ (NSString *)leapClassName;

@property (nonatomic, copy) NSString *belongToCFID;
@property (nonatomic, assign) NSInteger supportMoney;
@property (nonatomic, copy) NSString *rewardDes;
@property (nonatomic, assign) NSInteger limitNum;

// local att
@property (nonatomic, copy) NSString *rewardUUID;

@end
