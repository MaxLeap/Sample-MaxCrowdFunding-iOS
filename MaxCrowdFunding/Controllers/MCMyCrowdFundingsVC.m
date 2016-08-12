//
//  MCMyCrowdFundingsVC.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/11.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCMyCrowdFundingsVC.h"
#import "UIScrollView+EmptyDataSet.h"
#import "UIView+CustomBorder.h"
#import "MCCrowdFunding.h"
#import "MCCFDetailViewController.h"
#import "MCAttentionInfo.h"
#import "MCSupportInfo.h"

static CGFloat kBtnContainerH = 50;

@interface MCMyCrowdFundingsVC () <UITableViewDelegate,
 UITableViewDataSource,
 DZNEmptyDataSetSource,
 DZNEmptyDataSetDelegate
>
@property (nonatomic, strong) UIView *btnContainer;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) UIButton *lastSelectedBtn;
@property (nonatomic, assign) MyCFShowType cfShowType;
@end

@implementation MCMyCrowdFundingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self buildUI];
}

- (void)buildUI {
    self.view.backgroundColor = [UIColor whiteColor];
    NSString *title;
    if (self.cfRelationShip == MCCFRelationShipMine) {
        title = @"发起的项目";
    } else if (self.cfRelationShip == MCCFRelationShipMySupport) {
        title = @"支持的项目";
    } else {
        title = @"关注的项目";
    }
    self.navigationItem.title = title;
    
    [self.view addSubview:self.btnContainer];
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIButton *tempBtn = self.lastSelectedBtn;
    self.lastSelectedBtn = nil;
    [self changeDataAction:tempBtn];
}


#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCMyCrowdFundingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    MCCrowdFunding *crowdFunding = self.dataSource[indexPath.row];
    [cell updateContentWithCrowdFunding:crowdFunding state:self.cfShowType];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self toShowCrowdFundingDetailAtIndexPath:indexPath];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *plainTxt = @"没有结果";
    NSAttributedString *attTxt = [[NSAttributedString alloc] initWithString:plainTxt
                                                                 attributes:@{
                        NSForegroundColorAttributeName: UIColorFromRGBA(52, 55, 59, 0.8),
                                   NSFontAttributeName: [UIFont systemFontOfSize:18]
                        }];
    return attTxt;
}

#pragma mark - actions
- (void)toShowCrowdFundingDetailAtIndexPath:(NSIndexPath *)indexPath {
    MCCrowdFunding *crowdFunding = self.dataSource[indexPath.row];
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

- (void)changeDataAction:(UIButton *)sender {
    if (self.lastSelectedBtn == sender) {
        return;
    }
    
    self.lastSelectedBtn.selected = NO;
    self.lastSelectedBtn = sender;
    sender.selected = YES;
    
    if (self.cfRelationShip == MCCFRelationShipMine) {
        [self fetchMineCrowdFundingData];
    } else if (self.cfRelationShip == MCCFRelationShipMySupport) {
        [self fetchMySupportCrowdFundingData];
    } else {
        [self fetchMyAttentionCrowdFundingData];
    }
}

- (void)fetchMyAttentionCrowdFundingData {
    MLQuery *attentionQuery = [MCAttentionInfo query];
    [attentionQuery whereKey:@"userID" equalTo:[MLUser currentUser].objectId];
    [attentionQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count) {
            NSArray *cfIDs = [objects valueForKey:@"cfID"];
            NSSet *ids = [NSSet setWithArray:cfIDs];
            [self fetchCrowdFundingsWithCFIDs:ids];
        } else {
            self.dataSource = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
}

- (void)fetchMySupportCrowdFundingData {
    MLQuery *supportQuery = [MCSupportInfo query];
    [supportQuery whereKey:@"supportUser" equalTo:[MLUser currentUser]];
    [supportQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count) {
            NSMutableArray *cfIDs = [objects valueForKey:@"belongToCFID"];
            NSSet *ids = [NSSet setWithArray:cfIDs];
            [self fetchCrowdFundingsWithCFIDs:ids];
        } else {
            self.dataSource = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
}

- (void)fetchCrowdFundingsWithCFIDs:(NSSet *)crowdFundingIDs {
    NSArray *ids = [crowdFundingIDs allObjects];
    MLQuery *cfQuery = [MCCrowdFunding query];
    [cfQuery whereKey:@"objectId" containedIn:ids];
    [cfQuery includeKey:@"publisher"];
    [cfQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count) {
            NSInteger tag = self.lastSelectedBtn.tag;
            switch (tag) {
                case 1000: {
                    self.cfShowType = MyCFShowTypeSuccessed;
                    
                    NSMutableArray *successedCF = [[NSMutableArray alloc] init];
                    for (MCCrowdFunding *crowdFunding in objects) {
                        BOOL isSuccessed = [self isSuccessedCrowdFunding:crowdFunding];
                        if (isSuccessed) {
                            [successedCF addObject:crowdFunding];
                        }
                    }
                    self.dataSource = successedCF;
                    break;
                }
                case 1001: {
                    self.cfShowType = MyCFShowTypeContinue;
                    
                    NSMutableArray *continueCF = [[NSMutableArray alloc] init];
                    for (MCCrowdFunding *crowdFunding in objects) {
                        BOOL isContunie = [self isContinuedCrowdFunding:crowdFunding];
                        if (isContunie) {
                            [continueCF addObject:crowdFunding];
                        }
                    }
                    self.dataSource = continueCF;
                    break;
                }
                case 1002: {
                    self.cfShowType = MyCFShowTypeFailed;
                    
                    NSMutableArray *failedCF = [[NSMutableArray alloc] init];
                    for (MCCrowdFunding *crowdFunding in objects) {
                        BOOL isFailed = [self isFailedCrowdFunding:crowdFunding];
                        if (isFailed) {
                            [failedCF addObject:crowdFunding];
                        }
                    }
                    self.dataSource = failedCF;
                    break;
                }
                default:
                    break;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });

    }];
}

- (void)fetchMineCrowdFundingData {
    MLQuery *cfQuey = [MCCrowdFunding query];
    [cfQuey whereKey:@"publisherID" equalTo:[MLUser currentUser].objectId];
    [cfQuey orderByDescending:@"createdAt"];
    [cfQuey includeKey:@"publisher"];
    NSInteger tag = self.lastSelectedBtn.tag;
    [cfQuey findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count) {
            switch (tag) {
                case 1000: {
                    self.cfShowType = MyCFShowTypeSuccessed;
                    
                    NSMutableArray *successedCF = [[NSMutableArray alloc] init];
                    for (MCCrowdFunding *crowdFunding in objects) {
                        BOOL isSuccessed = [self isSuccessedCrowdFunding:crowdFunding];
                        if (isSuccessed) {
                            [successedCF addObject:crowdFunding];
                        }
                    }
                    self.dataSource = successedCF;
                    break;
                }
                case 1001: {
                    self.cfShowType = MyCFShowTypeContinue;
                    
                    NSMutableArray *continueCF = [[NSMutableArray alloc] init];
                    for (MCCrowdFunding *crowdFunding in objects) {
                        BOOL isContunie = [self isContinuedCrowdFunding:crowdFunding];
                        if (isContunie) {
                            [continueCF addObject:crowdFunding];
                        }
                    }
                    self.dataSource = continueCF;
                    break;
                }
                case 1002: {
                    self.cfShowType = MyCFShowTypeFailed;
                    
                    NSMutableArray *failedCF = [[NSMutableArray alloc] init];
                    for (MCCrowdFunding *crowdFunding in objects) {
                        BOOL isFailed = [self isFailedCrowdFunding:crowdFunding];
                        if (isFailed) {
                            [failedCF addObject:crowdFunding];
                        }
                    }
                    self.dataSource = failedCF;
                    break;
                }
                default:
                    break;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (BOOL)isSuccessedCrowdFunding:(MCCrowdFunding *)crowdFunding {
    
    BOOL hasEnough = crowdFunding.completeNum >= crowdFunding.targetNum;
    if (hasEnough) {
        return YES;
    }
    return NO;
}

- (BOOL)isFailedCrowdFunding:(MCCrowdFunding *)crowdFunding {
    BOOL hasEnough = crowdFunding.completeNum >= crowdFunding.targetNum;
    BOOL hasOverdue = [[NSDate date] timeIntervalSinceDate:crowdFunding.endDate] > 0;
    if (!hasEnough && hasOverdue) {
        return YES;
    }
    return NO;
}

- (BOOL)isContinuedCrowdFunding:(MCCrowdFunding *)crowdFunding {
    BOOL hasOverdue = [[NSDate date] timeIntervalSinceDate:crowdFunding.endDate] > 0;
    if (!hasOverdue) {
        return YES;
    }
    return NO;
}


#pragma getters
- (UIView *)btnContainer {
    if (!_btnContainer) {
        CGFloat width = CGRectGetWidth(self.view.bounds);
        _btnContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 64, width, kBtnContainerH)];
        [_btnContainer addBottomBorderWithColor:UIColorFromRGBA(216, 216, 216, 1) width:1];
        
        NSArray *btnTitles = @[@"成功", @"进行", @"失败"];
        CGFloat btnW = width / 3;
        for (NSInteger i = 0; i < 3; i ++) {
            CGFloat btnX = btnW * i;
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btnX, 0, btnW, kBtnContainerH)];
            NSString *title = btnTitles[i];
            [btn setTitle:title forState:UIControlStateNormal];
            [btn setTitleColor:UIColorFromRGBA(52, 55, 59, 1) forState:UIControlStateNormal];
            [btn setTitleColor:UIColorFromRGBA(59, 163, 255, 1) forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(changeDataAction:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 1000 + i;
            
            [_btnContainer addSubview:btn];
            
            if (i != 2) {
                [btn addRightBorderWithColor:UIColorFromRGBA(216, 216, 216, 0.5) width:1 excludePoint:12 edgeType:ExcludeAllPoint];
            }
            
            if (i == 1) {
                [self changeDataAction:btn];
            }
        }
    }
    return _btnContainer;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64 + kBtnContainerH, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 64 - kBtnContainerH) style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [_tableView registerClass:[MCMyCrowdFundingCell class] forCellReuseIdentifier:@"cell"];
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        _tableView.rowHeight = 127;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
    }
    return _tableView;
}
@end



#pragma mark - MCMyCrowdFundingCell
@interface MCMyCrowdFundingCell ()
@property (nonatomic, strong) UIImageView *preImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@end

@implementation MCMyCrowdFundingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self.contentView addSubview:self.preImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.stateLabel];
    [self.contentView addSubview:self.timeLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat border = 10;
    CGFloat imgH = height - border * 2;
    CGFloat imgW = 140;
    self.preImageView.frame = CGRectMake(border, border, imgW, imgH);
    
    CGFloat labelX = CGRectGetMaxX(self.preImageView.frame) + 10;
    CGFloat labelW = width - labelX - border;
    CGFloat titleLabelH = 42;
    self.titleLabel.frame = CGRectMake(labelX, border, labelW, titleLabelH);
    
    CGFloat lableH = 15;
    CGFloat timeLabelY = CGRectGetMaxY(self.preImageView.frame) - lableH;
    self.timeLabel.frame = CGRectMake(labelX, timeLabelY, labelW, lableH);
    
    CGFloat stateLabelY = CGRectGetMinY(self.timeLabel.frame) - lableH - 3;
    self.stateLabel.frame = CGRectMake(labelX, stateLabelY, labelW, lableH);
}

- (void)updateContentWithCrowdFunding:(MCCrowdFunding *)crowdF state:(MyCFShowType)showType {
    NSArray *photos = crowdF.photos;
    NSString *imgURL = @"";
    if (photos.count) {
        imgURL = photos.firstObject;
    }
    [self.preImageView sd_setImageWithURL:[NSURL URLWithString:imgURL] placeholderImage:ImageNamed(@"")];
    
    self.titleLabel.text = crowdF.projectName;
    
    NSString *stateInfo;
    if (showType == MyCFShowTypeSuccessed) {
        stateInfo = @"筹款成功";
    } else if (showType == MyCFShowTypeFailed) {
        stateInfo = @"筹款失败";
    } else {
        stateInfo = @"筹款中";
    }
    self.stateLabel.text = stateInfo;
    
    NSDate *createDate = crowdF.createdAt;
    NSString *timeInfo = [self timeInfoWithCreateDate:createDate];
    self.timeLabel.text = timeInfo;
}

- (NSString *)timeInfoWithCreateDate:(NSDate *)createDate {
    NSDate *dateNow = [NSDate date];
    NSTimeInterval timeInterval = [dateNow timeIntervalSinceDate:createDate];
    if (timeInterval > 24 * 3600) {
        NSInteger day = (NSInteger)(timeInterval / (24 * 3600));
        return [NSString stringWithFormat:@"%ld 天前", (long)day];
    } else if (timeInterval > 3600) {
        NSInteger hours = (NSInteger)(timeInterval / (3600));
        return [NSString stringWithFormat:@"%ld 小时前", (long)hours];
    } else {
        NSInteger mins = (NSInteger) (timeInterval / 60);
        return [NSString stringWithFormat:@"%ld 分钟前", (long)mins];
    }
}

#pragma mark - getters
- (UIImageView *)preImageView {
    if (!_preImageView) {
        _preImageView = [[UIImageView alloc] init];
        _preImageView.contentMode = UIViewContentModeScaleAspectFill;
        _preImageView.clipsToBounds = YES;
    }
    return _preImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.font = [UIFont systemFontOfSize:11];
        _stateLabel.textColor = UIColorFromRGBA(52, 55, 59, 0.3);
    }
    return _stateLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:11];
        _timeLabel.textColor = UIColorFromRGBA(52, 55, 59, 0.3);
    }
    return _timeLabel;
}

@end