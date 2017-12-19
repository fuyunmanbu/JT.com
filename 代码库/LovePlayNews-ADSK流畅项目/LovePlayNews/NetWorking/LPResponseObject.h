//
//  TYResponseObject.h
//  TYHttpManagerDemo
//
//  Created by tany on 16/5/24.
//  Copyright © 2016年 tany. All rights reserved.

// 以下三个类都是继承于 TYResponseObject ，应该适用于处理不同样式的结果

#import "TYResponseObject.h"

typedef NS_ENUM(NSInteger, TYStauteCode) {
    TYStauteSuccessCode = 0, // 该状态码表示成功
};

@interface LPResponseObject : TYResponseObject
//这里都是重写父类的方法，对父类方法的补充，自定义

@end
