//
//  MCPublisherTrendVC.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/14.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCPublisherTrendVC.h"
#import "MCProductDesViewController.h"
#import "UIImage+Resize.h"
#import "UITextView+Placeholder.h"
#import "MCCFTrends.h"
#import "MCCrowdFunding.h"

static CGFloat kSureButtonHeight = 50.0f;

static NSString * const kCollectionCell = @"collectionCell";

@interface MCPublisherTrendVC () <UICollectionViewDelegate,
 UICollectionViewDataSource,
 UIImagePickerControllerDelegate,
 UINavigationControllerDelegate
>
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *imgDataSource;
@property (nonatomic, strong) UIView *editingTextView;
@property (nonatomic, strong) UIButton *sureButton;
@property (nonatomic, strong) UIAlertController *actionController;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@property (nonatomic, strong) NSMutableArray *trendImages;
@end

@implementation MCPublisherTrendVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imgDataSource = [@[ImageNamed(@"icn_faqizhongchou_add pic")] mutableCopy];
    
    [self buildUI];
}

- (void)buildUI {
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.title = @"项目动态";
    
    [self.view addSubview:self.textView];
    
    [self.view addSubview:self.collectionView];
    
    [self.view addSubview:self.sureButton];
}


#pragma mark - UICollectionView delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imgDataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MCCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionCell forIndexPath:indexPath];
    UIImage *image = self.imgDataSource[indexPath.row];
    [cell updateContentWithImage:image forIndexPath:indexPath];
    
    MCPublisherTrendVC *__weak wself = self;
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
    [self.textView resignFirstResponder];
    
    if (indexPath.row == 0) {
        [self addPhotoAction];
    }
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
- (void)addPhotoAction {
    if (self.imgDataSource.count >= 5) {
        return;
    }
    
    [self presentViewController:self.actionController animated:YES completion:nil];
}

- (void)sureButtonAction:(UIButton *)sender {
    NSString *content = self.textView.text;
    if (content.length < 30) {
        [SVProgressHUD showErrorWithStatus:@"不能少于30字"];
        return;
    }
    
    if (self.imgDataSource.count <= 1) {
        // 没有添加图片
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showErrorWithStatus:@"没有添加图片"];
        return;
    }
    
    NSArray *images = [[self.imgDataSource subarrayWithRange:NSMakeRange(1, self.imgDataSource.count - 1)] mutableCopy];
    self.trendImages = [[NSMutableArray alloc] init];
    
    // upload image
    [SVProgressHUD showWithStatus:@"上传图片..."];
    [self uploadImages:images complete:^{
        [SVProgressHUD showSuccessWithStatus:@"上传成功!"];
        MCCFTrends *trend = [[MCCFTrends alloc] init];
        trend.belongToCFID = self.crowdFunding.objectId;
        trend.trendContent = content;
        trend.photos = self.trendImages;
        
        [SVProgressHUD showWithStatus:@"保存项目动态..."];
        [trend saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                if (self.trendImages.count == images.count) {
                    [SVProgressHUD showSuccessWithStatus:@"动态发送成功"];
                } else {
                    [SVProgressHUD showSuccessWithStatus:@"动态发送成功，但是有图片上传失败"];
                }
                
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [SVProgressHUD showErrorWithStatus:@"项目动态发送失败"];
            }
        }];
    }];
}

- (void)uploadImages:(NSArray *)images complete:(void(^)())complete {
    NSMutableArray *imagesToUpload = [images mutableCopy];
    if (imagesToUpload.count > 0) {
        UIImage *firstImage = imagesToUpload.firstObject;
        [imagesToUpload removeObject:firstImage];
        [self uploadImage:firstImage completeHandler:^(NSString *imgURL, NSError *error) {
            if (imgURL.length) {
                [self.trendImages addObject:imgURL];
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


#pragma mark - getters
- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 120 + 64)];
        _textView.font = [UIFont systemFontOfSize:14];
        _textView.textColor = UIColorFromRGBA(52, 55, 59, 1);
        _textView.placeholderColor = UIColorFromRGBA(52, 55, 59, 0.5);
        _textView.placeholderLabel.font = [UIFont systemFontOfSize:14];
        _textView.placeholder = @"说点什么吧,不少于30字";
    }
    return _textView;
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

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 5;
        flowLayout.minimumInteritemSpacing = 5;
        CGFloat itemW = (CGRectGetWidth(self.view.bounds) - 15 * 2 - 10 * 2) / 3;
        flowLayout.itemSize = CGSizeMake(itemW, itemW);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 120 + 64, CGRectGetWidth(self.view.bounds), (63 / 2 + 218 + 60)) collectionViewLayout:flowLayout];
        [_collectionView registerClass:[MCCollectionCell class] forCellWithReuseIdentifier:kCollectionCell];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"collectFooter"];
        _collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _collectionView.contentInset = UIEdgeInsetsMake(15, 15, 15, 15);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
//        _collectionView.bounces = NO;
        _collectionView.alwaysBounceVertical = YES;
        
        _collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _collectionView;
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
