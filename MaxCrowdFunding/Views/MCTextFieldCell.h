//
//  MCTextFieldCell.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/8.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kTitle;
extern NSString * const kValue;
extern NSString * const kPlaceHolder;

@class MCTextFieldCell;
@protocol MCTextFieldCellDelegate <NSObject>
- (void)textFieldCell:(MCTextFieldCell *)cell didStartEdit:(UITextField *)editView;
- (void)textFieldCell:(MCTextFieldCell *)cell didEndEdit:(UITextField *)endEditView;
@end

@interface MCTextFieldCell : UITableViewCell
@property (nonatomic, weak) id<MCTextFieldCellDelegate> delegate;
- (void)updateContentWithDic:(NSDictionary *)dic;
- (NSDictionary *)contentDic;
@end
