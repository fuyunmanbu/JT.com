//
//  TYResponseObject.h
//  LovePlayNews
//
//  Created by tany on 16/9/7.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYHttpRequest.h"

@interface TYResponseObject : NSObject<TYHttpResponseParser> // 遵守了该协议

@property (nonatomic, strong) NSString *msg; // 消息

@property (nonatomic, assign) NSInteger status; //状态码

@property (nonatomic, strong) id data;// json 或 model数据

// 需要自己在parseResponse实现模型转换
@property (nonatomic, assign, readonly) Class modelClass;

// 初始化方法
- (instancetype)initWithModelClass:(Class)modelClass;

// 验证(处理掉错误的可能，确保数据正确)
- (BOOL)isValidResponse:(id)response request:(TYHttpRequest *)request error:(NSError *__autoreleasing *)error;

// 解析 返回ResponseObject（记录 response 数据）
- (id)parseResponse:(id)response request:(TYHttpRequest *)request;

@end
