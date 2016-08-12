//
//  SecondViewController.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/4.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCPostCFViewController.h"
#import "MCPostCFDetailVC.h"


@interface MCPostCFViewController ()
@end

@implementation MCPostCFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postDreamCFAction:(id)sender {
    MCPostCFDetailVC *postDetailVC = [[MCPostCFDetailVC alloc] init];
    postDetailVC.cfType = CrowdFundingTypeDream;
    [self.navigationController pushViewController:postDetailVC animated:YES];
}

- (IBAction)postProductCFAction:(id)sender {
    MCPostCFDetailVC *postDetailVC = [[MCPostCFDetailVC alloc] init];
    postDetailVC.cfType = CrowdFundingTypeProduct;
    [self.navigationController pushViewController:postDetailVC animated:YES];
}

@end

@implementation MCPostButton

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    
    self.imageView.frame = CGRectMake(0, 0, width, 97);
    self.titleLabel.frame = CGRectMake(0, 97, width, height - 97);
    
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

@end
