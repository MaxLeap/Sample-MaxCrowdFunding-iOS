//
//  MCSupportCFViewController.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/13.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCSupportCFViewController.h"
#import "MCCFDetailCells.h"
#import "MCCrowdFunding.h"
#import "MCCFReward.h"
#import "MCAddress.h"
#import "MCSupportInfo.h"
#import "MCAddressViewController.h"

@import MaxLeapPay;
@import MaxPayUI;

static NSString * const kRewardCell = @"rewardCell";
static NSString * const kLimitNumCell = @"limitNumCell";
static NSString * const kTextViewCell = @"textViewCell";
static NSString * const kTextFieldCell = @"textFiedlCell";

static CGFloat const kBottomContainerH = 50.0;

@interface MCSupportCFViewController () <UITableViewDelegate,
 UITableViewDataSource,
 MCLimitCellDelegate,
 MCDetailFieldCellDelegate,
 MCAddressVCDelegate
>
@property (nonatomic, strong) MCCrowdFunding *crowdFunding;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *bottomContainer;
@property (nonatomic, strong) UIButton *payButton;
@property (nonatomic, strong) UILabel *totalNumLabel;
// meta data
@property (nonatomic, assign) NSInteger supportCount;
@property (nonatomic, strong) MCAddress *selectedAddress;
@property (nonatomic, strong) MCCFReward *selectedReward;
@property (nonatomic, strong) NSIndexPath *lastSelectedRewardIndex;
@end

@implementation MCSupportCFViewController

- (id)initWithCrowdFunding:(MCCrowdFunding *)crowdFunding {
    if (self = [super init]) {
        _crowdFunding = crowdFunding;
        _supportCount = 1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self buildUI];
    
    [self addObservers];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)buildUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"支持";
 
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.bottomContainer];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.crowdFunding.isDreamCF ? 2 : 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.crowdFunding.isDreamCF ? 0.01 : 45;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat headerH = 0.01;
    if (section == 0) {
        if (!self.crowdFunding.isDreamCF) {
            UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 45)];
            header.backgroundColor = [UIColor whiteColor];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(self.view.bounds) - 15, 45)];
            titleLabel.font = [UIFont systemFontOfSize:15];
            titleLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
            titleLabel.text = @"产品回报";
            [header addSubview:titleLabel];
            
            return header;
        }
    } else {
        headerH = 10;
    }
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), headerH)];
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.crowdFunding.isDreamCF && section == 0) {
        return self.rewards.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.crowdFunding.isDreamCF ? 45 : 75;
    } else if (indexPath.section == 1) {
        return self.crowdFunding.isDreamCF ? 120 : 45;
    } else if (indexPath.section == 2) {
        return 45.0;
    } else {
        return 120.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.crowdFunding.isDreamCF && indexPath.section == 0) {
        // reward cell
        MCDetailRewardCell *rewardCell = [tableView dequeueReusableCellWithIdentifier:kRewardCell forIndexPath:indexPath];
        rewardCell.tintColor = UIColorFromRGBA(25, 196, 70, 1);
        MCCFReward *reward = self.rewards[indexPath.row];
        NSString *photo = self.crowdFunding.photos.count ? self.crowdFunding.photos.firstObject : @"";
        [rewardCell updateContentWithReward:reward photo:photo];
        return rewardCell;
    } else if (!self.crowdFunding.isDreamCF && indexPath.section == 1) {
        MCDetailLimitNumCell *limitNumCell = [tableView dequeueReusableCellWithIdentifier:kLimitNumCell forIndexPath:indexPath];
        limitNumCell.delegate = self;
//        limitNumCell.limitCount =
        return limitNumCell;
    } else if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        NSString *txt = @"收货地址";
        if (self.selectedAddress) {
            txt = [NSString stringWithFormat:@"%@ (%@%@)", txt, self.selectedAddress.regional, self.selectedAddress.detailAdd];
        }
        cell.textLabel.text = txt;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    } else if (indexPath.section == 3 || (indexPath.section == 1 && self.crowdFunding.isDreamCF)) {
        // text view
        MCDetailTextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTextViewCell forIndexPath:indexPath];
        return cell;
    } else if (self.crowdFunding.isDreamCF && indexPath.section == 0) {
        // text field
        MCDetailTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kTextFieldCell forIndexPath:indexPath];
        cell.delegate = self;
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.crowdFunding.isDreamCF) {
        if (indexPath.section == 2) {
            [self toSelectAddressViewController];
        } else if (indexPath.section == 0) {
            [self didSelectedRewardCellAtIndexPath:indexPath];
        }
    }
}

#pragma mark - custom delegate
- (void)limitCellNumberDidChanged:(NSInteger)num {
    self.supportCount = num;
    NSInteger money = num * self.selectedReward.supportMoney;
    [self updateTotalMoeny:money];
}

- (void)textFieldCellDidEditWithSupportMoeny:(NSInteger)supportMoeny {
    [self updateTotalMoeny:supportMoeny];
}

- (void)addressVCDidSelectedAddress:(MCAddress *)address {
    self.selectedAddress = address;
    
    NSIndexPath *addressIndex = [NSIndexPath indexPathForRow:0 inSection:2];
    [self.tableView reloadRowsAtIndexPaths:@[addressIndex] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)updateTotalMoeny:(NSInteger)total {
    NSString *totalInfo = [NSString stringWithFormat:@"合计: ￥ %ld", (long)total];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:totalInfo attributes:@{
            NSFontAttributeName: [UIFont systemFontOfSize:15],
            NSForegroundColorAttributeName: UIColorFromRGBA(52, 55, 59, 1)}];
    NSRange redRange = [totalInfo rangeOfString:[NSString stringWithFormat:@"￥ %ld", (long)total]];
    [attributedStr setAttributes:@{
           NSFontAttributeName: [UIFont systemFontOfSize:15],
           NSForegroundColorAttributeName: UIColorFromRGBA(233, 48, 48, 1)
                                   } range:redRange];
    
    self.totalNumLabel.attributedText = attributedStr;
}

#pragma mark - actions
- (void)didSelectedRewardCellAtIndexPath:(NSIndexPath *)indexPath {
    MCDetailRewardCell *lastCell = [self.tableView cellForRowAtIndexPath:self.lastSelectedRewardIndex];
    lastCell.accessoryType = UITableViewCellAccessoryNone;
    
    self.selectedReward = self.rewards[indexPath.row];
    MCDetailRewardCell *rewardCell = [self.tableView cellForRowAtIndexPath:indexPath];
    rewardCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.lastSelectedRewardIndex = indexPath;
    
    // update total moeny
    NSInteger money = self.supportCount * self.selectedReward.supportMoney;
    [self updateTotalMoeny:money];
}


- (void)toSelectAddressViewController {
    MCAddressViewController *addressVC = [[MCAddressViewController alloc] init];
    addressVC.delegate = self;
    [self.navigationController pushViewController:addressVC animated:YES];
}

- (void)payButtonAction:(UIButton *)sender {
    
    if (self.crowdFunding.isDreamCF) {
        [self supportDreamCrowdFunding];
    } else {
        [self supportProductCrowdFunding];
    }
}

- (void)supportDreamCrowdFunding {
    NSIndexPath *fieldCellIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    MCDetailTextFieldCell *fieldCell = [self.tableView cellForRowAtIndexPath:fieldCellIndex];
    NSInteger supportMoeny = [fieldCell supportMoneyCount];
    
    NSIndexPath *txtViewIndex = [NSIndexPath indexPathForRow:0 inSection:1];
    MCDetailTextViewCell *txtViewCell = [self.tableView cellForRowAtIndexPath:txtViewIndex];
    NSString *inputStr = [txtViewCell inputString];
    
    if (supportMoeny <= 0) {
        [SVProgressHUD showErrorWithStatus:@"支持金额不能小于0"];
        return;
    }
    
    MaxPaymentOrder *order = [[MaxPaymentOrder alloc] init];
    order.totalPrice = [NSDecimalNumber decimalNumberWithDecimal:[@(supportMoeny * 100) decimalValue]];
    order.orderId = [[[NSUUID UUID]UUIDString].lowercaseString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    MaxPaymentViewController *payVC = [[MaxPaymentViewController alloc ] init];
    payVC.order = order;
    payVC.completionBlock = ^(BOOL succeeded, MLPayResult *result) {
        if (!succeeded) {
            [SVProgressHUD showErrorWithStatus:@"完成真实支付需要在MaxLeap后台的“应用设置”-“支付设置”中，设置支付宝、微信支付和银联支付的商户信息。"];
        }
        
        MCSupportInfo *supportInfo = [[MCSupportInfo alloc] init];
        supportInfo.belongToCFID = self.crowdFunding.objectId;
        supportInfo.supportMoney = supportMoeny;
        supportInfo.supportUser = [MLUser currentUser];
        supportInfo.supportCount = 1;
        supportInfo.content = inputStr;
        [supportInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [self.crowdFunding incrementKey:@"supportUserCount"];
                [self.crowdFunding incrementKey:@"completeNum" byAmount:@(supportMoeny)];
                [self.crowdFunding saveInBackgroundWithBlock:nil];
                
                [[MLUser currentUser] incrementKey:@"supportTimes"];
                [[MLUser currentUser] saveInBackgroundWithBlock:nil];
                
                // 发起人得money ++， but can not save user whit out login
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kDidFinishSupportCF object:nil];
                [self.navigationController popViewControllerAnimated:NO];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [SVProgressHUD showErrorWithStatus:@"支付失败"];
            }
        }];
    };
    
    [self.navigationController pushViewController:payVC animated:YES];
}

- (void)supportProductCrowdFunding {
    MCCFReward *reward = self.selectedReward;
    // 支持金额
    NSInteger supportMoney = reward.supportMoney * self.supportCount;
    
    if (supportMoney <= 0) {
        [SVProgressHUD showErrorWithStatus:@"支持金额不能小于0"];
        return;
    }
    
    // 收货地址
    MCAddress *address = self.selectedAddress;
    
    NSIndexPath *txtViewIndx = [NSIndexPath indexPathForRow:0 inSection:3];
    MCDetailTextViewCell *txtViewCell = [self.tableView cellForRowAtIndexPath:txtViewIndx];
    NSString *content = [txtViewCell inputString];
    
    
    MaxPaymentOrder *order = [[MaxPaymentOrder alloc] init];
    order.totalPrice = [NSDecimalNumber decimalNumberWithDecimal:[@(supportMoney * 100) decimalValue]];
    order.orderId = [[[NSUUID UUID]UUIDString].lowercaseString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    MaxPaymentViewController *payVC = [[MaxPaymentViewController alloc ] init];
    payVC.order = order;
    payVC.completionBlock = ^(BOOL succeeded, MLPayResult *result) {
        if (!succeeded) {
            [SVProgressHUD showErrorWithStatus:@"完成真实支付需要在MaxLeap后台的“应用设置”-“支付设置”中，设置支付宝、微信支付和银联支付的商户信息。"];
        }
        
        MCSupportInfo *supportInfo = [[MCSupportInfo alloc] init];
        supportInfo.belongToCFID = self.crowdFunding.objectId;
        supportInfo.supportMoney = supportMoney;
        supportInfo.supportUser = [MLUser currentUser];
        supportInfo.supportCount = self.supportCount;
        supportInfo.content = content;
        supportInfo.forCFReward = reward;
        supportInfo.supporterAddress = address;
        [supportInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [self.crowdFunding incrementKey:@"supportUserCount"];
                [self.crowdFunding incrementKey:@"completeNum" byAmount:@(supportMoney)];
                [self.crowdFunding saveInBackgroundWithBlock:nil];
                
                [[MLUser currentUser] incrementKey:@"supportTimes"];
                [[MLUser currentUser] saveInBackgroundWithBlock:nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kDidFinishSupportCF object:nil];
                
                [self.navigationController popViewControllerAnimated:NO];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [SVProgressHUD showErrorWithStatus:@"支付失败"];
            }
        }];
    };
    
    [self.navigationController pushViewController:payVC animated:YES];
}

#pragma mark - notifications
- (void)keyboardWillShow:(NSNotification *)notify {
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[notify.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    NSNumber *duration = [notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notify.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    // modify constraints
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    self.tableView.frame = CGRectMake(0, 0, width, height - CGRectGetHeight(keyboardBounds));
    
    CGRect rect = CGRectMake(0, CGRectGetHeight(keyboardBounds), width, height);
    [self.tableView scrollRectToVisible:rect animated:YES];
    
    // commit animations
    [UIView commitAnimations];
    
}

- (void)keyboardWillHidden:(NSNotification *)notify {
    NSNumber *duration = [notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notify.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    self.tableView.frame = self.view.bounds;
    
    [UIView commitAnimations];
}

#pragma mark - getters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.contentInset = UIEdgeInsetsMake(-34, 0, 0, 0);
        [_tableView registerClass:[MCDetailRewardCell class] forCellReuseIdentifier:kRewardCell];
        [_tableView registerClass:[MCDetailLimitNumCell class] forCellReuseIdentifier:kLimitNumCell];
        [_tableView registerClass:[MCDetailTextViewCell class] forCellReuseIdentifier:kTextViewCell];
        [_tableView registerClass:[MCDetailTextFieldCell class] forCellReuseIdentifier:kTextFieldCell];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
//        _tableView.bounces = NO;
        
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _tableView;
}

- (UIView *)bottomContainer {
    if (!_bottomContainer) {
        CGFloat height = CGRectGetHeight(self.view.bounds);
        CGFloat width = CGRectGetWidth(self.view.bounds);
        _bottomContainer = [[UIView alloc] initWithFrame:CGRectMake(0, height - kBottomContainerH, width, kBottomContainerH)];
        _bottomContainer.backgroundColor = [UIColor whiteColor];
        
        CGFloat btnW = 93;
        [_bottomContainer addSubview:self.totalNumLabel];
        self.totalNumLabel.frame = CGRectMake(0, 0, width - btnW - 15, kBottomContainerH);
        
        [_bottomContainer addSubview:self.payButton];
        self.payButton.frame = CGRectMake(width - btnW, 0, btnW, kBottomContainerH);
    }
    return _bottomContainer;
}

- (UILabel *)totalNumLabel {
    if (!_totalNumLabel) {
        _totalNumLabel = [[UILabel alloc] init];
        _totalNumLabel.textAlignment = NSTextAlignmentRight;
        [self updateTotalMoeny:0];
    }
    return _totalNumLabel;
}

- (UIButton *)payButton {
    if (!_payButton) {
        _payButton = [[UIButton alloc] init];
        [_payButton setTitle:@"支付" forState:UIControlStateNormal];
        [_payButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(233, 48, 48, 1)] forState:UIControlStateNormal];
        [_payButton addTarget:self action:@selector(payButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _payButton;
}

@end
