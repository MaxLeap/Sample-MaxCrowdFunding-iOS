//
//  MCTabbarController.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/4.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "MCTabbarController.h"
#import "MCPostCFViewController.h"

@interface MCTabbarController ()<UITabBarControllerDelegate>

@end

@implementation MCTabbarController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configTabbarItems];
    
    [self addObservers];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPostNewCF:) name:kDidPostNewCF object:nil];
}

- (void)didPostNewCF:(NSNotification *)notify {
    self.selectedIndex = 0;
}

- (void)configTabbarItems {
    NSArray *itemImgs = @[@"btn_zhongchou_tabbar", @"icn_launch_homepage", @"btn_user profiles"];
    NSArray *childVCs = self.childViewControllers;
    
    NSInteger i = 0;
    for (UIViewController *vc in childVCs) {
        NSString *imgPrefix = itemImgs[i];
        NSString *normalImgName, *selectedImgName;
        if (i != 1) {
            normalImgName = [imgPrefix stringByAppendingString:@"_normal"];
            selectedImgName = [imgPrefix stringByAppendingString:@"_selected"];
        } else {
            normalImgName = imgPrefix;
            selectedImgName = imgPrefix;
        }
        
        vc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImgName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        vc.tabBarItem.image = [[UIImage imageNamed:normalImgName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        NSDictionary *normalAtt = @{
                    NSForegroundColorAttributeName : UIColorFromRGBA(151, 151, 151, 1)
                                    };
        NSDictionary *selectedAtt = @{
                    NSForegroundColorAttributeName : UIColorFromRGBA(78, 89, 99, 1)
                                      };
        
        [vc.tabBarItem setTitleTextAttributes:normalAtt forState:UIControlStateNormal];
        [vc.tabBarItem setTitleTextAttributes:selectedAtt forState:UIControlStateSelected];
        
        i ++;
    }
}

#pragma mark - UITabBarController delegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    UINavigationController *navController = (UINavigationController *)viewController;
    if ([navController.topViewController isKindOfClass:[MCPostCFViewController class]]) {
        UIViewController *postCFVC = [self viewControllerWithStoryboardID:@"MCPostCFViewController"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:postCFVC];
        [self presentViewController:navController animated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (UIViewController *)viewControllerWithStoryboardID:(NSString *)sbID {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:sbID];
    return vc;
}

@end
