//
//  MCSupportInfo.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/7.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <MaxLeap/MaxLeap.h>

@class MCAddress;
@class MCCFReward;
@interface MCSupportInfo : MLObject <MLSubclassing>

+ (NSString *)leapClassName;

@property (nonatomic, copy) NSString *belongToCFID;
@property (nonatomic, strong) MLUser *supportUser;
@property (nonatomic, assign) NSInteger supportMoney;
@property (nonatomic, assign) NSInteger supportCount;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) MCAddress *supporterAddress;
@property (nonatomic, strong) MCCFReward *forCFReward;

@end
