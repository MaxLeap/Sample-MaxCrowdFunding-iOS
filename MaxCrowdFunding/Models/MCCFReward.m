//
//  MCCFReward.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/7.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCCFReward.h"

@implementation MCCFReward

@dynamic belongToCFID;
@dynamic supportMoney;
@dynamic rewardDes;
@dynamic limitNum;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)leapClassName {
    return @"MCCFReward";
}

@end
