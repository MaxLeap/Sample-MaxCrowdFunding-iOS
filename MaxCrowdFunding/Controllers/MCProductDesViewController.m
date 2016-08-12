//
//  MCProductDesViewController.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/6.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCProductDesViewController.h"
#import "UITextView+Placeholder.h"
#import "UIImage+Resize.h"

static CGFloat kSureButtonHeight = 50.0f;

static NSString * const kTitle = @"titleKey";
static NSString * const kValue = @"valueKey";
static NSString * const kPlaceHolder = @"placeHolderKey";

static NSString * const kTableCell = @"tableCell";
static NSString * const kCollectionCell = @"collectionCell";

NSString * const kProductName = @"productName";
NSString * const kProductDes = @"productDes";
NSString * const kProductImgs = @"ProductImgs";

@interface MCProductDesViewController () <UITableViewDelegate,
 UITableViewDataSource,
 UICollectionViewDelegate,
 UICollectionViewDataSource,
 UICollectionViewDelegateFlowLayout,
 UINavigationControllerDelegate,
 UIImagePickerControllerDelegate,
 MCProductCellProtocol
>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tableDataSource;
@property (nonatomic, strong) UIButton *sureButton;
// table footer
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *imgDataSource;

@property (nonatomic, strong) UIAlertController *actionController;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UITextView *editingTextView;
@end

@implementation MCProductDesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configDataSource];
    
    [self buildUI];
}

- (void)configDataSource {
    NSString *productName = _editProductDesInfo ? _editProductDesInfo[kProductName] : @"";
    NSString *productDes = _editProductDesInfo ? _editProductDesInfo[kProductDes] : @"";
    NSArray *images = _editProductDesInfo ? _editProductDesInfo[kProductImgs] : @[];
    
    self.tableDataSource = [@[
            @{kTitle: @"项目名称:", kValue:productName, kPlaceHolder: @"请输入项目名称"},
            @{kTitle: @"项目简介:", kValue:productDes, kPlaceHolder: @"请输入项目简介，不少于30字"}
                              ] mutableCopy];
    
    self.imgDataSource = [@[ImageNamed(@"icn_faqizhongchou_add pic")] mutableCopy];
    if (images.count) {
        [self.imgDataSource addObjectsFromArray:images];
    }
}

- (void)buildUI {
    self.navigationItem.title = @"项目描述";
    
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.sureButton];
}

#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableDataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 0 ? 60 : 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCProductCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableCell forIndexPath:indexPath];
    NSDictionary *dic = self.tableDataSource[indexPath.row];
    [cell updateContentWithDic:dic isTitleCell:indexPath.row == 0];
    cell.delegate = self;
    return cell;
}

#pragma mark - UICollectionView delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imgDataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MCCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionCell forIndexPath:indexPath];
    UIImage *image = self.imgDataSource[indexPath.row];
    [cell updateContentWithImage:image forIndexPath:indexPath];
    
    MCProductDesViewController *__weak wself = self;
    cell.xButtonBlock = ^(NSIndexPath *cellIndexPath) {
        [wself.imgDataSource removeObjectAtIndex:cellIndexPath.row];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wself.collectionView reloadData];
        });
    };
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(CGRectGetWidth(self.view.bounds), 50);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reuseView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"collectFooter" forIndexPath:indexPath];
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 50)];
    tipLabel.text = @"最少一张，最多4张";
    tipLabel.font = [UIFont systemFontOfSize:12];
    tipLabel.textColor = UIColorFromRGBA(52, 55, 59, 0.5);
    [reuseView addSubview:tipLabel];
    return reuseView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self.editingTextView resignFirstResponder];
    
    if (indexPath.row == 0) {
        [self addPhotoAction];
    }
}

#pragma mark - 
- (void)productCell:(MCProductCell *)cell didStartEdit:(UITextView *)textView {
    self.editingTextView = textView;
}

- (void)productCell:(MCProductCell *)cell didEndEdit:(UITextView *)textView {
    NSDictionary *content = [cell contentInfo];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath) {
        [self.tableDataSource replaceObjectAtIndex:indexPath.row withObject:content];
    }
    
    [textView resignFirstResponder];
}

#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        UIImage *resizedImg = [image resizedImage:CGSizeMake(960, 640) interpolationQuality:kCGInterpolationDefault];
        [self.imgDataSource addObject:resizedImg];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }
    
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - actions
- (void)sureButtonAction:(UIButton *)sender {
    [self.editingTextView resignFirstResponder];
    
    NSDictionary *productNameInfo = self.tableDataSource.firstObject;
    NSString *productName = productNameInfo[kValue];
    NSDictionary *productDesInfo = self.tableDataSource.lastObject;
    NSString *productDes = productDesInfo[kValue];
    
    if (productName.length <= 0) {
       // 名称为空
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showErrorWithStatus:@"项目名称为空"];
        return;
    }
    
    if (productDes.length <= 30) {
        // 描述不够
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showErrorWithStatus:@"项目描述不能少于30字"];
        return;
    }
    
    if (self.imgDataSource.count <= 1) {
        // 没有添加图片
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showErrorWithStatus:@"没有添加图片"];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(didDescriptProductWithDesInfo:)]) {
        NSArray *productImgs = [self.imgDataSource subarrayWithRange:NSMakeRange(1, self.imgDataSource.count - 1)];
        NSDictionary *desInfo = @{
                kProductName: productName,
                 kProductDes: productDes,
                kProductImgs: productImgs
                                  };
        [self.delegate didDescriptProductWithDesInfo:desInfo];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addPhotoAction {
    if (self.imgDataSource.count >= 5) {
        return;
    }
    
    [self presentViewController:self.actionController animated:YES completion:nil];
}


#pragma mark - getters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - kSureButtonHeight) style:UITableViewStylePlain];
        [_tableView registerClass:[MCProductCell class] forCellReuseIdentifier:kTableCell];
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.bounces = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.tableFooterView = self.collectionView;
    }
    return _tableView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 5;
        flowLayout.minimumInteritemSpacing = 5;
        CGFloat itemW = (CGRectGetWidth(self.view.bounds) - 15 * 2 - 10 * 2) / 3;
        flowLayout.itemSize = CGSizeMake(itemW, itemW);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), (63 / 2 + 218 + 60)) collectionViewLayout:flowLayout];
        [_collectionView registerClass:[MCCollectionCell class] forCellWithReuseIdentifier:kCollectionCell];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"collectFooter"];
        _collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _collectionView.contentInset = UIEdgeInsetsMake(15, 15, 15, 15);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.bounces = NO;
    }
    return _collectionView;
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


@interface MCProductCell () <UITextViewDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *textView;
@end

@implementation MCProductCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.textView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    CGFloat border = 15;
    CGFloat labelH = 23;
    CGFloat labelW = 75;
    self.titleLabel.frame = CGRectMake(border, border, labelW, labelH);
    
    CGFloat textViewH = height - border * 2;
    CGFloat textViewX = CGRectGetMaxX(self.titleLabel.frame) + 6;
    CGFloat textViewW = width - textViewX - border;
    self.textView.frame = CGRectMake(textViewX, border - 5, textViewW, textViewH);
}

- (void)updateContentWithDic:(NSDictionary *)dic isTitleCell:(BOOL)isTitle {
    self.titleLabel.text = dic[kTitle];
    self.textView.text = dic[kValue];
    self.textView.placeholder = dic[kPlaceHolder];
    
    self.textView.scrollEnabled = !isTitle;
}

- (NSDictionary *)contentInfo {
    NSDictionary *content = @{
            kTitle: self.titleLabel.text,
            kValue: self.textView.text,
            kPlaceHolder: self.textView.placeholder
                              };
    return content;
}

#pragma mark - UITextView delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(productCell:didStartEdit:)]) {
        [self.delegate productCell:self didStartEdit:textView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(productCell:didEndEdit:)]) {
        [self.delegate productCell:self didEndEdit:textView];
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

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.delegate = self;
        _textView.font = [UIFont systemFontOfSize:15];
        _textView.textColor = UIColorFromRGBA(52, 55, 59, 1);
    }
    return _textView;
}
@end


@interface MCCollectionCell ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *xButton;
@property (nonatomic, strong) NSIndexPath *indexPathInCollectionView;
@end

@implementation MCCollectionCell
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.contentView addSubview:self.imageView];
    
    self.xButton = [[UIButton alloc] init];
    [self.xButton setImage:ImageNamed(@"icn_faqizhongchou_close") forState:UIControlStateNormal];
    [self.xButton addTarget:self action:@selector(xButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.xButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    
    CGFloat xBtnW = 25;
    self.xButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - xBtnW, 0, xBtnW, xBtnW);
}

- (void)updateContentWithImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath {
    _indexPathInCollectionView = indexPath;
    self.imageView.image = image;
    if (indexPath.row == 0) {
        self.xButton.hidden = YES;
    } else {
        self.xButton.hidden = NO;
    }
}

- (void)xButtonAction:(UIButton *)sender {
    if (self.xButtonBlock) {
        self.xButtonBlock(_indexPathInCollectionView);
    }
}
@end