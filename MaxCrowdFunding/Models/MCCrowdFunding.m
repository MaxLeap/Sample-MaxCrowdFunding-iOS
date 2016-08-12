//
//  MCCrowdFunding.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/7.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCCrowdFunding.h"

@implementation MCCrowdFunding

@dynamic publisher;
@dynamic publisherID;
@dynamic isDreamCF;
@dynamic targetNum;
@dynamic completeNum;
@dynamic endDate;
@dynamic projectName;
@dynamic projectDes;
@dynamic photos;
@dynamic freightInfo;
@dynamic deliveryTimeInfo;
@dynamic supportUserCount;
@dynamic attentionCount;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)leapClassName {
    return @"MCCrowdFunding";
}

@end
