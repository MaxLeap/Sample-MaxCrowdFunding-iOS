//
//  MCProjectRewardVC.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/6.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCProjectRewardVC.h"
#import "MCProjectRewardDesVC.h"

static CGFloat kSureButtonHeight = 50.0f;

static NSString * const kProductRewardCell = @"productRewardCell";
static NSString * const kAddRewardCell = @"addRewardCell";

@interface MCProjectRewardVC () <UITableViewDelegate,
 UITableViewDataSource,
 MCProjectRewardDesDelegate
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UIButton *sureButton;
@end

@implementation MCProjectRewardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configDataSource];
    
    [self buildUI];
}

- (void)configDataSource {
    self.dataSource = [[NSMutableArray alloc] init];
    if (_editRewards.count) {
        [self.dataSource addObjectsFromArray:_editRewards];
    }
}

- (void)buildUI {
    self.navigationItem.title = @"项目回报";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.sureButton];
}

#pragma mark - UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataSource.count && section == 0) {
        return self.dataSource.count;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.dataSource.count && section == 0) {
        return 0.01;
    } else {
        return 25;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!self.dataSource.count || section == 1) {
        return 10;
    }
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!self.dataSource.count || section == 1) {
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 10)];
        header.backgroundColor = [UIColor clearColor];
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.dataSource.count && section == 0) {
        return nil;
    } else {
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 25)];
        footer.backgroundColor = [UIColor clearColor];
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 25)];
        tipLabel.text = @"可以添加多个回报";
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.textColor = UIColorFromRGBA(52, 55, 59, 0.5);
        tipLabel.font = [UIFont systemFontOfSize:12];
        [footer addSubview:tipLabel];
        return footer;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSource.count && indexPath.section == 0) {
        return 60;
    } else {
        return 45;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSource.count && indexPath.section == 0) {
        MCProjectRewardDesCell *rewardCell = [tableView dequeueReusableCellWithIdentifier:kProductRewardCell forIndexPath:indexPath];
        MCCFReward *reward = self.dataSource[indexPath.row];
        [rewardCell updateContentWithReward:reward];
        return rewardCell;
    } else {
        MCProjectAddRewardCell *addCell = [tableView dequeueReusableCellWithIdentifier:kAddRewardCell forIndexPath:indexPath];
        NSString *title;
        if (self.dataSource.count) {
            title = @"继续添加";
        } else {
            title = @"添加回报";
        }
        [addCell updateTitle:title];
        return addCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.dataSource.count || indexPath.section == 1) {
        [self toAddReward];
    } else {
        MCCFReward *reward = self.dataSource[indexPath.row];
        [self toEditReward:reward];
    }
}

#pragma mark - custom delegate
- (void)didEndEditRewardDes:(MCCFReward *)reward isAdd:(BOOL)isAdd {
    
    if (isAdd) {
        [self.dataSource addObject:reward];
    } else {
        NSInteger index = -1;
        NSInteger i = 0;
        for (MCCFReward *aReward in self.dataSource) {
            if ([reward.rewardUUID isEqualToString:aReward.rewardUUID]) {
                index = i;
                break;
            }
            i ++;
        }
        if (index >= 0) {
            [self.dataSource replaceObjectAtIndex:index withObject:reward];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - actions
- (void)toAddReward {
    MCProjectRewardDesVC *rewardDesVC = [[MCProjectRewardDesVC alloc] init];
    rewardDesVC.delegate = self;
    [self.navigationController pushViewController:rewardDesVC animated:YES];
}

- (void)toEditReward:(MCCFReward *)reward {
    MCProjectRewardDesVC *rewardDesVC = [[MCProjectRewardDesVC alloc] init];
    rewardDesVC.delegate = self;
    rewardDesVC.editReward = reward;
    [self.navigationController pushViewController:rewardDesVC animated:YES];
}

- (void)sureButtonAction:(UIButton *)sender {
    if (self.dataSource.count <= 0) {
        [SVProgressHUD showErrorWithStatus:@"请先添加项目回报"];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(addRewardVCDidEndAddReward:)]) {
        [self.delegate addRewardVCDidEndAddReward:self.dataSource];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - getters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - kSureButtonHeight) style:UITableViewStylePlain];
        [_tableView registerClass:[MCProjectRewardDesCell class] forCellReuseIdentifier:kProductRewardCell];
        [_tableView registerClass:[MCProjectAddRewardCell class] forCellReuseIdentifier:kAddRewardCell];
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.tableFooterView = [UIView new];
        _tableView.bounces = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - kSureButtonHeight, CGRectGetWidth(self.view.bounds), kSureButtonHeight)];
        [_sureButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(59, 163, 255, 1)] forState:UIControlStateNormal];
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(sureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}

@end



#pragma mark - MCProjectRewardDesCell
@interface MCProjectRewardDesCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *rewardDesLabel;
@property (nonatomic, strong) UIImageView *accessImgView;
@end

@implementation MCProjectRewardDesCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.rewardDesLabel];
    [self.contentView addSubview:self.accessImgView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat borderX = 15;
    CGFloat borderY = 10;
    
    CGFloat imgW = 25;
    CGFloat imgX = width - borderX - imgW;
    CGFloat imgY = (height - imgW) / 2;
    self.accessImgView.frame = CGRectMake(imgX, imgY, imgW, imgW);
    
    CGFloat labelW = width - borderX * 2 - imgW;
    CGFloat labelH = (height - borderY * 2 - 5) / 2;
    self.titleLabel.frame = CGRectMake(borderX, borderY, labelW, labelH);
    self.rewardDesLabel.frame = CGRectMake(borderX, CGRectGetMaxY(self.titleLabel.frame) + 5, labelW, labelH);
}

- (void)updateContentWithReward:(MCCFReward *)reward {
    NSString *title = [NSString stringWithFormat:@"支持%ld元", (long)reward.supportMoney];
    self.titleLabel.text = title;
    self.rewardDesLabel.text = reward.rewardDes;
}

#pragma mark - getters
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
    }
    return _titleLabel;
}

- (UILabel *)rewardDesLabel {
    if (!_rewardDesLabel) {
        _rewardDesLabel = [[UILabel alloc] init];
        _rewardDesLabel.font = [UIFont systemFontOfSize:12];
        _rewardDesLabel.textColor = UIColorFromRGBA(52, 55, 59, 0.5);
    }
    return _rewardDesLabel;
}

- (UIImageView *)accessImgView {
    if (!_accessImgView) {
        _accessImgView = [[UIImageView alloc] init];
        _accessImgView.image = ImageNamed(@"icn_more");
    }
    return _accessImgView;
}

@end


#pragma mark - MCProjectAddRewardCell
@interface MCProjectAddRewardCell ()
@property (nonatomic, strong) UIImageView *addImgView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation MCProjectAddRewardCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self.contentView addSubview:self.addImgView];
    [self.contentView addSubview:self.titleLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat centerX = width / 2 - 8;
    self.titleLabel.frame = CGRectMake(centerX, 0, width / 2, height);
    
    CGFloat imgW = 25;
    CGFloat imgX = centerX - imgW - 8;
    CGFloat imgY = (height - imgW) / 2;
    self.addImgView.frame = CGRectMake(imgX, imgY, imgW, imgW);
}

- (void)updateTitle:(NSString *)title {
    self.titleLabel.text = title;
}

#pragma mark - getters
- (UIImageView *)addImgView {
    if (!_addImgView) {
        _addImgView = [[UIImageView alloc] init];
        _addImgView.image = ImageNamed(@"icn_huibao_add more");
        _addImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _addImgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = UIColorFromRGBA(59, 163, 255, 1);
        _titleLabel.font = [UIFont systemFontOfSize:15];
    }
    return _titleLabel;
}
@end