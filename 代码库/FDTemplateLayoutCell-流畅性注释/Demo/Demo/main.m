//
//  main.m
//  Demo
//
//  Created by sunnyxx on 15/4/16.
//  Copyright (c) 2015年 forkingdog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDAppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        // 对比系统自带的写法，这里的写法确实可以注意一下，需要遵守 UIApplicationDelegate 代理
        //UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([FDAppDelegate class]));
    }
}
