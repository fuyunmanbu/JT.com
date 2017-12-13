//
//  AppDelegate.m
//  LovePlayNews
//
//  Created by tany on 16/8/1.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "AppDelegate.h"
#import "LPTabBarController.h"
#import "LPADLaunchController.h"
#import "JPFPSStatus.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self addMainWindow];
    
    [self addADLaunchController];
    
#if defined(DEBUG)||defined(_DEBUG)
    [[JPFPSStatus sharedInstance] open]; // 画面帧率测试
#endif
    
    return YES;
}

//手动加载主控制器，tabbar和分页视图
- (void)addMainWindow
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[LPTabBarController alloc]init];
    [self.window makeKeyAndVisible];
}

//在主视图上添加一个视图，目测是广告
- (void)addADLaunchController
{
    UIViewController *rootViewController = self.window.rootViewController;
    LPADLaunchController *launchController = [[LPADLaunchController alloc]init];
    [rootViewController addChildViewController:launchController];
    launchController.view.frame = rootViewController.view.frame;
    [rootViewController.view addSubview:launchController.view];
}

@end
