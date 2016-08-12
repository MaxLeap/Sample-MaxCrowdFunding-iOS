//
//  MCCFDetailViewController.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/12.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCCrowdFunding;
@interface MCCFDetailViewController : UIViewController
@property (nonatomic, strong) MCCrowdFunding *crowdFunding;
@property (nonatomic, assign) BOOL isMine;
@end


@interface MCAttentionButton : UIButton

@end
