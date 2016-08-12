//
//  MCHelpViewController.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/8.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCHelpViewController.h"
#import "MCSupportViewController.h"

@interface MCHelpViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation MCHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = @[@"意见反馈", @"常见问题", @"关于我们"];
    
    [self buildUI];
}

- (void)buildUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"支持帮助";
    
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSString *title = self.dataSource[indexPath.row];
    cell.textLabel.text = title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self sendEmailAction];
    } else if (indexPath.row == 1) {
        [self showFAQ];
    } else {
        [self aboutUS];
    }
}

#pragma mark - actions
- (void)sendEmailAction {
    [SVProgressHUD showErrorWithStatus:@"配置Email"];
}

- (void)showFAQ {
    MCSupportViewController *supportVC = [[MCSupportViewController alloc] init];
    [self.navigationController pushViewController:supportVC animated:YES];
}

- (void)aboutUS {
    
}

#pragma mark - setter & getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 54;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"headerCell"];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

@end
