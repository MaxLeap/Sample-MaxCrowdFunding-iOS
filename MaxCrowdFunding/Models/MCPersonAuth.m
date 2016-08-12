//
//  MCPersonAuth.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/7.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCPersonAuth.h"

@implementation MCPersonAuth

@dynamic userID;
@dynamic IDCardNum;
@dynamic phoneNum;
@dynamic IDCardPicURL;


+ (void)load {
    [self registerSubclass];
}

+ (NSString *)leapClassName {
    return @"MCPersonAuth";
}


@end
