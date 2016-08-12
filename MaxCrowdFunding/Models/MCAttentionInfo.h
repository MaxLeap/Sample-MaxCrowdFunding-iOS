//
//  MCAttentionInfo.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/7.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <MaxLeap/MaxLeap.h>

@interface MCAttentionInfo : MLObject <MLSubclassing>

+ (NSString *)leapClassName;

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *cfID;

@end
