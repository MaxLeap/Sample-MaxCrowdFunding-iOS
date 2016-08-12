//
//  MCPostCFDetailVC.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/6.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCPostCFDetailVC.h"
#import "MCProductDesViewController.h"
#import "MCProjectRewardVC.h"
#import "MCCrowdFunding.h"
#import "MCCFReward.h"
#import "MCCFTrends.h"
#import "LGAlertView.h"

static NSInteger const kSureButtonHeight = 50.0f;
static NSString * const kTitle = @"titleKey";
static NSString * const kValue = @"valueKey";

static NSString * const kTextFieldCell = @"textFieldCell";
static NSString * const kDateCell = @"dateCell";
static NSString * const kLabelCell = @"labelCell";

@interface MCPostCFDetailVC () <UITableViewDelegate,
 UITableViewDataSource,
 MCProductDesProtocol,
 MCPostDetailTextFieldCellDelegate,
 MCPostDetailDateCellDelegate,
 MCProjectAddRewardDelegate
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UIButton *sureButton;
@property (nonatomic, strong) UIAlertController *alertWithText;
@property (nonatomic, strong) UITextField *editingField;
// 众筹 meta
@property (nonatomic, strong) NSDictionary *productDesInfo;
@property (nonatomic, strong) NSMutableArray *productPhotos;
@property (nonatomic, assign) NSInteger targetCountMoney;
@property (nonatomic, assign) NSInteger totalDay;
@property (nonatomic, copy) NSString *freightInfo;
@property (nonatomic, copy) NSString *deliveryTimeInfo;
@property (nonatomic, strong) NSArray *projectRewards;
//@property (nonatomic, strong) NSDate *deliveryTime;
@end

@implementation MCPostCFDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configDataSource];
    
    [self buildUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)configDataSource {
    NSArray *dataArray;
    if (self.cfType == CrowdFundingTypeDream) {
        dataArray = @[
              @{kTitle: @"目标金额:", kValue: @(-1)},
              @{kTitle: @"截止日期:", kValue: @(3)},
              @{kTitle: @"项目描述:", kValue: @""}
                      ];
    } else {
        dataArray = @[
              @{kTitle: @"目标金额:", kValue: @(-1)},
              @{kTitle: @"截止日期:", kValue: @(3)},
              @{kTitle: @"项目描述:", kValue: @""},
              @{kTitle: @"项目回报:", kValue: @""},
              @{kTitle: @"邮费:", kValue: @""},
              @{kTitle: @"发货时间:", kValue: @""}
                      ];
    }
    self.dataSource = [dataArray mutableCopy];
}

- (void)buildUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"发起众筹";
    
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.sureButton];
}

#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 60.0f;
    } else if (indexPath.row == 1) {
        return 90.0f;
    } else {
        return 55.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dataInfo = self.dataSource[indexPath.row];
    if (indexPath.row == 0) {
        MCPostDetailTextFiledCell *textFieldCell = [tableView dequeueReusableCellWithIdentifier:kTextFieldCell forIndexPath:indexPath];
        [textFieldCell updateContentWithDic:dataInfo];
        textFieldCell.delegate = self;
        return textFieldCell;
    } else if (indexPath.row == 1) {
        MCPostDetailDateCell *dateCell = [tableView dequeueReusableCellWithIdentifier:kDateCell forIndexPath:indexPath];
        [dateCell updateContentWithDic:dataInfo];
        dateCell.delegate = self;
        return dateCell;
    } else {
        MCPostDetailLabelCell *labelCell = [tableView dequeueReusableCellWithIdentifier:kLabelCell forIndexPath:indexPath];
        [labelCell updateContentWithDic:dataInfo];
        return labelCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (![MCUtils hasLogin]) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showErrorWithStatus:@"请先登录"];
        return;
    }
    
    if (indexPath.row <= 1) {
        return;
    } else if (indexPath.row == 2) {
        [self toProjectDesViewController];
    } else if (indexPath.row == 3) {
        [self toAddProjectRewardViewController];
    } else if (indexPath.row == 4) {
        [self showPriceOfMail];
    } else if (indexPath.row == 5) {
        [self showSendProductTime];
    }
}

#pragma mark - custom protocol
- (void)didDescriptProductWithDesInfo:(NSDictionary *)desInfo {
    _productDesInfo = desInfo;
    
    NSDictionary *productDes = @{kTitle: @"项目描述:", kValue: desInfo[kProductName]};
    [self.dataSource replaceObjectAtIndex:2 withObject:productDes];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)dateCellDidChangedDays:(NSInteger)days {
    self.totalDay = days;
    
    NSDictionary *dateInfo = @{kTitle: @"截止日期:", kValue: @(days)};
    [self.dataSource replaceObjectAtIndex:1 withObject:dateInfo];
    
    [self.editingField resignFirstResponder];
}

- (void)textFieldCellDidBeginEdit:(UITextField *)editingView {
    self.editingField = editingView;
}

- (void)textFieldCellDidEndEdit:(UITextField *)endEditView {
    [self.editingField resignFirstResponder];
    
    NSString *text = [endEditView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.targetCountMoney = [text integerValue];
    
    NSDictionary *targetInfo = @{kTitle: @"目标金额:", kValue: @(self.targetCountMoney)};
    [self.dataSource replaceObjectAtIndex:0 withObject:targetInfo];
}

- (void)addRewardVCDidEndAddReward:(NSArray *)rewards {
    self.projectRewards = rewards;
    
    if (self.cfType == CrowdFundingTypeProduct && rewards.count) {
        NSString *rewardDes = [NSString stringWithFormat:@"%lu 个项目回报", (unsigned long)rewards.count];
        NSDictionary *rewardInfo = @{kTitle: @"项目回报:", kValue: rewardDes};
        
        [self.dataSource replaceObjectAtIndex:3 withObject:rewardInfo];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

#pragma mark - actions
- (void)toProjectDesViewController {
    MCProductDesViewController *productDesVC = [[MCProductDesViewController alloc] init];
    productDesVC.delegate = self;
    productDesVC.editProductDesInfo = _productDesInfo;
    [self.navigationController pushViewController:productDesVC animated:YES];
}

- (void)toAddProjectRewardViewController {
    MCProjectRewardVC *projectRewardVC = [[MCProjectRewardVC alloc] init];
    projectRewardVC.delegate = self;
    projectRewardVC.editRewards = self.projectRewards;
    [self.navigationController pushViewController:projectRewardVC animated:YES];
}

- (void)showPriceOfMail {
    [self showAlertWithTextInputType:@"邮费:" message:@"请输入邮费信息"];
}

- (void)showSendProductTime {
//    [self showAlertWithTextInputType:@"发货时间:" message:@"请输入发货时间"];
    
    UIDatePicker *datePicker = [UIDatePicker new];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.minimumDate = [NSDate date];
    datePicker.frame = CGRectMake(0.f, 0.f, self.view.frame.size.width, 110.f);
    
    [[[LGAlertView alloc] initWithViewAndTitle:@"选择发货时间"
                                       message:@""
                                         style:LGAlertViewStyleActionSheet
                                          view:datePicker
                                  buttonTitles:@[@"Done"]
                             cancelButtonTitle:@"Cancel"
                        destructiveButtonTitle:nil
                                 actionHandler:^(LGAlertView *alertView, NSString *title, NSUInteger index) {
                                     NSLog(@"actionHandler, %@, %lu", datePicker.date, (long unsigned)index);
                                     NSDate *date = datePicker.date;
                                     NSString *dateString = [date descriptionWithLocale:[NSLocale currentLocale]];
                                     if (dateString.length >= 10) {
                                         self.deliveryTimeInfo = [dateString substringToIndex:10];
                                     }
                                     NSDictionary *deliverTimeInfo = @{kTitle: @"发货时间:", kValue: self.deliveryTimeInfo};
                                     [self.dataSource replaceObjectAtIndex:5 withObject:deliverTimeInfo];
                                     
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [self.tableView reloadData];
                                     });
                                 }
                                 cancelHandler:^(LGAlertView *alertView) {
                                     NSLog(@"cancelHandler");
                                 }
                            destructiveHandler:^(LGAlertView *alertView) {
                                NSLog(@"destructiveHandler");
                            }] showAnimated:YES completionHandler:nil];
    
}

- (void)sureButtonAction:(UIButton *)sender {
    BOOL shouldPost = [self checkCrowdFundingParams];
    if (!shouldPost) {
        return;
    }
    
    if (self.totalDay < 3) {
        self.totalDay = 3;
    }
    
    NSString *productName = _productDesInfo[kProductName];
    NSString *productDes = _productDesInfo[kProductDes];
    NSArray *imgs = _productDesInfo[kProductImgs];
    
    self.productPhotos = [[NSMutableArray alloc] init];
    [SVProgressHUD showWithStatus:@"上传图片..."];
    [self uploadImages:imgs complete:^{
        if (self.productPhotos.count == imgs.count) {
            MCCrowdFunding *crowFunding = [[MCCrowdFunding alloc] init];
            crowFunding.publisher = [MLUser currentUser];
            crowFunding.publisherID = [MLUser currentUser].objectId;
            crowFunding.isDreamCF = self.cfType == CrowdFundingTypeDream;
            crowFunding.targetNum = self.targetCountMoney;
            crowFunding.completeNum = 0;
            crowFunding.endDate = [NSDate dateWithTimeIntervalSinceNow:self.totalDay * 24 * 3600];
            crowFunding.projectName = productName;
            crowFunding.projectDes = productDes;
            crowFunding.photos = self.productPhotos;
            crowFunding.supportUserCount = 0;
            crowFunding.attentionCount = 0;
            // 产品众筹的属性
            crowFunding.freightInfo = self.freightInfo;
            crowFunding.deliveryTimeInfo = self.deliveryTimeInfo;

            [SVProgressHUD showWithStatus:@"发送中..."];
            [crowFunding saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showSuccessWithStatus:@"众筹发送成功"];
                    });
                    
                    NSString *cfID = crowFunding.objectId;
                    [self saveRewardInfoForCrowdFunding:cfID];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showSuccessWithStatus:@"众筹发送失败"];
                    });
                }
            }];
        } else {
            NSInteger failedCount = imgs.count - self.productPhotos.count;
            if (failedCount == imgs.count) {
                [SVProgressHUD showErrorWithStatus:@"图片全部上传失败, 众筹不会发送, check your Network"];
                return ;
            } else {
                NSString *alertContent = [NSString stringWithFormat:@"有%ld张图片上传失败了，是否继续发送众筹?", (long)failedCount];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:alertContent preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                    });
                }];
                [alertController addAction:cancelAction];
                
                UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    MCCrowdFunding *crowFunding = [[MCCrowdFunding alloc] init];
                    crowFunding.publisher = [MLUser currentUser];
                    crowFunding.publisherID = [MLUser currentUser].objectId;
                    crowFunding.isDreamCF = self.cfType == CrowdFundingTypeDream;
                    crowFunding.targetNum = self.targetCountMoney;
                    crowFunding.completeNum = 0;
                    crowFunding.endDate = [NSDate dateWithTimeIntervalSinceNow:self.totalDay * 24 * 3600];
                    crowFunding.projectName = productName;
                    crowFunding.projectDes = productDes;
                    crowFunding.photos = self.productPhotos;
                    crowFunding.supportUserCount = 0;
                    crowFunding.attentionCount = 0;
                    // 产品众筹的属性
                    crowFunding.freightInfo = self.freightInfo;
                    crowFunding.deliveryTimeInfo = self.deliveryTimeInfo;
                    
                    [SVProgressHUD showWithStatus:@"发送中..."];
                    [crowFunding saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (succeeded) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [SVProgressHUD showSuccessWithStatus:@"众筹发送成功"];
                            });
                            
                            NSString *cfID = crowFunding.objectId;
                            [self saveRewardInfoForCrowdFunding:cfID];
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [SVProgressHUD showSuccessWithStatus:@"众筹发送失败"];
                            });
                        }
                    }];
                }];
                [alertController addAction:yesAction];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self presentViewController:alertController animated:yesAction completion:nil];
                });
            }
        }
    }];
}

- (BOOL)checkCrowdFundingParams {
    if (![MCUtils hasLogin]) {
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showErrorWithStatus:@"请先登录"];
        return NO;
    }
    
    if (self.targetCountMoney <= 0) {
        [SVProgressHUD showErrorWithStatus:@"目标金额不能为0"];
        return NO;
    }
    
    if (!_productDesInfo) {
        [SVProgressHUD showErrorWithStatus:@"请先填写项目描述"];
        return NO;
    }
    
    if (self.cfType == CrowdFundingTypeProduct && self.projectRewards.count <= 0) {
        [SVProgressHUD showErrorWithStatus:@"请添加项目回报"];
        return NO;
    }
    
    if (self.cfType == CrowdFundingTypeProduct && self.freightInfo.length <= 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入邮费信息"];
        return NO;
    }
    
    if (self.cfType == CrowdFundingTypeProduct && self.deliveryTimeInfo.length <= 0) {
        [SVProgressHUD showErrorWithStatus:@"请输入发货时间"];
        return NO;
    }
    
    return YES;
}

- (void)saveRewardInfoForCrowdFunding:(NSString *)cfID {
    if (self.cfType == CrowdFundingTypeProduct && self.projectRewards.count) {
        for (MCCFReward *reward in self.projectRewards) {
            reward.belongToCFID = cfID;
            [reward saveInBackgroundWithBlock:nil];
        }
    }
    
    NSString *trendContent = [NSString stringWithFormat:@"%@ 发起了目标金额为%ld的众筹", [MLUser currentUser].username, _targetCountMoney];
    MCCFTrends *firstTrend = [[MCCFTrends alloc] init];
    firstTrend.belongToCFID = cfID;
    firstTrend.trendContent = trendContent;
    [firstTrend saveInBackgroundWithBlock:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.navigationController popViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidPostNewCF object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)uploadImages:(NSArray *)images complete:(void(^)())complete {
    NSMutableArray *imagesToUpload = [images mutableCopy];
    if (imagesToUpload.count > 0) {
        UIImage *firstImage = imagesToUpload.firstObject;
        [imagesToUpload removeObject:firstImage];
        [self uploadImage:firstImage completeHandler:^(NSString *imgURL, NSError *error) {
            if (imgURL.length) {
                [self.productPhotos addObject:imgURL];
            }
            
            [self uploadImages:imagesToUpload complete:complete];
        }];
    } else {
        if (complete) {
            complete();
        }
    }
}

- (void)uploadImage:(UIImage *)image completeHandler:(void(^)(NSString *imgURL, NSError *error))completeHandler {
    NSData *imgData = UIImageJPEGRepresentation(image, 0.6);
    MLFile *file = [MLFile fileWithName:@"img.jpg" data:imgData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSString *imgURL = file.url;
            if (completeHandler) {
                completeHandler(imgURL, nil);
            }
        } else {
            if (completeHandler) {
                completeHandler(nil, error);
            }
        }
    }];
}

#pragma mark - alert controllers
- (void)showAlertWithTextInputType:(NSString *)type message:(NSString *)message {
    
    [self presentViewController:[self alertWithTextType:type message:message]
                       animated:YES
                     completion:nil];
}

- (UIAlertController *)alertWithTextType:(NSString *)type message:(NSString *)message {
    
    _alertWithText = [UIAlertController alertControllerWithTitle:type
                                                         message:message
                                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
            handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"User choose OK");
                NSString *textInput = [self accessAlertTextField];
                NSLog(@"User Input was %@ for %@", textInput, type);
                if (textInput.length) {
                    if ([type isEqualToString:@"邮费:"]) {
                        self.freightInfo = textInput;
                        NSDictionary *mailCostInfo = @{kTitle: type, kValue: textInput};
                        [self.dataSource replaceObjectAtIndex:4 withObject:mailCostInfo];
                    } else {
//                        self.deliveryTimeInfo = textInput;
//                        NSDictionary *deliverTimeInfo = @{kTitle: type, kValue: textInput};
//                        [self.dataSource replaceObjectAtIndex:5 withObject:deliverTimeInfo];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }
           }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Cancel"
                                                      style:UIAlertActionStyleDestructive
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        NSLog(@"User choose CANCEL");
                                                    }];
    
    [_alertWithText addAction:action1];
    [_alertWithText addAction:action2];
    
    [_alertWithText addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        NSString *placeHolder = [type isEqualToString:@"发货时间:"] ? @"eg. 24小时内" : @"eg. 包邮";
        textField.placeholder = placeHolder;
    }];
    return _alertWithText;
}

- (NSString *)accessAlertTextField {
    
    return [self.alertWithText.textFields lastObject].text;
}

#pragma mark - getters

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - kSureButtonHeight) style:UITableViewStylePlain];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        [_tableView registerClass:[MCPostDetailTextFiledCell class] forCellReuseIdentifier:kTextFieldCell];
        [_tableView registerClass:[MCPostDetailDateCell class] forCellReuseIdentifier:kDateCell];
        [_tableView registerClass:[MCPostDetailLabelCell class] forCellReuseIdentifier:kLabelCell];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
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


#pragma mark - MCPostDetailTextFiledCell
@interface MCPostDetailTextFiledCell () <UITextFieldDelegate>
@property (nonatomic, strong) UILabel *titlaLabel;
@property (nonatomic, strong) UITextField *sumTextField;
@property (nonatomic, strong) UILabel *currencyLabel;
@end

@implementation MCPostDetailTextFiledCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    [self.contentView addSubview:self.titlaLabel];
    [self.contentView addSubview:self.sumTextField];
    [self.contentView addSubview:self.currencyLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat borderX = 15;
    CGFloat labelH = 21;
    CGFloat startY = (height - labelH) / 2;
    CGFloat titleLabelW = 75;
    self.titlaLabel.frame = CGRectMake(borderX, startY, titleLabelW, labelH);
    
    CGFloat currencyW = 20;
    CGFloat currencyX = width - borderX - currencyW;
    self.currencyLabel.frame = CGRectMake(currencyX, startY, currencyW, labelH);
    
    CGFloat textFieldX = CGRectGetMaxX(self.titlaLabel.frame) + 3;
    CGFloat textFieldW = width - textFieldX - borderX - currencyW;
    self.sumTextField.frame = CGRectMake(textFieldX, startY, textFieldW, labelH);
}

- (void)updateContentWithDic:(NSDictionary *)dic {
    self.titlaLabel.text = dic[kTitle];
    NSInteger sum = [dic[kValue] integerValue];
    if (sum > 0) {
        self.sumTextField.text = [NSString stringWithFormat:@"%ld", (long)sum];
    }
}

#pragma mark - UITextField delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldCellDidBeginEdit:)]) {
        [self.delegate textFieldCellDidBeginEdit:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldCellDidEndEdit:)]) {
        [self.delegate textFieldCellDidEndEdit:textField];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - getters
- (UILabel *)titlaLabel {
    if (!_titlaLabel) {
        _titlaLabel = [[UILabel alloc] init];
        _titlaLabel.font = [UIFont systemFontOfSize:15];
        _titlaLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
    }
    return _titlaLabel;
}

- (UITextField *)sumTextField {
    if (!_sumTextField) {
        _sumTextField = [[UITextField alloc] init];
        _sumTextField.placeholder = @"请输入金额";
        _sumTextField.delegate = self;
        _sumTextField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _sumTextField;
}

- (UILabel *)currencyLabel {
    if (!_currencyLabel) {
        _currencyLabel = [[UILabel alloc] init];
        _currencyLabel.text = @"元";
        _currencyLabel.font = [UIFont systemFontOfSize:15];
        _currencyLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
    }
    return _currencyLabel;
}
@end


#pragma mark - MCPostDetailDateCell
@interface MCPostDetailDateCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *dateDesLabel;
@property (nonatomic, strong) UILabel *minDayLabel;
@property (nonatomic, strong) UILabel *maxDayLabel;
@property (nonatomic, strong) UISlider *slider;
@end

@implementation MCPostDetailDateCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.dateDesLabel];
    [self.contentView addSubview:self.minDayLabel];
    [self.contentView addSubview:self.slider];
    [self.contentView addSubview:self.maxDayLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat border = 15;
    CGFloat contentH = 23;
    CGFloat titleW = 75;
    self.titleLabel.frame = CGRectMake(border, border, titleW, contentH);
    
    CGFloat dateDesX = CGRectGetMaxX(self.titleLabel.frame) + 3;
    CGFloat dateDexW = width - dateDesX - border;
    self.dateDesLabel.frame = CGRectMake(dateDesX, border, dateDexW, contentH);
    
    CGFloat dayLabelW = 30;
    CGFloat secondLineY = height - border - contentH;
    self.minDayLabel.frame = CGRectMake(border, secondLineY, dayLabelW, contentH);
    
    CGFloat maxDayX = width - border - dayLabelW;
    self.maxDayLabel.frame = CGRectMake(maxDayX, secondLineY, dayLabelW, contentH);
    
    CGFloat sliderX = CGRectGetMaxX(self.minDayLabel.frame) + 8;
    CGFloat sliderW = width - sliderX - border - dayLabelW - 8;
    self.slider.frame = CGRectMake(sliderX, secondLineY, sliderW, contentH);
}

- (void)updateContentWithDic:(NSDictionary *)dic {
    self.titleLabel.text = dic[kTitle];
    NSInteger dayCount = [dic[kValue] integerValue];
    self.slider.value = dayCount;
    
    NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:dayCount * 24 * 3600];
    NSString *dateString = [endDate description];
    NSArray *components = [dateString componentsSeparatedByString:@":"];
    NSString *str;
    if (components.count > 1) {
        str = [NSString stringWithFormat:@"%@:%@", components.firstObject, components[1]];
    }
    NSString *dateDes = [NSString stringWithFormat:@"即日起至%@ 共%ld天", str, (long)dayCount];
    
    self.dateDesLabel.attributedText = [self attDateDesStringFromDateDes:dateDes];
}

#pragma mark - actions
- (void)sliderValueChanged:(UISlider *)slider {
    NSInteger days = slider.value;
    
    NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:days * 24 * 3600];
    NSString *dateString = [endDate description];
    NSArray *components = [dateString componentsSeparatedByString:@":"];
    NSString *str;
    if (components.count > 1) {
        str = [NSString stringWithFormat:@"%@:%@", components.firstObject, components[1]];
    }
    NSString *dateDes = [NSString stringWithFormat:@"即日起至%@ 共%ld天", str, (long)days];
    NSAttributedString *attDateDes = [self attDateDesStringFromDateDes:dateDes];
    self.dateDesLabel.attributedText = attDateDes;
    
    if ([self.delegate respondsToSelector:@selector(dateCellDidChangedDays:)]) {
        [self.delegate dateCellDidChangedDays:days];
    }
}

- (NSAttributedString *)attDateDesStringFromDateDes:(NSString *)dateDes {
    NSString *startTxt = @"共";
    NSString *endTxt = @"天";
    NSRange startRange = [dateDes rangeOfString:startTxt];
    NSRange endRange = [dateDes rangeOfString:endTxt];
    NSRange attRange = NSMakeRange(startRange.location + 1, endRange.location - startRange.location - 1);
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:dateDes];
    [attString setAttributes:@{
               NSForegroundColorAttributeName: UIColorFromRGBA(59, 163, 255, 1),
                          NSFontAttributeName: [UIFont systemFontOfSize:16]
                               } range:attRange];
    
    return attString;
}

#pragma mark - getters
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [self normalLabel];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
    }
    return _titleLabel;
}

- (UILabel *)dateDesLabel {
    if (!_dateDesLabel) {
        _dateDesLabel = [self normalLabel];
        _dateDesLabel.font = [UIFont systemFontOfSize:14];
        _dateDesLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _dateDesLabel;
}

- (UILabel *)minDayLabel {
    if (!_minDayLabel) {
        _minDayLabel = [self normalLabel];
        _minDayLabel.font = [UIFont systemFontOfSize:12];
        _minDayLabel.textColor = UIColorFromRGBA(52, 55, 59, 0.3);
        _minDayLabel.text = @"3天";
    }
    return _minDayLabel;
}

- (UILabel *)maxDayLabel {
    if (!_maxDayLabel) {
        _maxDayLabel = [self normalLabel];
        _maxDayLabel.font = [UIFont systemFontOfSize:12];
        _maxDayLabel.textColor = UIColorFromRGBA(52, 55, 59, 0.3);
        _maxDayLabel.text = @"30天";
    }
    return _maxDayLabel;
}

- (UISlider *)slider {
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        _slider.minimumValue = 3;
        _slider.maximumValue = 30;
        _slider.minimumTrackTintColor = UIColorFromRGBA(0, 197, 167, 1);
        
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

- (UILabel *)normalLabel {
    UILabel *label = [[UILabel alloc] init];
    return label;
}

@end


#pragma mark - MCPostDetailLabelCell
@interface MCPostDetailLabelCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *arrowImgView;
@end

@implementation MCPostDetailLabelCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.arrowImgView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat border = 15;
    CGFloat labelH = 23;
    CGFloat startY = (height - labelH) / 2;
    CGFloat titleLabelW = 75;
    self.titleLabel.frame = CGRectMake(border, border, titleLabelW, labelH);
    
    CGFloat imgW = 25;
    CGFloat imgX = width - border - imgW;
    self.arrowImgView.frame = CGRectMake(imgX, startY, imgW, imgW);
    
    CGFloat contentLabelX = CGRectGetMaxX(self.titleLabel.frame) + 5;
    CGFloat contentLabelW = width - contentLabelX - border - imgW - 5;
    self.contentLabel.frame = CGRectMake(contentLabelX, startY, contentLabelW, labelH);
}

- (void)updateContentWithDic:(NSDictionary *)dic {
    self.titleLabel.text = dic[kTitle];
    self.contentLabel.text = dic[kValue];
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

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.textColor = UIColorFromRGBA(52, 55, 59, 1);
    }
    return _contentLabel;
}

- (UIImageView *)arrowImgView {
    if (!_arrowImgView) {
        _arrowImgView = [[UIImageView alloc] init];
        _arrowImgView.image = ImageNamed(@"icn_more");
        _arrowImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _arrowImgView;
}
@end