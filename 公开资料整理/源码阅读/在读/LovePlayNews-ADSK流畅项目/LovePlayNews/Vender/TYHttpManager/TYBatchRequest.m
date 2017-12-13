//
//  TYBatchRequest.m
//  TYHttpManagerDemo
//
//  Created by tany on 16/5/27.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYBatchRequest.h"

@interface TYBatchRequest ()<TYRequestDelegate>
@property (nonatomic, strong) NSMutableArray *batchRequstArray;
@property (nonatomic, assign) NSInteger requestCompleteCount;
@property (nonatomic, assign) BOOL isLoading;
@end

@implementation TYBatchRequest

- (instancetype)init
{
    if (self = [super init]) {
        // 该属性设置默认值
        _batchRequstArray = [NSMutableArray array];
    }
    return self;
}
// 添加一个请求
- (void)addRequest:(id<TYRequestProtocol>)request
{
    if (_isLoading) {
        // TYBatchRequest正在运行，无法添加请求
        NSLog(@"TYBatchRequest is Running,can't add request");
        return;
    }
    // weak:指明该对象并不负责保持delegate这个对象，delegate这个对象的销毁由外部控制
//    strong：该对象强引用delegate，外界不能销毁delegate对象，会导致循环引用(Retain Cycles)
    // 设置请求代理为自己 strong，在该类中 request 未被强引用，所以没有 循环引用 问题
    request.embedAccesory = self; //设置代理
    // 将协议参数用数组记录住
    [_batchRequstArray addObject:request];
}
// 添加一组请求
- (void)addRequestArray:(NSArray *)requestArray
{
    for (id<TYRequestProtocol> request in requestArray) {
        // conformsToProtocol: 用来检查对象是否实现了指定协议类的方法
        if ([request conformsToProtocol:@protocol(TYRequestProtocol) ]) {
            [self addRequest:request];
        }
    }
}
// 取消某个请求
- (void)cancleRequest:(id<TYRequestProtocol>)request
{
    request.embedAccesory = nil;
    [request  cancle];
    [_batchRequstArray removeObject:request];
}
// 传进来block回调，并用属性记录block块
- (void)setRequestSuccessBlock:(TYBatchRequestSuccessBlock)successBlock failureBlock:(TYBatchRequestFailureBlock)failureBlock
{
    _successBlock = successBlock;
    _failureBlock = failureBlock;
}

- (void)loadWithSuccessBlock:(TYBatchRequestSuccessBlock)successBlock failureBlock:(TYBatchRequestFailureBlock)failureBlock
{
    [self setRequestSuccessBlock:successBlock failureBlock:failureBlock];
    
    [self load];
}
// 发动数组里每一个参数的请求方法
- (void)load{
    // 如果储存的数组/状态为YES，则return
    if (_isLoading || _batchRequstArray.count == 0) {
        return;
    }
    _isLoading = YES;
    _requestCompleteCount = 0;
    //数组里的每一个参数调用请求方法
    for (id<TYRequestProtocol> request in _batchRequstArray) {
        [request load];
    }
}
//取消所有正在执行/未执行的方法，设置状态
- (void)cancle
{
    for (id<TYRequestProtocol> request in _batchRequstArray) {
        request.embedAccesory = nil;
        [request cancle];
    }
    [_batchRequstArray removeAllObjects];
    _requestCompleteCount = 0;
    _isLoading = NO;
}
// 下面两个代理方法
#pragma mark - delegate
- (void)requestDidFinish:(id<TYRequestProtocol>)request
{
    NSInteger index = [_batchRequstArray indexOfObject:request];
    if (index != NSNotFound) {
        // ++i 先执行i+1,后执行程序  i++ 先执行程序,后执行i+1
        ++_requestCompleteCount; // 记录请求执行完成后的个数
    }
    
    if (_requestCompleteCount == _batchRequstArray.count) { // 如果数组内所有请求都执行完成
        if (_successBlock) {
            _successBlock(self); // 回调
        }
        [_batchRequstArray removeAllObjects];
        _isLoading = NO;// 结束请求状态，清空保存的协议参数
    }
}

- (void)requestDidFail:(id<TYRequestProtocol>)request error:(NSError *)error
{
    // 如果出现错误回调，直接结束所有的请求，调整状态(为什么不直接调用 cancle 方法？)
    if (_failureBlock) {
        _failureBlock(self,error);// 回调
    }
    [_batchRequstArray removeAllObjects];
    _isLoading = NO;
}

- (void)clearBlocks
{
    _successBlock = nil;
    _failureBlock = nil;
}
// 清除block记录，注意：自己忽略了这个问题
- (void)dealloc
{
    [self clearBlocks];
}


@end
