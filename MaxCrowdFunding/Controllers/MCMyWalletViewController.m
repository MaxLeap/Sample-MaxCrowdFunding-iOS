//
//  MCMyWalletViewController.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/8.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCMyWalletViewController.h"
#import "MCWithdrawalsViewController.h"

@interface MCMyWalletViewController ()
@property (nonatomic, strong) UIButton *withdrawalBtn;
@end

@implementation MCMyWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self buildUI];
}

- (void)buildUI {
    self.navigationItem.title = @"我的钱包";
    self.view.backgroundColor = UIColorFromRGBA(240, 240, 243, 1);
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    
    CGRect containFrame = CGRectMake(0, 64, width, 180);
    [self.view addSubview:[self contentContainerWithFrame:containFrame]];
    
    CGRect btnFrame = CGRectMake(20, CGRectGetMaxY(containFrame) + 30, (width - 20 * 2), 45);
    [self.view addSubview:[self withdrawalBtnWithFrame:btnFrame]];
}

- (UIView *)contentContainerWithFrame:(CGRect)frame {
    UIView *container = [[UIView alloc] initWithFrame:frame];
    container.backgroundColor = [UIColor whiteColor];
    
    UIImageView *balanceImgView = [[UIImageView alloc] initWithImage:ImageNamed(@"bg_user profiles_my wallet")];
    [container addSubview:balanceImgView];
    balanceImgView.center = CGPointMake(frame.size.width / 2, frame.size.height / 2 - 30);
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, CGRectGetMaxY(balanceImgView.frame), frame.size.width, 22);
    label.textColor = UIColorFromRGBA(52, 55, 59, 1);
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15];
    label.text = @"我的零钱";
    [container addSubview:label];
    
    UILabel *balanceLabel = [[UILabel alloc] init];
    balanceLabel.frame = CGRectMake(0, CGRectGetMaxY(label.frame), frame.size.width, 50);
    balanceLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
    balanceLabel.textAlignment = NSTextAlignmentCenter;
    balanceLabel.font = [UIFont systemFontOfSize:35];
    [container addSubview:balanceLabel];
    
    MLUser *currentUser = [MLUser currentUser];
    NSInteger balance = [currentUser[@"balance"] integerValue];
    NSString *balanceInfo = [NSString stringWithFormat:@"￥%ld", (long)balance];
    balanceLabel.text = balanceInfo;
    
    return container;
}

- (UIButton *)withdrawalBtnWithFrame:(CGRect)frame {
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    [btn setTitle:@"提现" forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(59, 163, 255, 1)] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(withdrawalButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 5;
    btn.clipsToBounds = YES;
    return btn;
}

#pragma mark - actions
- (void)withdrawalButtonAction:(UIButton *)sender {
    MLUser *currentUser = [MLUser currentUser];
    NSInteger balance = [currentUser[@"balance"] integerValue];
    if (balance <= 0) {
        [SVProgressHUD showErrorWithStatus:@"没有零钱可以提现."];
        return;
    }
    
    MCWithdrawalsViewController *withdrawalsVC = [[MCWithdrawalsViewController alloc] init];
    withdrawalsVC.maxNum = balance;
    [self.navigationController pushViewController:withdrawalsVC animated:YES];
}


@end
