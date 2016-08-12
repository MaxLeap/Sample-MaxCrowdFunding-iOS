//
//  MCAddAddressVC.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/8.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCAddAddressVC.h"
#import "MCTextFieldCell.h"
#import "MCAddress.h"

static NSString * const kTextFieldCell = @"fieldCell";
static NSString * const kSwitchCell = @"switchCell";
static CGFloat const kSaveButtonHeight = 50.0f;

@interface MCAddAddressVC () <UITableViewDelegate,
 UITableViewDataSource,
 MCTextFieldCellDelegate
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) BOOL isDefault;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIView *editingView;
@end

@implementation MCAddAddressVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configDataSource];
    
    [self buildUI];
}

- (void)configDataSource {
    self.isDefault = _editAddress ? _editAddress.isDefault : YES;
    NSString *receiverName = _editAddress ? _editAddress.receiverName : @"";
    NSString *phoneNum = _editAddress ? _editAddress.phoneNum : @"";
    NSString *regiol = _editAddress ? _editAddress.regional : @"";
    NSString *detail = _editAddress ? _editAddress.detailAdd : @"";
    
    self.dataSource = [@[
             @{kTitle: @"收件人:", kValue: receiverName, kPlaceHolder: @"请输入收件人姓名"},
             @{kTitle: @"联系方式:", kValue: phoneNum, kPlaceHolder: @"请输入手机号码"},
             @{kTitle: @"省、市、区:", kValue: regiol, kPlaceHolder: @""},
             @{kTitle: @"详细地址:", kValue: detail, kPlaceHolder: @""},
             @{}
                         ] mutableCopy];
}

- (void)buildUI {
    self.navigationItem.title = _editAddress ? @"修改收货地址" : @"添加收货地址";
    
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.saveButton];
}

#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row <= 3) {
        MCTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:kTextFieldCell forIndexPath:indexPath];
        cell.delegate = self;
        NSDictionary *dic = self.dataSource[indexPath.row];
        [cell updateContentWithDic:dic];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSwitchCell forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"设为默认";
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
        cell.accessoryView = nil;
        
        UISwitch *defaultSwitch = [[UISwitch alloc] init];
        defaultSwitch.on = self.isDefault;
        [defaultSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = defaultSwitch;
        return cell;
    }
}

#pragma mark - custom delegate
- (void)textFieldCell:(MCTextFieldCell *)cell didStartEdit:(UITextField *)editView {
    self.editingView = editView;
}

- (void)textFieldCell:(MCTextFieldCell *)cell didEndEdit:(UITextField *)endEditView {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSDictionary *editedInfo = [cell contentDic];
    if (indexPath.row < self.dataSource.count) {
        [self.dataSource replaceObjectAtIndex:indexPath.row withObject:editedInfo];
    }
}

#pragma mark - actions
- (void)switchValueChanged:(UISwitch *)sw {
    self.isDefault = sw.isOn;
}

- (void)saveButtonAction:(UIButton *)sender {
    NSString *receiverName, *phoneNum, *regional, *detailAdd;
    NSInteger i = 0;
    for (NSDictionary *dic in self.dataSource) {
        switch (i) {
            case 0: {
                receiverName = dic[kValue];
                break;
            }
            case 1: {
                phoneNum = dic[kValue];
                break;
            }
            case 2: {
                regional = dic[kValue];
                break;
            }
            case 3: {
                detailAdd = dic[kValue];
                break;
            }
            default:
                break;
        }
        i ++;
    }
    
    if (receiverName.length <= 0 || phoneNum.length <= 0 || regional.length <= 0 || detailAdd.length <= 0) {
        [SVProgressHUD showErrorWithStatus:@"请填入完整信息"];
        return;
    }
    
    MCAddress *address = _editAddress ? _editAddress : [[MCAddress alloc] init];
    address.userID = [MLUser currentUser].objectId;
    address.receiverName = receiverName;
    address.phoneNum = phoneNum;
    address.regional = regional;
    address.detailAdd = detailAdd;
    address.isDefault = self.isDefault;
    [address saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [SVProgressHUD showSuccessWithStatus:@"saved!"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        } else {
            [SVProgressHUD showErrorWithStatus:@"保存失败"];
        }
    }];
}


#pragma mark - getters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView registerClass:[MCTextFieldCell class] forCellReuseIdentifier:kTextFieldCell];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kSwitchCell];
        _tableView.backgroundColor = UIColorFromRGBA(240, 240, 243, 1);
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = NO;
        _tableView.rowHeight = 70;
    }
    return _tableView;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - kSaveButtonHeight, CGRectGetWidth(self.view.bounds), kSaveButtonHeight)];
        [_saveButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(59, 163, 255, 1)] forState:UIControlStateNormal];
        [_saveButton setTitle:@"保存" forState:UIControlStateNormal];
        [_saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_saveButton addTarget:self action:@selector(saveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

@end
