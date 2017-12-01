//
//  TYBaseRequest.m
//  TYHttpManagerDemo
//
//  Created by tany on 16/5/23.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYBaseRequest.h"
#import "TYHttpManager.h"

@interface TYBaseRequest ()
@property (nonatomic, copy) TYRequestSuccessBlock successBlock;
@property (nonatomic, copy) TYRequestFailureBlock failureBlock;

@property (nonatomic, assign) TYRequestState state;
@property (nonatomic, strong) id responseObject;
@end

@implementation TYBaseRequest

-(instancetype)init
{
    if (self = [super init]) {
        // 设置默认属性
        _method = TYRequestMethodGet;
        _serializerType = TYRequestSerializerTypeJSON;
        _timeoutInterval = 60;
    }
    return self;
}

#pragma mark - load request

// 请求
- (void)load
{
    // 这里的请求方法让我想起了 swift 开发框架 Moya 的使用方式，猜测
    [[TYHttpManager sharedInstance] addRequest:self];
    _state = TYRequestStateLoading;
}

// 取消
- (void)cancle
{
    [_dataTask cancel];
    [self clearRequestBlock];
    _delegate = nil;
    _state = TYRequestStateCancle;
}
// 设置回调block
- (void)setRequestSuccessBlock:(TYRequestSuccessBlock)successBlock failureBlock:(TYRequestFailureBlock)failureBlock
{
    _successBlock = successBlock;
    _failureBlock = failureBlock;
}

- (void)loadWithSuccessBlock:(TYRequestSuccessBlock)successBlock failureBlock:(TYRequestFailureBlock)failureBlock
{
    [self setRequestSuccessBlock:successBlock failureBlock:failureBlock];
    
    [self load];
}

#pragma mark - call delegate , block
// 收到请求返回的数据
- (void)requestDidResponse:(id)responseObject error:(NSError *)error
{
    if (error) {
        // 错了
        [self requestDidFailWithError:error];
    }else {
        if ([self validResponseObject:responseObject error:&error]){// 验证请求数据
            // 请求成功
            [self requestDidFinish];
        }else{
            // 错了
            [self requestDidFailWithError:error];
        }
    }
}

// 验证数据
- (BOOL)validResponseObject:(id)responseObject error:(NSError *__autoreleasing *)error
{
    // 记录该值，返回数据有没有值的判断
    _responseObject = responseObject;
    return _responseObject ? YES : NO;
}

// 请求成功（具体介绍见下面<请求失败>方法的注释）
- (void)requestDidFinish
{
    _state = TYRequestStateFinish;
    
    // 这种block写法可以借鉴，平时没注意
    void (^finishBlock)() = ^{
        if ([_delegate respondsToSelector:@selector(requestDidFinish:)]) {
            [_delegate requestDidFinish:self];
        }
        
        if (_successBlock) {
            _successBlock(self);
        }
        
        if (_embedAccesory && [_embedAccesory respondsToSelector:@selector(requestDidFinish:)]) {
            [_embedAccesory requestDidFinish:self];
        }
    };
    
    if (_asynCompleteQueue) {
        finishBlock();
    }else {
        dispatch_async(dispatch_get_main_queue(),finishBlock);
    }
}

// 请求失败
- (void)requestDidFailWithError:(NSError* )error
{
    _state = TYRequestStateError;
    
    // 这种block写法可以借鉴，平时没注意
    void (^failBlock)() = ^{
        // 如果代理有实现这个方法，回调
        if ([_delegate respondsToSelector:@selector(requestDidFail:error:)]) {
            [_delegate requestDidFail:self error:error];
        }
        
        if (_failureBlock) { //如果block不为nil，回调该block
            _failureBlock(self,error);
        }
        
        // 如果属性不为nil，且有方法实现，回调
        if (_embedAccesory && [_embedAccesory respondsToSelector:@selector(requestDidFail:error:)]) {
            [_embedAccesory requestDidFail:self error:error];
        }
    };
    
    //asynCompleteQueue：是否在异步线程中回调 默认NO
    if (_asynCompleteQueue) {
        failBlock();
    }else {
        // 为 NO 就回到主线程回调
        dispatch_async(dispatch_get_main_queue(),failBlock);
    }
}
// 清除block引用
- (void)clearRequestBlock
{
    _successBlock = nil;
    _failureBlock = nil;
    _progressBlock = nil;
    _constructingBodyBlock = nil;
}

- (void)dealloc
{
    [self clearRequestBlock];
    [_dataTask cancel];
    _delegate = nil;
}

@end
