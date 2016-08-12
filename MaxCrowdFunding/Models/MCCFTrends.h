//
//  MCCFTrends.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/7.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <MaxLeap/MaxLeap.h>

@interface MCCFTrends : MLObject <MLSubclassing>

+ (NSString *)leapClassName;

@property (nonatomic, copy) NSString *belongToCFID;
@property (nonatomic, copy) NSString *trendContent;
@property (nonatomic, strong) NSArray *photos;

@end
