//
//  MCPersonAuthVC.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/8.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCPersonAuthVC : UIViewController

@end

@interface MCPersonTextFieldCell : UITableViewCell
- (void)updateContentWithDic:(NSDictionary *)dic;

- (NSString *)inputText;
@end
