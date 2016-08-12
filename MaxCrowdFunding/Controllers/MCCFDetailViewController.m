//
//  MCCFDetailViewController.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/12.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCCFDetailViewController.h"
#import "UIBarButtonItem+Custom.h"
#import "MCCrowdFunding.h"
#import "MCCFReward.h"
#import "MCCFTrends.h"
#import "MCSupportInfo.h"
#import "MCAttentionInfo.h"
#import <MaxSocialShare/MaxSocialShare.h>
#import "MCCFDetailHeaderView.h"
#import "UIView+CustomBorder.h"
#import "MCCFDetailCells.h"
#import "MCSupportCFViewController.h"
#import "MCPublisherTrendVC.h"

static CGFloat kBottomContainerH = 50.0f;

static NSString * const kTimeCell = @"timeCell";
static NSString * const kProductRewardCell = @"rewardCell";
static NSString * const kSupporterCell = @"supporterCell";
static NSString * const kProjectDetailCell = @"projectDetail";
static NSString * const kProjectTrendCell = @"trendCell";

@interface MCCFDetailViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *bottomBtnContainer;
@property (nonatomic, strong) UIButton *supportBtn;
@property (nonatomic, strong) MCAttentionButton *attentionBtn;
@property (nonatomic, strong) MCCFDetailHeaderView *headerView;
// section 项目详情
@property (nonatomic, strong) UIButton *detailButton;
@property (nonatomic, strong) UIButton *trendButton;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, strong) UIButton *lastSelectedBtn;

// data source
@property (nonatomic, strong) NSArray *productRewards;
@property (nonatomic, strong) NSArray *projectTrends;
@property (nonatomic, strong) NSArray *supportInfos;
@end

@implementation MCCFDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lastSelectedBtn = self.detailButton;
    
    [self buildUI];
    
    [self checkHasAttention];
    
    [self fetchDataAboutCurrentCrowdFunding];
    
    [self addObservers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.headerView updateDetailInfoWithCrowdFunding:self.crowdFunding];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDidFinishSupportCF object:nil];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyToRefresh:) name:kDidFinishSupportCF object:nil];
}

- (void)buildUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"众筹详情";
    
    UIBarButtonItem *shareItem = [UIBarButtonItem barButtonItemWithNormalImagenName:@"icn_share" selectedImageName:@"" target:self action:@selector(shareAction:)];
    if (_isMine) {
        UIBarButtonItem *addTrendItem = [UIBarButtonItem barButtonItemWithNormalImagenName:@"icn_zhongchouxiangqin_edit" selectedImageName:@"" target:self action:@selector(addTrendAction:)];
        self.navigationItem.rightBarButtonItems = @[addTrendItem, shareItem];
    } else {
        self.navigationItem.rightBarButtonItem = shareItem;
    }
    
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.bottomBtnContainer];
}

- (void)checkHasAttention {
    if (![MCUtils hasLogin]) {
        return;
    }
    
    MLQuery *query = [MCAttentionInfo query];
    [query whereKey:@"userID" equalTo:[MLUser currentUser].objectId];
    __weak MCCFDetailViewController *weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count) {
            NSArray *attentionCFIDs = [objects valueForKey:@"cfID"];
            if ([attentionCFIDs containsObject:weakSelf.crowdFunding.objectId]) {
                weakSelf.attentionBtn.selected = YES;
            }
        }
    }];
}


#pragma mark - UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.crowdFunding.isDreamCF ? 2 : 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    BOOL isProductDetailSection = (self.crowdFunding.isDreamCF && section == 0) || (!self.crowdFunding.isDreamCF && section == 2);
    if (isProductDetailSection) {
        // product detail section
        return self.lastSelectedBtn == self.detailButton ? 1 : self.projectTrends.count;
    } else if ((self.crowdFunding.isDreamCF && section == 1) || (!self.crowdFunding.isDreamCF && section == 3)) {
        // supporter section
        return self.supportInfos.count;
    } else if (!self.crowdFunding.isDreamCF && section == 0) {
        // 运费和发货时间 section
        return 1;
    } else if (!self.crowdFunding.isDreamCF && section == 1) {
        // 产品回报 section
        return self.productRewards.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 55.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 10.0f)];
    header.backgroundColor = UIColorFromRGBA(240, 240, 243, 1);
    
    if ((self.crowdFunding.isDreamCF && section == 0) || (!self.crowdFunding.isDreamCF && section == 2)) {
        // 项目详情
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 10, width, 45)];
        container.backgroundColor = [UIColor whiteColor];
        [container addTopBorderWithColor:UIColorFromRGBA(216, 216, 216, 0.6) width:1];
        [container addBottomBorderWithColor:UIColorFromRGBA(216, 216, 216, 1) width:1];
        [container addSubview:self.detailButton];
        [container addSubview:self.trendButton];
        
        CGFloat btnW = width / 2;
        self.detailButton.frame = CGRectMake(0, 0, btnW, 45);
        self.trendButton.frame = CGRectMake(btnW, 0, btnW, 45);
        
        CGFloat indicatorW = 70;
        CGFloat indicatorH = 2;
        CGFloat indicatorX = self.lastSelectedBtn == self.detailButton ? (btnW - indicatorW) / 2 :
        (btnW - indicatorW) / 2 + btnW;
        CGFloat indicatorY = 45 - indicatorH;
        UIView *indicator = [[UIView alloc] initWithFrame:CGRectMake(indicatorX, indicatorY, indicatorW, indicatorH)];
        indicator.backgroundColor = UIColorFromRGBA(59, 163, 255, 1);
        [container addSubview:indicator];
        self.indicatorView = indicator;
        
        [header addSubview:container];
        
    } else {
        NSString *sectionTitle;
        if ((self.crowdFunding.isDreamCF && section == 1) || (!self.crowdFunding.isDreamCF && section == 3)) {
            // 支持者
            sectionTitle = @"支持者";
        } else if (!self.crowdFunding.isDreamCF && section == 0) {
            // 运费 和发货时间
            sectionTitle = @"运费和发货时间";
        } else if (!self.crowdFunding.isDreamCF && section == 1) {
            // 产品回报
            sectionTitle = @"产品回报";
        }
        
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 10, width, 45)];
        container.backgroundColor = [UIColor whiteColor];
        [container addTopBorderWithColor:UIColorFromRGBA(216, 216, 216, 0.6) width:1];
        [container addBottomBorderWithColor:UIColorFromRGBA(216, 216, 216, 1) width:1];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, width - 15, 45)];
        label.text = sectionTitle;
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = UIColorFromRGBA(52, 55, 59, 1);
        [container addSubview:label];
        [header addSubview:container];
    }
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.crowdFunding.isDreamCF) {
        if (indexPath.section == 0) {
            if (self.lastSelectedBtn == self.detailButton) {
                return [MCProductDetailCell rowHeightForCrowdFunding:self.crowdFunding];
            } else {
                return [MCProductTrendCell rowHeightForTrend:self.projectTrends[indexPath.row]];
            }
        }
        
        return 100;
    } else {
        CGFloat rowHeight = 100;
        switch (indexPath.section) {
            case 0: {
                rowHeight = 72;
                break;
            }
            case 1: {
                rowHeight = 75;
                break;
            }
            case 2: {
                if (self.lastSelectedBtn == self.detailButton) {
                    rowHeight =  [MCProductDetailCell rowHeightForCrowdFunding:self.crowdFunding];
                } else {
                    rowHeight = [MCProductTrendCell rowHeightForTrend:self.projectTrends[indexPath.row]];
                }
                break;
            }
            case 3: {
                rowHeight = 100;
                break;
            }
            default:
                break;
        }
        return rowHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL isProductDetailSection = (self.crowdFunding.isDreamCF && indexPath.section == 0) || (!self.crowdFunding.isDreamCF && indexPath.section == 2);
    if (isProductDetailSection) {
        // product detail section
        if (self.lastSelectedBtn == self.detailButton) {
            MCProductDetailCell *productDesCell = [tableView dequeueReusableCellWithIdentifier:kProjectDetailCell forIndexPath:indexPath];
            [productDesCell updateContentWithCrowdFunding:self.crowdFunding];
            return productDesCell;
        } else {
            MCProductTrendCell *trendCell = [tableView dequeueReusableCellWithIdentifier:kProjectTrendCell forIndexPath:indexPath];
            MCCFTrends *productTrend = self.projectTrends[indexPath.row];
            BOOL isLatest = indexPath.row == 0;
            BOOL isFirst = indexPath.row == self.projectTrends.count - 1;
            [trendCell updateContentWithTrend:productTrend isLatest:isLatest isFirst:isFirst];
            
            return trendCell;
        }
    } else if ((self.crowdFunding.isDreamCF && indexPath.section == 1) || (!self.crowdFunding.isDreamCF && indexPath.section == 3)) {
        // supporter section
        MCDetailSupporterCell *suppterCell = [tableView dequeueReusableCellWithIdentifier:kSupporterCell forIndexPath:indexPath];
        MCSupportInfo *supportInfo = self.supportInfos[indexPath.row];
        [suppterCell updateContentWithSupportInfo:supportInfo];
        return suppterCell;
    } else if (!self.crowdFunding.isDreamCF && indexPath.section == 0) {
        // 运费和发货时间 section
        MCDetailTimeCell *timeCell = [tableView dequeueReusableCellWithIdentifier:kTimeCell forIndexPath:indexPath];
        NSString *freightInfo = _crowdFunding.freightInfo.length ? _crowdFunding.freightInfo : @"";
        NSString *deliveryTimeInfo = _crowdFunding.deliveryTimeInfo.length ? _crowdFunding.deliveryTimeInfo : @"";
        NSDictionary *info = @{kMailCostInfo: freightInfo,
                               kDeliverTimeInfo: deliveryTimeInfo};
        [timeCell updateContentWithDic:info];
        
        return timeCell;
    } else if (!self.crowdFunding.isDreamCF && indexPath.section == 1) {
        // 产品回报 section
        MCDetailRewardCell *rewardCell = [tableView dequeueReusableCellWithIdentifier:kProductRewardCell forIndexPath:indexPath];
        MCCFReward *reward = self.productRewards[indexPath.row];
        NSArray *photos = self.crowdFunding.photos;
        NSString *photo = photos.count > 0 ? photos.firstObject : @"";
        [rewardCell updateContentWithReward:reward photo:photo];
        return rewardCell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

#pragma mark - fetch data
- (void)fetchDataAboutCurrentCrowdFunding {
    [self fetchProductRewards];
    
    [self fetchProjectTrends];
    
    [self fetchSupporters];
}

- (void)fetchProductRewards {
    if (self.crowdFunding.isDreamCF) {
        return;
    }
    
    MLQuery *rewardQuery = [MCCFReward query];
    [rewardQuery whereKey:@"belongToCFID" equalTo:self.crowdFunding.objectId];
    [rewardQuery orderByAscending:@"supportMoney"];
    
    [rewardQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.productRewards = objects;
        
        [NSThread sleepForTimeInterval:0.2];
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:1];
//            [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
        });
    }];
}

- (void)fetchProjectTrends {
    MLQuery *trendQuery = [MCCFTrends query];
    [trendQuery whereKey:@"belongToCFID" equalTo:self.crowdFunding.objectId];
    [trendQuery orderByDescending:@"createdAt"];
    
    [trendQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.projectTrends = objects;
        
        [NSThread sleepForTimeInterval:0.2];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.lastSelectedBtn == self.trendButton) {
                NSInteger index = self.crowdFunding.isDreamCF ? 0 : 2;
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
                [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
            }
        });
    }];
}

- (void)notifyToRefresh:(NSNotification *)notify {
    [self fetchSupporters];
}

- (void)fetchSupporters {
    MLQuery *query = [MCSupportInfo query];
    [query whereKey:@"belongToCFID" equalTo:self.crowdFunding.objectId];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"supportUser"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.supportInfos = objects;
        
        [NSThread sleepForTimeInterval:0.2];
        dispatch_async(dispatch_get_main_queue(), ^{
//            NSInteger index = weakSelf.crowdFunding.isDreamCF ? 1 : 3;
//            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
//            [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
            
            [self.tableView reloadData];
        });
    }];
}


#pragma mark - actions
- (void)supportButtonAction:(UIButton *)sender {
    NSLog(@"support");
    if (![MCUtils hasLogin]) {
        [SVProgressHUD showErrorWithStatus:@"请先登录"];
        return;
    }
    
    MCSupportCFViewController *supportCFVC = [[MCSupportCFViewController alloc] initWithCrowdFunding:self.crowdFunding];
    supportCFVC.rewards = self.productRewards;
    [self.navigationController pushViewController:supportCFVC animated:YES];
    
}

- (void)attentionButtonAction:(UIButton *)sender {
    NSLog(@"attention");
    if (![MCUtils hasLogin]) {
        [SVProgressHUD showErrorWithStatus:@"请先登录"];
        return;
    }
    
    if (sender.selected) {
        MLQuery *query = [MCAttentionInfo query];
        [query whereKey:@"userID" equalTo:[MLUser currentUser].objectId];
        [query whereKey:@"cfID" equalTo:self.crowdFunding.objectId];
        
        __weak MCCFDetailViewController *weakSelf = self;
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (objects) {
                MCAttentionInfo *attention = objects.firstObject;
                [attention deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        sender.selected = NO;
                        
                        MLUser *currentUser = [MLUser currentUser];
                        [currentUser incrementKey:@"attentionSum" byAmount:@(-1)];
                        [currentUser saveInBackgroundWithBlock:nil];
                        
                        [weakSelf.crowdFunding incrementKey:@"attentionCount" byAmount:@(-1)];
                        [weakSelf.crowdFunding saveInBackgroundWithBlock:nil];
                        
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"取消关注失败"];
                    }
                }];
            } else {
                [SVProgressHUD showErrorWithStatus:@"取消关注失败"];
            }
        }];
    } else {
        MCAttentionInfo *attention = [[MCAttentionInfo alloc] init];
        attention.userID = [MLUser currentUser].objectId;
        attention.cfID = self.crowdFunding.objectId;
        
        __weak MCCFDetailViewController *weakSelf = self;
        [attention saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                sender.selected = YES;
                
                MLUser *currentUser = [MLUser currentUser];
                [currentUser incrementKey:@"attentionSum"];
                [currentUser saveInBackgroundWithBlock:nil];
                
                [weakSelf.crowdFunding incrementKey:@"attentionCount"];
                [weakSelf.crowdFunding saveInBackgroundWithBlock:nil];
            } else {
                [SVProgressHUD showErrorWithStatus:@"关注失败"];
            }
        }];
    }
}

- (void)showCrowdFundingDetailAction:(UIButton *)sender {
    if (self.lastSelectedBtn == sender) {
        return;
    }
    
    self.lastSelectedBtn = sender;
    
    NSInteger index = self.crowdFunding.isDreamCF ? 0 : 2;
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationRight];
}

- (void)showCrowdFundingTrendAction:(UIButton *)sender {
    if (self.lastSelectedBtn == sender) {
        return;
    }
    
    self.lastSelectedBtn = sender;
    NSInteger index = self.crowdFunding.isDreamCF ? 0 : 2;
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)addTrendAction:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"项目管理" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *addTrendAction = [UIAlertAction actionWithTitle:@"添加项目动态" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self toAddTrendViewController];
    }];
    [alertController addAction:addTrendAction];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除项目" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self toDeleteCurrentCrowdFunding];
    }];
    [alertController addAction:deleteAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)toAddTrendViewController {
    MCPublisherTrendVC *publishTrendVC = [[MCPublisherTrendVC alloc] init];
    publishTrendVC.crowdFunding = self.crowdFunding;
    [self.navigationController pushViewController:publishTrendVC animated:YES];
}

- (void)toDeleteCurrentCrowdFunding {
    [SVProgressHUD showWithStatus:@"删除中..."];
    [self.crowdFunding deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [SVProgressHUD showSuccessWithStatus:@"删除成功"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidDeleteCF object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [SVProgressHUD showErrorWithStatus:@"删除失败"];
        }
    }];
}

- (void)shareAction:(UIButton *)sender {
    
    [SVProgressHUD showWithStatus:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *photos = self.crowdFunding.photos;
        NSString *firstPhotoURL = photos.firstObject;
        
        // 腾讯，微博，微信都支持以下字段
        MLShareItem *shareItem = [MLShareItem imageItemWithImageURL:[NSURL URLWithString:firstPhotoURL] title:self.crowdFunding.projectName detail:self.crowdFunding.projectDes];
        shareItem.title = self.crowdFunding.projectName;
        shareItem.detail = self.crowdFunding.projectDes;
        // 微信分享 要求图片大小 < 40 k
        //        NSURL *coverImgURL = [NSURL URLWithString:firstPhotoURL];
        //        shareItem.previewImageData = [NSData dataWithContentsOfURL:coverImgURL];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            
            // 若要兼容iPad， 需要container
            MaxSocialContainer *container = [MaxSocialContainer containerWithRect:self.view.frame inView:self.view];
            [MaxSocialShare shareItem:shareItem withContainer:container completion:^(MLSActivityType activityType, BOOL completed, NSError * _Nullable activityError) {
                NSLog(@"error = %@", activityError);
                if (completed) {
                    [SVProgressHUD showSuccessWithStatus:@"分享成功!"];
                } else {
                    [SVProgressHUD showErrorWithStatus:@"分享失败!"];
                }
            }];
        });
    });
}

#pragma mark - getters && setters

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - kBottomContainerH) style:UITableViewStylePlain];
        _tableView.tableFooterView = [UIView new];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        [_tableView registerClass:[MCDetailTimeCell class] forCellReuseIdentifier:kTimeCell];
        [_tableView registerClass:[MCDetailRewardCell class] forCellReuseIdentifier:kProductRewardCell];
        [_tableView registerClass:[MCDetailSupporterCell class] forCellReuseIdentifier:kSupporterCell];
        [_tableView registerClass:[MCProductDetailCell class] forCellReuseIdentifier:kProjectDetailCell];
        [_tableView registerClass:[MCProductTrendCell class] forCellReuseIdentifier:kProjectTrendCell];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 80.0f;
        
        _tableView.tableHeaderView = self.headerView;
    }
    return _tableView;
}

- (MCCFDetailHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[MCCFDetailHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 385)];
        [_headerView updateDetailInfoWithCrowdFunding:self.crowdFunding];
    }
    return _headerView;
}

- (UIView *)bottomBtnContainer {
    if (!_bottomBtnContainer) {
        CGFloat width = CGRectGetWidth(self.view.bounds);
        CGFloat height = CGRectGetHeight(self.view.bounds);
        
        _bottomBtnContainer = [[UIView alloc] initWithFrame:CGRectMake(0, height - kBottomContainerH, width, kBottomContainerH)];
        
        self.supportBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width * 0.75, kBottomContainerH)];
        [self.supportBtn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(253, 96, 74, 1)] forState:UIControlStateNormal];
        [self.supportBtn setTitle:@"我要支持" forState:UIControlStateNormal];
        [self.supportBtn addTarget:self action:@selector(supportButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.supportBtn.enabled = !_isMine;
        [_bottomBtnContainer addSubview:self.supportBtn];
        
        self.attentionBtn = [[MCAttentionButton alloc] initWithFrame:CGRectMake(width * 0.75, 0, width * 0.25, kBottomContainerH)];
        [self.attentionBtn setTitle:@"关注" forState:UIControlStateNormal];
        [self.attentionBtn setTitle:@"已关注" forState:UIControlStateSelected];
        [self.attentionBtn setImage:ImageNamed(@"btn_focus_normal") forState:UIControlStateNormal];
        [self.attentionBtn setImage:ImageNamed(@"btn_focus_selected") forState:UIControlStateSelected];
        [self.attentionBtn addTarget:self action:@selector(attentionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.attentionBtn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(216, 216, 216, 1)] forState:UIControlStateNormal];
        [_bottomBtnContainer addSubview:self.attentionBtn];
    }
    return _bottomBtnContainer;
}

- (UIButton *)detailButton {
    if (!_detailButton) {
        _detailButton = [[UIButton alloc] init];
        [_detailButton setTitle:@"项目详情" forState:UIControlStateNormal];
        _detailButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_detailButton setTitleColor:UIColorFromRGBA(52, 55, 59, 1) forState:UIControlStateNormal];
        [_detailButton addTarget:self action:@selector(showCrowdFundingDetailAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _detailButton;
}

- (UIButton *)trendButton {
    if (!_trendButton) {
        _trendButton = [[UIButton alloc] init];
        [_trendButton setTitle:@"项目动态" forState:UIControlStateNormal];
        _trendButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_trendButton setTitleColor:UIColorFromRGBA(52, 55, 59, 1) forState:UIControlStateNormal];
        [_trendButton addTarget:self action:@selector(showCrowdFundingTrendAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _trendButton;
}

@end


#pragma mark - MCAttentionButton
@implementation MCAttentionButton
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imgW = 22;
    CGFloat imgH = 19;
    CGFloat imgX = (CGRectGetWidth(self.bounds) - imgW) / 2;
    CGFloat imgY = 8;
    self.imageView.frame = CGRectMake(imgX, imgY, imgW, imgH);
    
    CGFloat labelY = CGRectGetMaxY(self.imageView.frame) + 5;
    CGFloat labelH = CGRectGetHeight(self.bounds) - labelY - 5;
    self.titleLabel.frame = CGRectMake(0, labelY, CGRectGetWidth(self.bounds), labelH);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.titleLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
}
@end
