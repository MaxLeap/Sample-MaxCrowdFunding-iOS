//
//  MCAddressViewController.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/8.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCAddress;
@protocol MCAddressVCDelegate <NSObject>
- (void)addressVCDidSelectedAddress:(MCAddress *)address;
@end
@interface MCAddressViewController : UIViewController
@property (nonatomic, weak) id<MCAddressVCDelegate> delegate;
@end

@class MCAddress;
@interface MCAddressCell : UITableViewCell
- (void)updateContentWithAddress:(MCAddress *)address;
@end