//
//  MCAddress.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/7.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <MaxLeap/MaxLeap.h>

@interface MCAddress : MLObject <MLSubclassing>

+ (NSString *)leapClassName;

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *receiverName;
@property (nonatomic, copy) NSString *phoneNum;
@property (nonatomic, copy) NSString *regional;
@property (nonatomic, copy) NSString *detailAdd;
@property (nonatomic, assign) BOOL isDefault;

@end
