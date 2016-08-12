//
//  MCSupportCFViewController.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/13.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCCrowdFunding;

@interface MCSupportCFViewController : UIViewController
@property (nonatomic, strong) NSArray *rewards;
- (id)initWithCrowdFunding:(MCCrowdFunding *)crowdFunding;
@end
