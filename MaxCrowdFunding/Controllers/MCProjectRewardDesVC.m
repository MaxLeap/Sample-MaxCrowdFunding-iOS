//
//  MCProjectRewardDesVC.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/6.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCProjectRewardDesVC.h"
#import "UITextView+Placeholder.h"

static CGFloat const kSureButtonHeight = 50.0f;
static NSString * const kCellID = @"cell";

static NSString * const kTitle = @"titleKey";
static NSString * const kValue = @"valueKey";
static NSString * const kPlaceHolder = @"placeHolder";
static NSString * const kSubText = @"subText";

@interface MCProjectRewardDesVC () <UITableViewDelegate,
 UITableViewDataSource,
 MCProjectRewardCellProtocol
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) UIView *editingView;
@end

@implementation MCProjectRewardDesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configDataSource];
    
    [self buildUI];
}

- (void)configDataSource {
    NSString *money = _editReward.supportMoney > 0 ? [NSString stringWithFormat:@"%ld", _editReward.supportMoney] : @"";
    NSString *rewardDes = _editReward ? _editReward.rewardDes : @"";
    
    NSString *limitCount;
    if (!_editReward || _editReward.limitNum == NSIntegerMax) {
        limitCount = @"";
    } else {
        limitCount = [NSString stringWithFormat:@"%ld", (long)_editReward.limitNum];
    }
    
    self.dataSource = [@[
        @{kTitle: @"筹款金额:", kValue: money, kPlaceHolder: @"请输入金额", kSubText: @"元"},
        @{kTitle: @"项目回报:", kValue: rewardDes, kPlaceHolder: @"请输入项目回报，不少于30字", kSubText: @""},
        @{kTitle: @"限制数量:", kValue: limitCount, kPlaceHolder: @"默认不限制", kSubText: @"份"},
                         ] mutableCopy];
}

- (void)buildUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"回报描述";
    
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.sureButton];
}

#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 1 ? 120.0 : 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCProjectRewardCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID forIndexPath:indexPath];
    NSDictionary *content = self.dataSource[indexPath.row];
    [cell updateContentWithContent:content isTextField:indexPath.row != 1];
    cell.delegate = self;
    return cell;
}

#pragma mark - MCProjectRewardCellProtocol
- (void)rewardCell:(MCProjectRewardCell *)cell didBeginEdit:(UIView *)editView {
    self.editingView = editView;
}

- (void)rewardCell:(MCProjectRewardCell *)cell didEndEdit:(UIView *)endView {
    [endView resignFirstResponder];
    
    NSDictionary *content = [cell contentInfo];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath) {
        [self.dataSource replaceObjectAtIndex:indexPath.row withObject:content];
    }
}

#pragma mark - actions
- (void)sureButtonAction:(UIButton *)sender {
    NSInteger sumMoney = 0, limitCount = NSIntegerMax;
    NSString *projectDes;
    for (NSInteger i = 0; i < self.dataSource.count; i ++) {
        NSDictionary *content = self.dataSource[i];
        if (i == 0) {
            sumMoney = [content[kValue] integerValue];
        } else if (i == 1) {
            projectDes = content[kValue];
        } else if (i == 2) {
            NSString *limitString = content[kValue];
            if (limitString.length) {
                limitCount = [content[kValue] integerValue];
            }
        }
    }
    
    if (sumMoney <= 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入筹款金额"];
        return;
    }
    
    if (projectDes.length < 30) {
        [SVProgressHUD showErrorWithStatus:@"项目回报描述不少于30字"];
        return;
    }
    
    if (limitCount <= 0) {
        [SVProgressHUD showErrorWithStatus:@"限制数量输入错误"];
        return;
    }
    
    MCCFReward *reward = _editReward ? _editReward : [[MCCFReward alloc] init];
    reward.supportMoney = sumMoney;
    reward.rewardDes = projectDes;
    reward.limitNum = limitCount;
    if (!_editReward) {
        reward.rewardUUID = [[NSUUID UUID] UUIDString];
    }
    
    if ([self.delegate respondsToSelector:@selector(didEndEditRewardDes: isAdd:)]) {
        BOOL isAdd = _editReward == nil;
        [self.delegate didEndEditRewardDes:reward isAdd:isAdd];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tapGesture {
    [self.editingView resignFirstResponder];
}

#pragma mark - getters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - kSureButtonHeight) style:UITableViewStylePlain];
        [_tableView registerClass:[MCProjectRewardCell class] forCellReuseIdentifier:kCellID];
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.tableFooterView = [UIView new];
        _tableView.bounces = YES;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        [_tableView addGestureRecognizer:tapGesture];
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


#pragma mark - MCProjectRewardCell
@interface MCProjectRewardCell () <UITextViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *subTextLabel;
@end

@implementation MCProjectRewardCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.textField];
    [self.contentView addSubview:self.textView];
    [self.contentView addSubview:self.subTextLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat border = 15;
    CGFloat labelH = 23;
    CGFloat titleLabelW = 75;
    self.titleLabel.frame = CGRectMake(border, border, titleLabelW, labelH);
    
    CGFloat subLabelW = 20;
    CGFloat subLabelX = width - border - subLabelW;
    self.subTextLabel.frame = CGRectMake(subLabelX, border, subLabelW, labelH);
    
    CGFloat inputViewX = CGRectGetMaxX(self.titleLabel.frame) + 5;
    CGFloat inputViewH = height - border * 2;
    CGFloat inputViewW = width - inputViewX - border - subLabelW;
    self.textField.frame = CGRectMake(inputViewX, border, inputViewW, inputViewH);
    self.textView.frame = CGRectMake(inputViewX, border, inputViewW, inputViewH);
}

- (void)updateContentWithContent:(NSDictionary *)content isTextField:(BOOL)isTextField {
    if (isTextField) {
        self.textView.hidden = YES;
        self.textField.hidden = NO;
        self.textField.attributedPlaceholder = [self attributedPlaceHolderWithPlainTxt:content[kPlaceHolder]];
        self.textField.text = content[kValue];
    } else {
        self.textView.hidden = NO;
        self.textField.hidden = YES;
        self.textView.text = content[kValue];
        self.textView.attributedPlaceholder = [self attributedPlaceHolderWithPlainTxt:content[kPlaceHolder]];
    }
    
    self.titleLabel.text = content[kTitle];
    self.subTextLabel.text = content[kSubText];
}

- (NSDictionary *)contentInfo {
    NSString *title = self.titleLabel.text;
    NSString *value = self.textField.hidden ? self.textView.text : self.textField.text;
    NSString *placeHolder = self.textField.hidden ? self.textView.attributedPlaceholder.string : self.textField.attributedPlaceholder.string;
    NSString *subTxt = self.subTextLabel.text;
    NSDictionary *content = @{
                    kTitle: title,
                    kValue: value,
              kPlaceHolder: placeHolder,
                  kSubText: subTxt
                              };
    return content;
}

- (NSAttributedString *)attributedPlaceHolderWithPlainTxt:(NSString *)plainTxt {
    NSDictionary *attribute = @{
            NSFontAttributeName: [UIFont systemFontOfSize:14],
            NSForegroundColorAttributeName: UIColorFromRGBA(52, 55, 59, 0.5)
                                };
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:plainTxt attributes:attribute];
    return attString;
}

#pragma mark - UITextField delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(rewardCell:didBeginEdit:)]) {
        [self.delegate rewardCell:self didBeginEdit:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(rewardCell:didEndEdit:)]) {
        [self.delegate rewardCell:self didEndEdit:textField];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(rewardCell:didBeginEdit:)]) {
        [self.delegate rewardCell:self didBeginEdit:textView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(rewardCell:didEndEdit:)]) {
        [self.delegate rewardCell:self didEndEdit:textView];
    }
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

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.delegate = self;
        _textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _textField;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.delegate = self;
    }
    return _textView;
}

- (UILabel *)subTextLabel {
    if (!_subTextLabel) {
        _subTextLabel = [[UILabel alloc] init];
        _subTextLabel.font = [UIFont systemFontOfSize:15];
        _subTextLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
    }
    return _subTextLabel;
}
@end
