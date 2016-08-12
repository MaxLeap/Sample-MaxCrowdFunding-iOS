//
//  MCSupportInfo.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/7.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCSupportInfo.h"

@implementation MCSupportInfo

@dynamic belongToCFID;
@dynamic supportUser;
@dynamic supportMoney;
@dynamic supportCount;
@dynamic content;
@dynamic supporterAddress;
@dynamic forCFReward;


+ (void)load {
    [self registerSubclass];
}

+ (NSString *)leapClassName {
    return @"MCSupportInfo";
}

@end
