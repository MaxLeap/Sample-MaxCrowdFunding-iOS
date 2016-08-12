//
//  MCMeViewController.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/4.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCMeViewController.h"
#import "UIView+CustomBorder.h"
#import "MCMyWalletViewController.h"
#import "MCPersonAuthVC.h"
#import "MCHelpViewController.h"
#import "MCPersonalViewController.h"
#import "MCAddressViewController.h"
#import "MCMyCrowdFundingsVC.h"

static NSString * const kNoLoginCell = @"nologinCell";
static NSString * const kUserNameCell = @"userNameCell";
static NSString * const kUserDetailCell = @"userDetailCell";

@interface MCMeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation MCMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configDataSource];
    
    [self buildUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)configDataSource {
    NSArray *section0 = [MCUtils hasLogin] ? @[[MLUser currentUser]] : @[@"not login"];
    self.dataSource = @[section0, @[@"我的钱包", @"实名认证", @"收货地址"], @[@"支持帮助"]];
}

- (void)buildUI {
    self.navigationItem.title = @"我的";
    
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [MCUtils hasLogin] ? 2 : 1;
    }
    
    NSArray *sectionData = self.dataSource[section];
    return sectionData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (![MCUtils hasLogin]) {
            return 90 + 60;
        }
        return indexPath.row == 0 ? 90 : 60;
    } else {
        return 55.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (![MCUtils hasLogin]) {
            MCMeNoLoginCell *noLoginCell = [tableView dequeueReusableCellWithIdentifier:kNoLoginCell forIndexPath:indexPath];
            __weak MCMeViewController *weakSelf = self;
            noLoginCell.loginBtnBlock = ^() {
                [weakSelf toLoginViewController];
            };
            return noLoginCell;
        } else {
            MLUser *currentUser = [MLUser currentUser];
            if (indexPath.row == 0) {
                MCMeUserNameCell *nameCell = [tableView dequeueReusableCellWithIdentifier:kUserNameCell forIndexPath:indexPath];
                [nameCell updateContentWithUser:currentUser];
                nameCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return nameCell;
            } else {
                MCMeDetailCell *detailCell = [tableView dequeueReusableCellWithIdentifier:kUserDetailCell forIndexPath:indexPath];
                detailCell.crowdFundingBlock = ^() {
                    [self toShowMyProject];
                };
                detailCell.mySupportBlock = ^(){
                    [self toShowMySupportProjects];
                };
                detailCell.myAttentionBlock = ^() {
                    [self toShowMyAttentionProjects];
                };
                [detailCell updateContentWithUser:currentUser];
                return detailCell;
            }
        }
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        NSString *title = self.dataSource[indexPath.section][indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = title;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        [self toLoginViewController];
    } else if (indexPath.section == 1) {
        if (![MCUtils hasLogin]) {
            [SVProgressHUD showErrorWithStatus:@"请先登录"];
            return;
        }
        
        switch (indexPath.row) {
            case 0: {
                [self toMyWallet];
                break;
            }
            case 1: {
                [self toPersonAuthViewController];
                break;
            }
            case 2: {
                [self toAddressViewController];
                break;
            }
            case 3: {
                [self toShowMyProject];
                break;
            }
            default:
                break;
        }
    } else if (indexPath.section == 2) {
        [self toShowSupportAndHelpViewController];
    }
}

#pragma mark - actions
- (void)toLoginViewController {
    MCPersonalViewController *personVC = [[MCPersonalViewController alloc] initWithNibName:@"MCPersonalViewController" bundle:nil];
    personVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:personVC animated:YES];
}

- (void)toMyWallet {
    MCMyWalletViewController *myWalletVC = [[MCMyWalletViewController alloc] init];
    myWalletVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myWalletVC animated:YES];
}

- (void)toPersonAuthViewController {
    MCPersonAuthVC *personAuthVC = [[MCPersonAuthVC alloc] init];
    personAuthVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:personAuthVC animated:YES];
}

- (void)toAddressViewController {
    MCAddressViewController *addressVC = [[MCAddressViewController alloc] init];
    addressVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addressVC animated:YES];
}

- (void)toShowMyProject {
    MCMyCrowdFundingsVC *myCrowdFundingVC = [[MCMyCrowdFundingsVC alloc] init];
    myCrowdFundingVC.hidesBottomBarWhenPushed = YES;
    myCrowdFundingVC.cfRelationShip = MCCFRelationShipMine;
    [self.navigationController pushViewController:myCrowdFundingVC animated:YES];
}

- (void)toShowMySupportProjects {
    MCMyCrowdFundingsVC *myCFVC = [[MCMyCrowdFundingsVC alloc] init];
    myCFVC.hidesBottomBarWhenPushed = YES;
    myCFVC.cfRelationShip = MCCFRelationShipMySupport;
    [self.navigationController pushViewController:myCFVC animated:YES];
}

- (void)toShowMyAttentionProjects {
    MCMyCrowdFundingsVC *myCFVC = [[MCMyCrowdFundingsVC alloc] init];
    myCFVC.hidesBottomBarWhenPushed = YES;
    myCFVC.cfRelationShip = MCCFRelationShipMyAttention;
    [self.navigationController pushViewController:myCFVC animated:YES];
}

- (void)toShowSupportAndHelpViewController {
    MCHelpViewController *helpVC = [[MCHelpViewController alloc] init];
    helpVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:helpVC animated:YES];
}

#pragma mark - getters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        [_tableView registerClass:[MCMeNoLoginCell class] forCellReuseIdentifier:kNoLoginCell];
        [_tableView registerClass:[MCMeUserNameCell class] forCellReuseIdentifier:kUserNameCell];
        [_tableView registerClass:[MCMeDetailCell class] forCellReuseIdentifier:kUserDetailCell];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.contentInset = UIEdgeInsetsMake(-34, 0, 0, 0);
        
        _tableView.backgroundColor = UIColorFromRGBA(240, 240, 243, 1);
    }
    return _tableView;
}

@end


#pragma mark - MCMeNoLoginCell
@interface MCMeNoLoginCell ()
@property (nonatomic, strong) UIImageView *userIconImgView;
@property (nonatomic, strong) UIButton *logInBtn;
@end

@implementation MCMeNoLoginCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self.contentView addSubview:self.userIconImgView];
    [self.contentView addSubview:self.logInBtn];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat iconW = 60;
    CGFloat iconX = (width - iconW) / 2;
    CGFloat iconY = (height - iconW) / 2 - 20;
    self.userIconImgView.frame = CGRectMake(iconX, iconY, iconW, iconW);
    self.userIconImgView.layer.cornerRadius = iconW / 2;
    
    CGFloat btnW = 120;
    CGFloat btnH = 35;
    CGFloat btnX = (width - btnW) / 2;
    CGFloat btnY = CGRectGetMaxY(self.userIconImgView.frame) + 10;
    self.logInBtn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    self.logInBtn.layer.cornerRadius = btnH / 2;
}

- (void)loginButtonAction:(UIButton *)sender {
    if (self.loginBtnBlock) {
        self.loginBtnBlock();
    }
}

#pragma mark - getters
- (UIImageView *)userIconImgView {
    if (!_userIconImgView) {
        UIImage *img = ImageNamed(@"btn_nav_personal_normal");
        _userIconImgView = [[UIImageView alloc] initWithImage:img];
        _userIconImgView.contentMode = UIViewContentModeScaleAspectFill;
        _userIconImgView.backgroundColor = UIColorFromRGBA(158, 165, 168, 1);
    }
    return _userIconImgView;
}

- (UIButton *)logInBtn {
    if (!_logInBtn) {
        _logInBtn = [[UIButton alloc] init];
        [_logInBtn setTitle:@"登录/注册" forState:UIControlStateNormal];
        [_logInBtn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(158, 165, 168, 1)] forState:UIControlStateNormal];
        _logInBtn.clipsToBounds = YES;
        [_logInBtn addTarget:self action:@selector(loginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _logInBtn;
}

@end


#pragma mark - MCMeUserNameCell
@interface MCMeUserNameCell ()
@property (nonatomic, strong) UIImageView *userIconImgView;
@property (nonatomic, strong) UILabel *userNameLabel;
@end

@implementation MCMeUserNameCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self.contentView addSubview:self.userIconImgView];
    [self.contentView addSubview:self.userNameLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat border = 15;
    CGFloat userIconW = height - border * 2;
    self.userIconImgView.frame = CGRectMake(border, border, userIconW, userIconW);
    self.userIconImgView.layer.cornerRadius = userIconW / 2;
    
    CGFloat indicatorW = 25;
    
    CGFloat labelX = CGRectGetMaxX(self.userIconImgView.frame) + 5;
    CGFloat labelW = width - labelX - border - indicatorW - 5;
    self.userNameLabel.frame = CGRectMake(labelX, 0, labelW, height);
}

- (void)updateContentWithUser:(MLUser *)user {
    [self.userIconImgView sd_setImageWithURL:user[@"iconUrl"] placeholderImage:ImageNamed(@"btn_nav_personal_normal")];
    self.userNameLabel.text = user.username;
}

#pragma mark - getters
- (UIImageView *)userIconImgView {
    if (!_userIconImgView) {
        _userIconImgView = [[UIImageView alloc] init];
        _userIconImgView.contentMode = UIViewContentModeScaleAspectFill;
        _userIconImgView.backgroundColor = UIColorFromRGBA(187, 187, 187, 1);
        _userIconImgView.clipsToBounds = YES;
    }
    return _userIconImgView;
}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] init];
        _userNameLabel.font = [UIFont systemFontOfSize:14];
        _userNameLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
    }
    return _userNameLabel;
}

@end


#pragma mark - MCMeDetailCell
@interface MCMeDetailCell ()
@property (nonatomic, strong) MCDetailButton *cfCountBtn;
@property (nonatomic, strong) MCDetailButton *supportBtn;
@property (nonatomic, strong) MCDetailButton *attentionBtn;
@end

@implementation MCMeDetailCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    self.cfCountBtn = [[MCDetailButton alloc] init];
    [self.cfCountBtn addTarget:self action:@selector(crowdFundingButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.supportBtn = [[MCDetailButton alloc] init];
    [self.supportBtn addTarget:self action:@selector(supportButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.attentionBtn = [[MCDetailButton alloc] init];
    [self.attentionBtn addTarget:self action:@selector(attentionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.cfCountBtn];
    [self.contentView addSubview:self.supportBtn];
    [self.contentView addSubview:self.attentionBtn];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat btnW = width / 3;
    self.cfCountBtn.frame = CGRectMake(0, 0, btnW, height);
    self.supportBtn.frame = CGRectMake(btnW, 0, btnW, height);
    self.attentionBtn.frame = CGRectMake(btnW * 2, 0, btnW, height);
    
    [self.cfCountBtn addRightBorderWithColor:UIColorFromRGBA(178, 178, 178, 0.2) width:1 excludePoint:20 edgeType:ExcludeAllPoint];
    [self.supportBtn addRightBorderWithColor:UIColorFromRGBA(178, 178, 178, 0.2) width:1 excludePoint:20 edgeType:ExcludeAllPoint];
}

- (void)updateContentWithUser:(MLUser *)user {
    NSInteger cfSum = [user[@"crowdFundingSum"] integerValue];
    NSInteger supportCount = [user[@"supportTimes"] integerValue];
    NSInteger attentionSum = [user[@"attentionSum"] integerValue];
    
    [self.cfCountBtn configWithNum:cfSum desInfo:@"筹款"];
    [self.supportBtn configWithNum:supportCount desInfo:@"支持"];
    [self.attentionBtn configWithNum:attentionSum desInfo:@"关注"];
}

#pragma mark - actions
- (void)crowdFundingButtonAction:(UIButton *)sender {
    if (self.crowdFundingBlock) {
        self.crowdFundingBlock();
    }
}

- (void)supportButtonAction:(UIButton *)sender {
    if (self.mySupportBlock) {
        self.mySupportBlock();
    }
}

- (void)attentionButtonAction:(UIButton *)sender {
    if (self.myAttentionBlock) {
        self.myAttentionBlock();
    }
}

@end


#pragma mark - custom button
@interface MCDetailButton ()
@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, strong) UILabel *desLabel;
@end

@implementation MCDetailButton

- (id)init {
    if (self = [super init]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self addSubview:self.numLabel];
    [self addSubview:self.desLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat border = 8;
    CGFloat labelH = (height - border * 2) / 2;
    self.numLabel.frame = CGRectMake(0, border, width, labelH);
    
    self.desLabel.frame = CGRectMake(0, border + labelH, width, labelH);
}

- (void)configWithNum:(NSInteger)num desInfo:(NSString *)des {
    self.desLabel.text = des;
    NSString *numInfo;
    if ([des isEqualToString:@"筹款"]) {
        numInfo = [NSString stringWithFormat:@"￥ %ld", (long)num];
    } else {
        numInfo = [NSString stringWithFormat:@"%ld", (long)num];
    }
    self.numLabel.text = numInfo;
}

#pragma mark - getters
- (UILabel *)numLabel {
    if (!_numLabel) {
        _numLabel = [[UILabel alloc] init];
        _numLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
        _numLabel.font = [UIFont systemFontOfSize:15];
        _numLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _numLabel;
}

- (UILabel *)desLabel {
    if (!_desLabel) {
        _desLabel = [[UILabel alloc] init];
        _desLabel.textColor = UIColorFromRGBA(52, 55, 59, 0.5);
        _desLabel.font = [UIFont systemFontOfSize:12];
        _desLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _desLabel;
}
@end