//
//  MCPostCFDetailVC.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/6.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CrowdFundingTypeDream,
    CrowdFundingTypeProduct,
} CrowdFundingType;

@interface MCPostCFDetailVC : UIViewController
@property (nonatomic, assign) CrowdFundingType cfType;
@end


@protocol MCPostDetailTextFieldCellDelegate <NSObject>
- (void)textFieldCellDidBeginEdit:(UITextField *)editingView;
- (void)textFieldCellDidEndEdit:(UITextField *)endEditView;
@end
@interface MCPostDetailTextFiledCell : UITableViewCell
@property (nonatomic, weak) id<MCPostDetailTextFieldCellDelegate> delegate;
- (void)updateContentWithDic:(NSDictionary *)dic;
@end


@protocol MCPostDetailDateCellDelegate <NSObject>
- (void)dateCellDidChangedDays:(NSInteger)days;
@end
@interface MCPostDetailDateCell : UITableViewCell
@property (nonatomic, weak) id<MCPostDetailDateCellDelegate> delegate;
- (void)updateContentWithDic:(NSDictionary *)dic;
@end


@interface MCPostDetailLabelCell : UITableViewCell
- (void)updateContentWithDic:(NSDictionary *)dic;
@end
