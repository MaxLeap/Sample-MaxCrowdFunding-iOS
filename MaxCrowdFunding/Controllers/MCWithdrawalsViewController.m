//
//  MCWithdrawalsViewController.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/20.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCWithdrawalsViewController.h"
#import "MCTextFieldCell.h"

static NSString * const kTxtFieldCell = @"textFieldCell";

@interface MCWithdrawalsViewController () <UITableViewDelegate,
 UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation MCWithdrawalsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self buildUI];
}

- (void)buildUI {
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.title = @"余额提现";
    
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        MCTextFieldCell *textFieldCell = [tableView dequeueReusableCellWithIdentifier:kTxtFieldCell forIndexPath:indexPath];
        NSDictionary *info = @{
                    kTitle : @"提现金额:",
                               };
        [textFieldCell updateContentWithDic:info];
        return textFieldCell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.textLabel.text = @"添加银行卡";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 75.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 75.0f)];
    
    CGFloat borderX = 20;
    CGFloat btnW = width - 20 * 2;
    CGFloat btnH = 45.0;
    CGFloat btnY = 75.0 - btnH;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(borderX, btnY, btnW, btnH)];
    [btn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(59, 163, 255, 1)] forState:UIControlStateNormal];
    [btn setTitle:@"提现" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(withdrawalsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 5;
    btn.clipsToBounds = YES;
    [footer addSubview:btn];
    
    return footer;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - actions
- (void)withdrawalsButtonAction:(UIButton *)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    MCTextFieldCell *txtFieldCell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *info = [txtFieldCell contentDic];
    NSInteger withdrawalsNum = [info[kValue] integerValue];
    if (withdrawalsNum <= 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入有效的提现金额."];
        return;
    }
    
    NSInteger aNum = RAND_FROM_TO(90000, 99999);
    NSInteger aDay = RAND_FROM_TO(100, 199);
    NSString *msg = [NSString stringWithFormat:@"有%ld人在排队提现中，估计%ld天后可以提现成功...", (long)aNum, (long)aDay];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"🔥🔥🔥" message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:action];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - getters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        [_tableView registerClass:[MCTextFieldCell class] forCellReuseIdentifier:kTxtFieldCell];
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.rowHeight = 60.0f;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _tableView;
}

@end
