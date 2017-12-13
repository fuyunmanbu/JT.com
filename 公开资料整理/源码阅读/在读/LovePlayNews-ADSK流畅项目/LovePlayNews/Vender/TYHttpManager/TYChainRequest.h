//
//  TYChainRequest.h
//  TYHttpManagerDemo
//
//  Created by tany on 16/5/27.
//  Copyright © 2016年 tany. All rights reserved.

// 该类和上面(TYBatchRequest)的类代码功能几乎一样，内部只是多加了一层方法的封装

#import <Foundation/Foundation.h>
#import "TYRequestProtocol.h"

@class TYChainRequest;
typedef void (^TYChainRequestSuccessBlock)(TYChainRequest *request);
typedef void (^TYChainRequestFailureBlock)(TYChainRequest *request,NSError *error);

@interface TYChainRequest : NSObject

// 以下两个属性在.m文件均有可写属性，外界只能读，里面处理逻辑
@property (nonatomic, strong, readonly) NSArray *chainRequstArray;
@property (nonatomic, assign, readonly) NSInteger curRequestIndex;

// 这两个属性用于记录下面两个方法的block回调（这里是只读属性，.m文件内有局部属性）
@property (nonatomic, copy, readonly) TYChainRequestSuccessBlock successBlock; // 请求成功block
@property (nonatomic, copy, readonly) TYChainRequestFailureBlock failureBlock; // 请求失败block

- (void)addRequest:(id<TYRequestProtocol>)request;

- (void)addRequestArray:(NSArray *)requestArray;

- (void)cancleRequest:(id<TYRequestProtocol>)request;

// 设置回调block
- (void)setRequestSuccessBlock:(TYChainRequestSuccessBlock)successBlock failureBlock:(TYChainRequestFailureBlock)failureBlock;

- (void)loadWithSuccessBlock:(TYChainRequestSuccessBlock)successBlock failureBlock:(TYChainRequestFailureBlock)failureBlock;

- (void)load;

- (void)cancle;

@end
