//
//  LPTabBarController.m
//  LovePlayNews
//
//  Created by tany on 16/8/1.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "LPTabBarController.h"
#import "UITabBarController+AddChildVC.h"
#import "UIImage+Color.h"
#import "LPNavigationController.h"
#import "LPNewsPagerController.h"
#import "LPRecommendController.h"
#import "LPZonePagerController.h"
#import "LPMineViewController.h"

@interface LPTabBarController ()

@end

@implementation LPTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureTabBar];
    
    [self configureChildViewControllers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    设置状态栏的颜色
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

//设置 tabBar
- (void)configureTabBar
{
//    这句代码不清楚具体作用
    self.tabBar.shadowImage = [UIImage imageNamed:@"tabbartop-line"];
    if (kIsIOS8Later) {// 设置tabBar的背景，带微微的透明效果，接近不透明
        [self.tabBar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:238/255.0 green:240/255.0 blue:245/255.0 alpha:0.78]]];
        // blur效果
        UIVisualEffectView *visualEfView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        visualEfView.frame = CGRectMake(0, -1, CGRectGetWidth(self.tabBar.frame), CGRectGetHeight(self.tabBar.frame)+1);
        visualEfView.alpha = 1.0;
        [self.tabBar insertSubview:visualEfView atIndex:0];
    }
    
//    设置 tabBarItem 选中和默认时文字的颜色
    [[UITabBarItem appearanceWhenContainedIn:[LPTabBarController class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor colorWithRed:113/255.0 green:113/255.0 blue:113/255.0 alpha:1.0] } forState:UIControlStateNormal];
    
    [[UITabBarItem appearanceWhenContainedIn:[LPTabBarController class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName :[UIColor colorWithRed:218/255.0 green:85/255.0 blue:107/255.0 alpha:1.0] } forState:UIControlStateSelected];
}

- (void)configureChildViewControllers
{
    // 资讯
    [self addNewsController];
    
    // 精选
    [self addRecommendController];
    
    // 社区
    [self addZoneController];
    
    // 我的
    [self addMineController];
}

#pragma mark - add childVC
//资讯
- (void)addNewsController
{
    UIEdgeInsets imageInsets = UIEdgeInsetsZero;
    UIOffset titlePosition = UIOffsetMake(0, -2);
    
    LPNewsPagerController *newsPagerController = [[LPNewsPagerController alloc]init];
    
    [self addChildViewController:newsPagerController title:@"资讯" image:@"icon_zx_nomal_pgall" selectedImage:@"icon_zx_pressed_pgall" imageInsets:imageInsets titlePosition:titlePosition navControllerClass:[LPNavigationController class]];
}
//精选
- (void)addRecommendController
{
    UIEdgeInsets imageInsets = UIEdgeInsetsZero;
    UIOffset titlePosition = UIOffsetMake(0, -2);

    LPRecommendController *recommendController = [[LPRecommendController alloc]init];
    [self addChildViewController:recommendController title:@"精选" image:@"icon_jx_nomal_pgall" selectedImage:@"icon_jx_pressed_pgall"imageInsets:imageInsets titlePosition:titlePosition navControllerClass:[LPNavigationController class]];
}
//社区
- (void)addZoneController
{
    UIEdgeInsets imageInsets = UIEdgeInsetsZero;
    UIOffset titlePosition = UIOffsetMake(0, -2);
    
    LPZonePagerController *zoneController = [[LPZonePagerController alloc]init];
    [self addChildViewController:zoneController title:@"社区" image:@"icon_sq_nomal_pgall" selectedImage:@"icon_sq_pressed_pgall"imageInsets:imageInsets titlePosition:titlePosition navControllerClass:[LPNavigationController class]];
}
//我
- (void)addMineController
{
    UIEdgeInsets imageInsets = UIEdgeInsetsZero;
    UIOffset titlePosition = UIOffsetMake(0, -2);
    
    LPMineViewController *mineController = [[LPMineViewController alloc]init];
    [self addChildViewController:mineController title:@"我" image:@"icon_w_nomal_pgall" selectedImage:@"icon_w_pressed_pgall"imageInsets:imageInsets titlePosition:titlePosition navControllerClass:[LPNavigationController class]];
}
@end
