//
//  MCProductDesViewController.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/6.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kProductName;
extern NSString * const kProductDes;
extern NSString * const kProductImgs;

@protocol MCProductDesProtocol <NSObject>
- (void)didDescriptProductWithDesInfo:(NSDictionary *)desInfo;
@end

@interface MCProductDesViewController : UIViewController
@property (nonatomic, weak) id<MCProductDesProtocol> delegate;
@property (nonatomic, strong) NSDictionary *editProductDesInfo;
@end

@class MCProductCell;
@protocol MCProductCellProtocol <NSObject>
- (void)productCell:(MCProductCell *)cell didStartEdit:(UITextView *)textView;
- (void)productCell:(MCProductCell *)cell didEndEdit:(UITextView *)textView;
@end
@interface MCProductCell : UITableViewCell
@property (nonatomic, weak) id<MCProductCellProtocol> delegate;
- (void)updateContentWithDic:(NSDictionary *)dic isTitleCell:(BOOL)isTitle;

- (NSDictionary *)contentInfo;
@end

typedef void(^MCDeleteImgBlock)(NSIndexPath *indexPath);
@interface MCCollectionCell : UICollectionViewCell
@property (nonatomic, copy) MCDeleteImgBlock xButtonBlock;

- (void)updateContentWithImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath;
@end
