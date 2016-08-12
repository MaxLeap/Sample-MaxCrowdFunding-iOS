//
//  MCHomeCFCell.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/11.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCCrowdFunding;
@interface MCHomeCFCell : UITableViewCell

- (void)updateContentWithCrowdFunding:(MCCrowdFunding *)crowdFunding showProgress:(BOOL)showProgress;

@end
