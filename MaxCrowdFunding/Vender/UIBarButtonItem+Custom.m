//
//  UIBarButtonItem+Custom.m
//  iKeyboard
//
//  Created by XiaJun on 15/4/3.
//  Copyright (c) 2015年 iLegendSoft. All rights reserved.
//

#import "UIBarButtonItem+Custom.h"

@implementation UIBarButtonItem (Custom)

+ (UIBarButtonItem *)barButtonItemWithNormalImagenName:(NSString *)normalImageName
                                  highlightedImageName:(NSString *)highlightedImageName
                                                target:(id)taget
                                                action:(SEL)action {
    UIImage* normalImage = [UIImage imageNamed:normalImageName];
    UIImage* selectedImage = [UIImage imageNamed:highlightedImageName];
    UIButton *someButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, normalImage.size.width, normalImage.size.height)];
    [someButton setImage:normalImage forState:UIControlStateNormal];
    [someButton setImage:selectedImage forState:UIControlStateHighlighted];
    [someButton addTarget:taget action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtomItem = [[UIBarButtonItem alloc] initWithCustomView:someButton];
    return barButtomItem;
}

+ (UIBarButtonItem *)barButtonItemWithNormalImagenName:(NSString *)normalImageName
                                     selectedImageName:(NSString *)selectedImageName
                                                target:(id)taget
                                                action:(SEL)action {
    UIImage* normalImage = [UIImage imageNamed:normalImageName];
    UIImage* selectedImage = [UIImage imageNamed:selectedImageName];
    UIButton *someButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, normalImage.size.width, normalImage.size.height)];
    [someButton setImage:normalImage forState:UIControlStateNormal];
    [someButton setImage:selectedImage forState:UIControlStateSelected];
    [someButton setImage:selectedImage forState:UIControlStateHighlighted];
    [someButton addTarget:taget action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtomItem = [[UIBarButtonItem alloc] initWithCustomView:someButton];
    return barButtomItem;
}


@end
