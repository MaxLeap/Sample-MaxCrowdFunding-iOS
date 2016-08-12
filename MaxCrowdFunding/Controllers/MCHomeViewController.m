//
//  FirstViewController.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/4.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCHomeViewController.h"
#import "MCHomeHeaderView.h"
#import "MCCrowdFunding.h"
#import "MCHomeCFCell.h"
#import "MCCateCrowdFundingVC.h"
#import "MCCrowdFundingType.h"
#import "MCCFDetailViewController.h"
#import "MJRefresh.h"

@interface MCHomeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *hotCrowdFundings;
@property (nonatomic, strong) MCHomeHeaderView *tableHeader;
@end

@implementation MCHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self buildUI];
    
    [self addRefresh];
    
    [self addObservers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)buildUI {
    self.navigationItem.title = @"众筹";
    
    [self.view addSubview:self.tableView];
}

- (void)addRefresh {
    __weak MCHomeViewController *weakSelf = self;
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf fetchData];
    }];
    self.tableView.header.updatedTimeHidden = YES;
    self.tableView.header.stateHidden = YES;
    [self.tableView.header beginRefreshing];
}

static bool fetchHotCFFinish = NO;
static bool fetchNewCFFinish = NO;
- (void)fetchData {
    fetchHotCFFinish = NO;
    fetchNewCFFinish = NO;
    
    [self fetchHotCrowdFundings];
    
    [self fetchNewCrowdFundings];
}

- (void)fetchHotCrowdFundings {
    MLQuery *hotCFQuery = [MCCrowdFunding query];
    hotCFQuery.limit = 5;
    [hotCFQuery orderByDescending:@"attentionCount"];
    [hotCFQuery includeKey:@"publisher"];
    [hotCFQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        fetchHotCFFinish = YES;
        self.hotCrowdFundings = objects;
        if (fetchNewCFFinish) {
            [self.tableView.header endRefreshing];
        }
        
        if (objects) {
            [self.tableHeader updateContentWithCrowdFundings:objects];
        }
    }];
}

- (void)fetchNewCrowdFundings {
    MLQuery *newCFQuery = [MCCrowdFunding query];
    newCFQuery.limit = 8;
    [newCFQuery orderByDescending:@"createdAt"];
    [newCFQuery includeKey:@"publisher"];
    [newCFQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        fetchNewCFFinish = YES;
        if (fetchHotCFFinish) {
            [self.tableView.header endRefreshing];
        }
        
        if (objects) {
            self.dataSource = objects;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyToRefresh) name:kDidFinishSupportCF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyToRefresh) name:kDidDeleteCF object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyToRefresh) name:kDidPostNewCF object:nil];
}

- (void)notifyToRefresh {
    [self.tableView.header beginRefreshing];
}

#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 55)];
    
    UIView *contentContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 10, width, 45)];
    contentContainer.backgroundColor = [UIColor whiteColor];
    
    UIView *indicator = [[UIView alloc] initWithFrame:CGRectMake(10, 15, 2, 15)];
    indicator.backgroundColor = UIColorFromRGBA(59, 163, 255, 1);
    [contentContainer addSubview:indicator];
    
    CGFloat labelX = CGRectGetMaxX(indicator.frame) + 5;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 0, width - labelX, 45)];
    titleLabel.text = @"人气新品";
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
    [contentContainer addSubview:titleLabel];
    
    [header addSubview:contentContainer];
    
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCHomeCFCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    MCCrowdFunding *crowdFunding = self.dataSource[indexPath.row];
    [cell updateContentWithCrowdFunding:crowdFunding showProgress:NO];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self toShowCFDetailAtIndexPath:indexPath];
}

#pragma mark - actions
- (void)toShowDreamCrowdFundings {
    MCCateCrowdFundingVC *crowdFundingCateVC = [[MCCateCrowdFundingVC alloc] init];
    crowdFundingCateVC.cfType = MCCrowdFundingTypeDream;
    crowdFundingCateVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:crowdFundingCateVC animated:YES];
}

- (void)toShowProductCrowdFundings {
    MCCateCrowdFundingVC *crowdFundingCateVC = [[MCCateCrowdFundingVC alloc] init];
    crowdFundingCateVC.cfType = MCCrowdFundingTypeProduct;
    crowdFundingCateVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:crowdFundingCateVC animated:YES];
}

// tapped banner
- (void)toShowCrowdFundingAtIndex:(NSInteger)index {
    if (index >= self.hotCrowdFundings.count) {
        return;
    }
    
    MCCrowdFunding *crowdFunding = self.hotCrowdFundings[index];
    BOOL isMine = NO;
    if ([MCUtils hasLogin]) {
        MLUser *publisher = crowdFunding.publisher;
        isMine = [publisher.objectId isEqualToString:[MLUser currentUser].objectId];
    }
    MCCFDetailViewController *cfDetailVC = [[MCCFDetailViewController alloc] init];
    cfDetailVC.crowdFunding = crowdFunding;
    cfDetailVC.isMine = isMine;
    cfDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cfDetailVC animated:YES];
}

- (void)toShowCFDetailAtIndexPath:(NSIndexPath *)indexPath {
    MCCrowdFunding *crowdFunding = self.dataSource[indexPath.row];
    BOOL isMine = NO;
    if ([MCUtils hasLogin]) {
        MLUser *publisher = crowdFunding.publisher;
        isMine = [publisher.objectId isEqualToString:[MLUser currentUser].objectId];
    }
    MCCFDetailViewController *cfDetailVC = [[MCCFDetailViewController alloc] init];
    cfDetailVC.crowdFunding = crowdFunding;
    cfDetailVC.isMine = isMine;
    cfDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cfDetailVC animated:YES];
}


#pragma mark - getters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)) style:UITableViewStyleGrouped];
        [_tableView registerClass:[MCHomeCFCell class] forCellReuseIdentifier:@"cell"];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 113.0f;
        _tableView.contentInset = UIEdgeInsetsMake(-20, 0, -20, 0);
        
        _tableView.tableHeaderView = self.tableHeader;
    }
    return _tableView;
}

- (MCHomeHeaderView *)tableHeader {
    if (!_tableHeader) {
        _tableHeader = [[MCHomeHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 290)];
        
        __weak MCHomeViewController *weakSelf = self;
        _tableHeader.showDreamCFBlock = ^(){
            [weakSelf toShowDreamCrowdFundings];
        };
        _tableHeader.showProductCFBlock = ^(){
            [weakSelf toShowProductCrowdFundings];
        };
        _tableHeader.bannerBlock = ^(NSInteger index) {
            [weakSelf toShowCrowdFundingAtIndex:index];
        };
    }
    return _tableHeader;
}

@end
