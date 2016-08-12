//
//  MCCateCrowdFundingVC.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/11.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCCateCrowdFundingVC.h"
#import "MCCrowdFunding.h"
#import "MCHomeCFCell.h"
#import "MJRefresh.h"
#import "MCCFDetailViewController.h"

@interface MCCateCrowdFundingVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *crowdFundings;
@end

@implementation MCCateCrowdFundingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self buildUI];
    
    [self addRefresh];
    
    [self addObservers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)buildUI {
    self.navigationItem.title = _cfType == MCCrowdFundingTypeDream ? @"梦想众筹" : @"产品众筹";
    
    [self.view addSubview:self.tableView];
}

- (void)addRefresh {
    __weak MCCateCrowdFundingVC *weakSelf = self;
    [self.tableView addLegendHeaderWithRefreshingBlock:^{
        [weakSelf fetchCrowdFundingList];
    }];
    self.tableView.header.updatedTimeHidden = YES;
    self.tableView.header.stateHidden = YES;
    [self.tableView.header beginRefreshing];
}

- (void)fetchCrowdFundingList {
    MLQuery *cfQuery = [MCCrowdFunding query];
    [cfQuery orderByDescending:@"createdAt"];
    [cfQuery includeKey:@"publisher"];
    BOOL isDream = _cfType == MCCrowdFundingTypeDream;
    [cfQuery whereKey:@"isDreamCF" equalTo:@(isDream)];
    
    [cfQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self.tableView.header endRefreshing];
        
        self.crowdFundings = objects;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyToRefresh) name:kDidFinishSupportCF object:nil];
}

- (void)notifyToRefresh {
    [self.tableView.header beginRefreshing];
}

#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.crowdFundings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCHomeCFCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MCCrowdFunding *crowdFunding = self.crowdFundings[indexPath.row];
    [cell updateContentWithCrowdFunding:crowdFunding showProgress:YES];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self toShowCrowdFundingDetailAtIndexPath:indexPath];
}

#pragma mark - actions
- (void)toShowCrowdFundingDetailAtIndexPath:(NSIndexPath *)indexPath {
    MCCrowdFunding *crowdFunding = self.crowdFundings[indexPath.row];
    BOOL isMine = NO;
    if ([MCUtils hasLogin]) {
        MLUser *publisher = crowdFunding.publisher;
        isMine = [publisher.objectId isEqualToString:[MLUser currentUser].objectId];
    }
    MCCFDetailViewController *cfDetailVC = [[MCCFDetailViewController alloc] init];
    cfDetailVC.crowdFunding = crowdFunding;
    cfDetailVC.isMine = isMine;
    [self.navigationController pushViewController:cfDetailVC animated:YES];
}

#pragma mark - getters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)) style:UITableViewStylePlain];
        [_tableView registerClass:[MCHomeCFCell class] forCellReuseIdentifier:@"cell"];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 127.0f;        
    }
    return _tableView;
}

@end
