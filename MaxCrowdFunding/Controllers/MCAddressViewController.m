//
//  MCAddressViewController.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/8.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCAddressViewController.h"
#import "MCAddress.h"
#import "MCAddAddressVC.h"
#import "UIScrollView+EmptyDataSet.h"

@interface MCAddressViewController () <UITableViewDataSource,
 UITableViewDelegate,
 DZNEmptyDataSetSource,
 DZNEmptyDataSetDelegate
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation MCAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self buildUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fetchAddressInfos];
}

- (void)buildUI {
    
    if (self.delegate) {
        self.navigationItem.title = @"选择收货地址";
    } else {
        self.navigationItem.title = @"收货地址";
    }
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addAddressAction:)];
    rightItem.tintColor = UIColorFromRGBA(59, 163, 255, 1);
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self.view addSubview:self.tableView];
}

- (void)fetchAddressInfos {
    MLQuery *addressQuery = [MCAddress query];
    NSString *currentUserID = [MLUser currentUser].objectId;
    [addressQuery whereKey:@"userID" equalTo:currentUserID];
    [addressQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"获取收货地址信息失败"];
        } else {
            self.dataSource = [objects mutableCopy];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
}


#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MCAddress *address = self.dataSource[indexPath.row];
    [cell updateContentWithAddress:address];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
//    return self.delegate ? NO : YES;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self deleteAddressAtIndexPath:indexPath];
    }];
    
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"修改" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        MCAddress *address = self.dataSource[indexPath.row];
        [self toEditAddress:address];
    }];
    
    return @[deleteAction, editAction];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MCAddress *address = self.dataSource[indexPath.row];
//    [self toEditAddress:address];
    [self didSelectedAddress:address];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *plainTxt = @"还没有添加收货地址，添加一个吧.";
    NSAttributedString *attTxt = [[NSAttributedString alloc] initWithString:plainTxt attributes:@{
                NSFontAttributeName: [UIFont systemFontOfSize:16],
                NSForegroundColorAttributeName: UIColorFromRGBA(187, 187, 187, 1)
                            }];
    return attTxt;
}

#pragma mark - actions
- (void)addAddressAction:(UIBarButtonItem *)item {
    MCAddAddressVC *addVC = [[MCAddAddressVC alloc] init];
    [self.navigationController pushViewController:addVC animated:YES];
}

- (void)didSelectedAddress:(MCAddress *)address {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(addressVCDidSelectedAddress:)]) {
            [self.delegate addressVCDidSelectedAddress:address];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self toEditAddress:address];
    }
}

- (void)toEditAddress:(MCAddress *)address {
    MCAddAddressVC *addVC = [[MCAddAddressVC alloc] init];
    addVC.editAddress = address;
    [self.navigationController pushViewController:addVC animated:YES];
}

- (void)deleteAddressAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.dataSource.count) {
        MCAddress *address = self.dataSource[indexPath.row];
        [address deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [SVProgressHUD showSuccessWithStatus:@"删除成功"];
                [self.dataSource removeObjectAtIndex:indexPath.row];
            } else {
                [SVProgressHUD showErrorWithStatus:@"删除失败"];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }
}

#pragma mark - getters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView registerClass:[MCAddressCell class] forCellReuseIdentifier:@"cell"];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
        _tableView.backgroundColor = UIColorFromRGBA(240, 240, 243, 1);
        _tableView.bounces = NO;
        _tableView.rowHeight = 70;
    }
    return _tableView;
}

@end


#pragma mark - MCAddressCell
@interface MCAddressCell ()
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UILabel *phoneNumLabel;
@property (nonatomic, strong) UILabel *addressLabel;
@end

@implementation MCAddressCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self.contentView addSubview:self.userNameLabel];
    [self.contentView addSubview:self.phoneNumLabel];
    [self.contentView addSubview:self.addressLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat borderX = 15;
    CGFloat borderY = 10;
    CGFloat topLabelW = (width - borderX * 2) / 2;
    CGFloat labelH = (height - borderY * 2 - 5) / 2;
    self.userNameLabel.frame = CGRectMake(borderX, borderY, topLabelW, labelH);
    
    self.phoneNumLabel.frame = CGRectMake(CGRectGetMaxX(self.userNameLabel.frame), borderY, topLabelW, labelH);
    
    CGFloat bottomLabelY = CGRectGetMaxY(self.userNameLabel.frame) + 5;
    self.addressLabel.frame = CGRectMake(borderX, bottomLabelY, (width - borderX * 2), labelH);
}

- (void)updateContentWithAddress:(MCAddress *)address {
    self.userNameLabel.text = address.receiverName;
    self.phoneNumLabel.text = address.phoneNum;
    NSString *adderssInfo = [NSString stringWithFormat:@"%@%@", address.regional, address.detailAdd];;
    if (address.isDefault) {
        adderssInfo = [NSString stringWithFormat:@"[默认]%@", adderssInfo];
    }
    self.addressLabel.text = adderssInfo;
}

#pragma mark - getters
- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] init];
        _userNameLabel.font = [UIFont systemFontOfSize:16];
        _userNameLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
    }
    return _userNameLabel;
}

- (UILabel *)phoneNumLabel {
    if (!_phoneNumLabel) {
        _phoneNumLabel = [[UILabel alloc] init];
        _phoneNumLabel.font = [UIFont systemFontOfSize:15];
        _phoneNumLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
        _phoneNumLabel.textAlignment = NSTextAlignmentRight;
    }
    return _phoneNumLabel;
}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        _addressLabel = [[UILabel alloc] init];
        _addressLabel.font = [UIFont systemFontOfSize:14];
        _addressLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
    }
    return _addressLabel;
}

@end
