//
//  LPAdLaunchImageView.h
//  LovePlayNews
//
//  Created by tany on 16/9/1.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPADLaunchView : UIView
// imageView 在下层，先 addSubview
@property (nonatomic, weak, readonly) UIImageView *launchImageView;
// imageView 在上层，后 addSubview
@property (nonatomic, weak, readonly) UIImageView *adImageView;
// “跳过”按钮
@property (nonatomic, weak, readonly) UIButton *skipBtn;

@end
