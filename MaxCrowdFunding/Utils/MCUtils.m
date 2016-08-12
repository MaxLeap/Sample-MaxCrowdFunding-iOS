//
//  MCUtils.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/4.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCUtils.h"

@implementation MCUtils

+ (BOOL)hasLogin {
    MLUser *currentUser = [MLUser currentUser];
    if (currentUser && ![MLAnonymousUtils isLinkedWithUser:currentUser]) {
        return YES;
    }
    return NO;
}

@end
