//
//  MaxPaymentViewController.h
//  MaxPayDemo
//
//  Created by 周和生 on 16/5/25.
//  Copyright © 2016年 zhouhs. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MaxLeapPay;

@interface MaxPaymentOrder : NSObject
@property (nonatomic, strong) NSDecimalNumber *totalPrice;
@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, strong) NSDictionary *extraInfo;
@end

@interface MaxPaymentViewController : UIViewController
@property (nonatomic, strong) MaxPaymentOrder *order;
@property (nonatomic, strong) NSString *unipayReturnUrl;
@property (nonatomic, copy) void (^completionBlock)(BOOL succeeded, MLPayResult *result);
@end
