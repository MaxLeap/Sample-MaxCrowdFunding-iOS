//
//  AppDelegate.m
//  MaxCrowdFunding
//
//  Created by luomeng on 16/7/4.
//  Copyright © 2016年 MaxLeap. All rights reserved.
//

#import "AppDelegate.h"
#import "WXApi.h"
#import "WeiboSDK.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <MLHelpCenter/MLHelpCenter.h>

@import MLWeChatUtils;
@import MLWeiboUtils;
@import MLQQUtils;
@import MaxLeapPay;

#define MAXLEAP_APPID           @"577dc473169e7d0001082c21"
#define MAXLEAP_CLIENTKEY       @"dzNrSkRZeUE4MzdQeWE0RmpxeUQ3QQ"

// 注意要在info.plist中的URL Types中设置
#define WECHAT_APPID            @"wx41b6f4bde79513c8"
#define WECHAT_SECRET           @"d4624c36b6795d1d99dcf0547af5443d"
#define WEIBO_APPKEY            @"2328234403"
#define WEIBO_REDIRECTURL       @"https://api.weibo.com/oauth2/default.html"
#define QQ_APPID                @"222222"


@interface AppDelegate ()<WXApiDelegate,
TencentSessionDelegate,
WeiboSDKDelegate
>


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self configureGlobalAppearance];
    
    //配置 MaxLeap app信息
    [MaxLeap setApplicationId:MAXLEAP_APPID clientKey:MAXLEAP_CLIENTKEY site:MLSiteCN];
    [MaxLeapPay setWXAppId:WECHAT_APPID wxDelegate:self description:@"Payment sample"];
    [MLHelpCenter install];
    
    // 集成Wechat & Weibo & QQ
    [MLWeChatUtils initializeWeChatWithAppId:WECHAT_APPID appSecret:WECHAT_SECRET wxDelegate:self];
    [MLWeiboUtils initializeWeiboWithAppKey:WEIBO_APPKEY redirectURI:WEIBO_REDIRECTURL];
    [MLQQUtils initializeQQWithAppId:QQ_APPID qqDelegate:self];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark WXApiDelegate  &  payment delegate and methods
- (void)onResp:(BaseResp *)resp {
    // 将 PayResponse 交给 MaxLeapPay 处理
    if ([resp isKindOfClass:[PayResp class]]) {
        [MaxLeapPay handleWXPayResponse:(PayResp *)resp];
    }
    
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        [MLWeChatUtils handleAuthorizeResponse:(SendAuthResp *)resp];
    } else {
        // 处理其他请求的响应
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([url.absoluteString hasPrefix:@"tencent"]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    if ([url.absoluteString hasPrefix:@"wb"]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
    if ([url.absoluteString hasPrefix:@"wx"]) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    
    return YES;
}

/**
 * pay ment
 * iOS 4.2 -- iOS 8.4
 * 如果需要兼容 iOS 6, iOS 7, iOS 8，需要实现这个代理方法
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {
    
    // 注意，这里由 `MaxLeapPay` 统一调用各支付平台 SDK 的 `handleOpenUrl:` 方法，可能与其他 SDK 的发生重复调用问题，请注意处理
    
    return [MaxLeapPay handleOpenUrl:url completion:^(MLPayResult * _Nonnull result) {
        // 支付应用结果回调，保证跳转支付应用过程中，即使调用方app被系统kill时，能通过这个回调取到支付结果。
    }];
    
    
    if ([url.absoluteString hasPrefix:@"tencent"]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    if ([url.absoluteString hasPrefix:@"wb"]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
    if ([url.absoluteString hasPrefix:@"wx"]) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    
    return YES;
}

/**
 * payment
 * iOS 9.0 or later
 * iOS 9 以及更新版本会优先调用这个代理方法，如果没有实现这个，则会调用上面那个
 */

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    
    // 注意，这里由 `MaxLeapPay` 统一调用各支付平台 SDK 的 `handleOpenUrl:` 方法，可能与其他 SDK 的发生重复调用问题，请注意处理
    
    return [MaxLeapPay handleOpenUrl:url completion:^(MLPayResult * _Nonnull result) {
        // 支付应用结果回调，保证跳转支付应用过程中，即使调用方app被系统kill时，能通过这个回调取到支付结果。
    }];
    
    
    if ([url.absoluteString hasPrefix:@"tencent"]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    if ([url.absoluteString hasPrefix:@"wb"]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
    if ([url.absoluteString hasPrefix:@"wx"]) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    
    return YES;
}

#pragma mark TencentLoginDelegate TencentSessionDelegate

// 以下三个方法保持空实现就可以，MLQQUtils 会置换这三个方法，但是会调用这里的实现

- (void)tencentDidLogin {
    
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    
}

- (void)tencentDidNotNetWork {
    
}

#pragma mark - WeiboSDKDelegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    NSLog(@"didReceiveWeiboRequest %@", request);
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        [MLWeiboUtils handleAuthorizeResponse:(WBAuthorizeResponse *)response];
    }
}

#pragma mark - set Appearance
- (void)configureGlobalAppearance {
//    UIImage *barBGImage = [UIImage imageWithColor:[UIColor whiteColor]];
//    [[UINavigationBar appearance] setBackgroundImage:barBGImage forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                    NSForegroundColorAttributeName : [UIColor blackColor],
                    NSFontAttributeName : [UIFont systemFontOfSize:17]}];
    [[UINavigationBar appearance] setBackIndicatorImage:[ImageNamed(@"icn_back") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[ImageNamed(@"icn_back") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
//                NSForegroundColorAttributeName : [UIColor blackColor],
                NSFontAttributeName : [UIFont systemFontOfSize:17]}
                                                forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -64) forBarMetrics:UIBarMetricsDefault];
}


@end
