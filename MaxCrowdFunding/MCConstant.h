//
//  MCConstant.h
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/6.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#ifndef MCConstant_h
#define MCConstant_h

#define kTextColor                  UIColorFromRGB(0x404040)
#define kNavigationBGColor          UIColorFromRGB(0xFF7700)
#define kMainBGColor                UIColorFromRGB(0xFF7700)
#define kDefaultTextColor           UIColorFromRGB(0x444444)
#define kDefaultGrayColor           UIColorFromRGB(0x8F8F8F)
#define kSeparatorLineColor         [UIColor groupTableViewBackgroundColor]

#define ImageNamed(x)               [UIImage imageNamed:x]

#define UIColorFromRGBA(r, g, b, a) [UIColor colorWithRed:((float)(r))/255 green:((float)g)/255 blue:((float)b)/255 alpha:(a)]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromRGBWithAlpha( rgbValue, a ) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]
#define ScreenRect [[UIScreen mainScreen] bounds]

#define BLOCK_SAFE_RUN(block, ...) block ? block(__VA_ARGS__) : nil

#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

#define RAND_FROM_TO(min, max) (min + arc4random_uniform(max - min + 1))


// notification
#define kDidFinishSupportCF @"DidSupportCF"
#define kDidDeleteCF @"DidDeleteCF"
#define kDidPostNewCF @"DidPostNewCF"


#endif /* MCConstant_h */
