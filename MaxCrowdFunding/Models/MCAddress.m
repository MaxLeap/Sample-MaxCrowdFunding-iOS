//
//  MCAddress.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/7.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCAddress.h"

@implementation MCAddress

@dynamic userID;
@dynamic receiverName;
@dynamic phoneNum;
@dynamic regional;
@dynamic detailAdd;
@dynamic isDefault;


+ (void)load {
    [self registerSubclass];
}

+ (NSString *)leapClassName {
    return @"MCAddress";
}

@end
