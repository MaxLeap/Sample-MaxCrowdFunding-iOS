//
//  MCPersonAuth.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/7.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <MaxLeap/MaxLeap.h>

@interface MCPersonAuth : MLObject <MLSubclassing>

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *IDCardNum;
@property (nonatomic, copy) NSString *phoneNum;
@property (nonatomic, copy) NSString *IDCardPicURL;

+ (NSString *)leapClassName;

@end
