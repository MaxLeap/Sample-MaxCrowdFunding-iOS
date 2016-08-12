//
//  MCPersonAuthVC.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/8.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCPersonAuthVC.h"
#import "UIImage+Resize.h"
#import "MCPersonAuth.h"
#import "UIScrollView+EmptyDataSet.h"

static NSString * const kTitle = @"title";
static NSString * const kValue = @"value";

static CGFloat const kSureButtonHeight = 50.0f;

@interface MCPersonAuthVC () <UITableViewDelegate, UITableViewDataSource,
 UINavigationControllerDelegate,
 UIImagePickerControllerDelegate,
 DZNEmptyDataSetSource,
 DZNEmptyDataSetDelegate
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIButton *sureButton;

@property (nonatomic, strong) UIAlertController *actionController;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@property (nonatomic, copy) NSString *emptyString;
@end

@implementation MCPersonAuthVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configDataSource];
    
    [self buildUI];
}

- (void)configDataSource {
    
    MLQuery *authQuery = [MCPersonAuth query];
    [authQuery whereKey:@"userID" equalTo:[MLUser currentUser].objectId];
    [authQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count) {
            self.emptyString = @"已经实名认证了👌";
            [self.sureButton removeFromSuperview];
            self.dataSource = nil;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } else {
            self.dataSource = [@[
                                 @{kTitle: @"身份证号:", kValue: @""},
                                 @{kTitle: @"手机号:", kValue: @""},
                                 @{kTitle: @"身份证照片:", kValue: @""},
                                 ] mutableCopy];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
    
}

- (void)buildUI {
    self.navigationItem.title = @"实名认证";
    
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.sureButton];
}

#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCPersonTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *content = self.dataSource[indexPath.row];
    [cell updateContentWithDic:content];
    cell.accessoryView = nil;
    
    if (indexPath.row == 2) {
        UIButton *accessViewBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];//[[UIButton alloc] initWithImage:ImageNamed(@"icn_user profiles_shimingrenzheng")];
        [accessViewBtn setImage:ImageNamed(@"icn_user profiles_shimingrenzheng") forState:UIControlStateNormal];
        [accessViewBtn addTarget:self action:@selector(addImageAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = accessViewBtn;
    }
    return cell;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *plainTxt = self.emptyString.length ? self.emptyString : @"";
    NSAttributedString *attributedStr = [[NSAttributedString alloc] initWithString:plainTxt attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]}];
    return attributedStr;
}


#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        UIImage *resizedImg = [image resizedImage:CGSizeMake(960, 640) interpolationQuality:kCGInterpolationDefault];
        self.image = resizedImg;
        
        [self sureButtonAction:nil];
    }
    
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - actions
- (void)addImageAction:(UIButton *)sender {
    [self presentViewController:self.actionController animated:YES completion:nil];
}

- (void)sureButtonAction:(UIButton *)sender {
    NSIndexPath *indexPath0 = [NSIndexPath indexPathForRow:0 inSection:0];
    MCPersonTextFieldCell *textFieldCell = [self.tableView cellForRowAtIndexPath:indexPath0];
    NSString *idcardNum = [textFieldCell inputText];
    
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:1 inSection:0];
    MCPersonTextFieldCell *phoneNumCell = [self.tableView cellForRowAtIndexPath:indexPath1];
    NSString *phoneNum = [phoneNumCell inputText];
    
    if (idcardNum.length <= 0 || phoneNum.length <= 0 || self.image == nil) {
        [SVProgressHUD showErrorWithStatus:@"请输入完整信息"];
        return;
    }
    
    NSData *imgData = UIImageJPEGRepresentation(self.image, 0.6);
    MLFile *file = [MLFile fileWithName:@"img.jpg" data:imgData];
    [SVProgressHUD showWithStatus:@"上传图片..."];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSString *imgURL = file.url;
            MCPersonAuth *authInfo = [[MCPersonAuth alloc] init];
            authInfo.userID = [MLUser currentUser].objectId;
            authInfo.IDCardNum = idcardNum;
            authInfo.phoneNum = phoneNum;
            authInfo.IDCardPicURL = imgURL;
            [SVProgressHUD showWithStatus:@"保存信息..."];
            [authInfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (!succeeded) {
                    [SVProgressHUD showErrorWithStatus:@"保存失败"];
                } else {
                    [SVProgressHUD showSuccessWithStatus:@"认证成功!"];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        } else {
            [SVProgressHUD showErrorWithStatus:@"图片上传失败，稍后再试"];
        }
    }];
}

#pragma mark - getters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView registerClass:[MCPersonTextFieldCell class] forCellReuseIdentifier:@"cell"];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
        _tableView.backgroundColor = UIColorFromRGBA(240, 240, 243, 1);
        _tableView.bounces = YES;
        
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _tableView;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - kSureButtonHeight, CGRectGetWidth(self.view.bounds), kSureButtonHeight)];
        [_sureButton setBackgroundImage:[UIImage imageWithColor:UIColorFromRGBA(59, 163, 255, 1)] forState:UIControlStateNormal];
        [_sureButton setTitle:@"提交" forState:UIControlStateNormal];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(sureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}

- (UIAlertController *)actionController {
    if (!_actionController) {
        _actionController = [UIAlertController alertControllerWithTitle:nil
                                                                message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"拍照"
                                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                                      if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
                                                                          self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                                          [self presentViewController:self.imagePickerController animated:YES completion:nil];
                                                                      }
                                                                  }];
        
        UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"从相册中选择"
                                                              style:UIAlertActionStyleDefault  handler:^(UIAlertAction * _Nonnull action) {
                                                                  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                                                                      self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                                      [self presentViewController:self.imagePickerController animated:YES completion:nil];
                                                                  }
                                                              }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [_actionController addAction:takePhotoAction];
        [_actionController addAction:albumAction];
        [_actionController addAction:cancelAction];
    }
    return _actionController;
}

- (UIImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
    }
    return _imagePickerController;
}

@end



#pragma mark - MCPersonTextFieldCell
@interface MCPersonTextFieldCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *inputField;
@end

@implementation MCPersonTextFieldCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.inputField];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat border = 15;
    CGFloat labelH = height - border * 2;
    CGFloat labelW = 80;
    self.titleLabel.frame = CGRectMake(border, border, labelW, labelH);
    
    CGFloat fieldX = CGRectGetMaxX(self.titleLabel.frame) + 5;
    CGFloat fieldW = width - fieldX - border;
    self.inputField.frame = CGRectMake(fieldX, border, fieldW, labelH);
}

- (void)updateContentWithDic:(NSDictionary *)dic {
    self.titleLabel.text = dic[kTitle];
    self.inputField.text = dic[kValue];
}

- (NSString *)inputText {
    return self.inputField.text;
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

- (UITextField *)inputField {
    if (!_inputField) {
        _inputField = [[UITextField alloc] init];
    }
    return _inputField;
}
@end
