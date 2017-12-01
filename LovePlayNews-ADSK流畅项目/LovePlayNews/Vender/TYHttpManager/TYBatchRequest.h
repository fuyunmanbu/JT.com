//
//  TYBatchRequest.h
//  TYHttpManagerDemo
//
//  Created by tany on 16/5/27.
//  Copyright © 2016年 tany. All rights reserved.

// 预计：该类是用于(批量)处理请求逻辑，将请求的实现方法孤立了出去

#import <Foundation/Foundation.h>
#import "TYRequestProtocol.h"

@class TYBatchRequest;
typedef void (^TYBatchRequestSuccessBlock)(TYBatchRequest *request);
typedef void (^TYBatchRequestFailureBlock)(TYBatchRequest *request,NSError *error);

@interface TYBatchRequest : NSObject

// 以下两个属性在.m文件均有可写属性
@property (nonatomic, strong, readonly) NSArray *batchRequstArray;
@property (nonatomic, assign, readonly) NSInteger requestCompleteCount;

// 这两个属性用于记录下面两个方法的block回调（这里是只读属性，.m文件内有局部属性）
@property (nonatomic, copy, readonly) TYBatchRequestSuccessBlock successBlock; // 请求成功block
@property (nonatomic, copy, readonly) TYBatchRequestFailureBlock failureBlock; // 请求失败block
// 添加一个请求
- (void)addRequest:(id<TYRequestProtocol>)request;
// 添加一组请求
- (void)addRequestArray:(NSArray *)requestArray;
// 取消某个请求
- (void)cancleRequest:(id<TYRequestProtocol>)request;

// 设置回调block
- (void)setRequestSuccessBlock:(TYBatchRequestSuccessBlock)successBlock failureBlock:(TYBatchRequestFailureBlock)failureBlock;// 传进来block回调，并用属性记录block块，在其他地方回调，用上面两个block属性记录
// load block
- (void)loadWithSuccessBlock:(TYBatchRequestSuccessBlock)successBlock failureBlock:(TYBatchRequestFailureBlock)failureBlock;

- (void)load;

- (void)cancle;

@end
