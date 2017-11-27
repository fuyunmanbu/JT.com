//
//  UIImage+TYLaunchImage.h
//  TYLaunchAnimationDemo
//
//  Created by tanyang on 15/12/3.
//  Copyright © 2015年 tanyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (TYLaunchImage)
// 获取 LaunchImage 的名字
+ (NSString *)ty_getLaunchImageName;
// 获取 LaunchImage
+ (UIImage *)ty_getLaunchImage;

@end
