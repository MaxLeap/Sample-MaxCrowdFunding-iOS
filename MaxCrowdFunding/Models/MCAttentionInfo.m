//
//  MCAttentionInfo.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/7.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCAttentionInfo.h"

@implementation MCAttentionInfo

@dynamic userID;
@dynamic cfID;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)leapClassName {
    return @"MCAttentionInfo";
}

@end
