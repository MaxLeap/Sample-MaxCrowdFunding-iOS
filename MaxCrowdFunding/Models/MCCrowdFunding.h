//
//  MCCrowdFunding.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/7.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <MaxLeap/MaxLeap.h>

@interface MCCrowdFunding : MLObject <MLSubclassing>

+ (NSString *)leapClassName;

@property (nonatomic, strong) MLUser *publisher;
@property (nonatomic, copy) NSString *publisherID;
@property (nonatomic, assign) BOOL isDreamCF;
@property (nonatomic, assign) NSInteger targetNum;
@property (nonatomic, assign) NSInteger completeNum;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, copy) NSString *projectName;
@property (nonatomic, copy) NSString *projectDes;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, copy) NSString *freightInfo;
@property (nonatomic, copy) NSString *deliveryTimeInfo;
@property (nonatomic, assign) NSInteger supportUserCount;
@property (nonatomic, assign) NSInteger attentionCount;

@end
