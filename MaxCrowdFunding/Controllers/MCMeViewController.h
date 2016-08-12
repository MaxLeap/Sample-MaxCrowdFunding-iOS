//
//  MCMeViewController.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/4.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCMeViewController : UIViewController

@end

@interface MCMeNoLoginCell : UITableViewCell
@property (nonatomic, copy) dispatch_block_t loginBtnBlock;
@end

@interface MCMeUserNameCell : UITableViewCell
- (void)updateContentWithUser:(MLUser *)user;
@end

@interface MCMeDetailCell : UITableViewCell
@property (nonatomic, copy) dispatch_block_t crowdFundingBlock;
@property (nonatomic, copy) dispatch_block_t mySupportBlock;
@property (nonatomic, copy) dispatch_block_t myAttentionBlock;
- (void)updateContentWithUser:(MLUser *)user;
@end

@interface MCDetailButton : UIButton
- (void)configWithNum:(NSInteger)num desInfo:(NSString *)des;
@end
