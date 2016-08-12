//
//  MCCFTrends.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/7.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCCFTrends.h"

@implementation MCCFTrends

@dynamic belongToCFID;
@dynamic trendContent;
@dynamic photos;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)leapClassName {
    return @"MCCFTrends";
}
@end
