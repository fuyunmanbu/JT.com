//
//  TYHttpManager.m
//  TYHttpManagerDemo
//
//  Created by tany on 16/5/23.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYHttpManager.h"
#import "AFNetworking.h"

@implementation TYHttpManager

#pragma mark - init
+ (TYHttpManager *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
/*
 //    dispatch_queue_t targetQueue = dispatch_queue_create("targetQueue", DISPATCH_QUEUE_SERIAL); //目标队列 DISPATCH_QUEUE_SERIAL 串行队列
 //    dispatch_queue_t queue3 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
 //    设置参考
 //    dispatch_set_target_queue(targetQueue, queue3);
 //    dispatch_async(targetQueue, ^{
 //        NSLog(@"job3 in");
 //        NSLog(@"%@",[NSThread currentThread]);
 //        [NSThread sleepForTimeInterval:2.f];
 //        NSLog(@"job3 out");
 //    });
 //    dispatch_async(targetQueue, ^{
 //        NSLog(@"job2 in");
 //        NSLog(@"%@",[NSThread currentThread]);
 //        [NSThread sleepForTimeInterval:1.f];
 //        NSLog(@"job2 out");
 //    });
 //    dispatch_async(targetQueue, ^{
 //        NSLog(@"job1 in");
 //        NSLog(@"%@",[NSThread currentThread]);
 //        [NSThread sleepForTimeInterval:3.f];
 //        NSLog(@"job1 out");
 //    });
 //    2017-11-29 14:35:50.418861+0800 moreText[53592:2673671] job3 in
 //    2017-11-29 14:35:50.419310+0800 moreText[53592:2673671] <NSThread: 0x60000046b980>{number = 5, name = (null)}
 //    2017-11-29 14:35:52.424435+0800 moreText[53592:2673671] job3 out
 //    2017-11-29 14:35:52.424731+0800 moreText[53592:2673671] job2 in
 //    2017-11-29 14:35:52.425534+0800 moreText[53592:2673671] <NSThread: 0x60000046b980>{number = 5, name = (null)}
 //    2017-11-29 14:35:53.430701+0800 moreText[53592:2673671] job2 out
 //    2017-11-29 14:35:53.431008+0800 moreText[53592:2673671] job1 in
 //    2017-11-29 14:35:53.431276+0800 moreText[53592:2673671] <NSThread: 0x60000046b980>{number = 5, name = (null)}
 //    2017-11-29 14:35:56.431777+0800 moreText[53592:2673671] job1 out
 */
// 该方法是产生一个串行队列，与全局并发队列同优先级，执行方式是同步的
+ (dispatch_queue_t)completeQueue {
    static dispatch_queue_t completeQueue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 创建一个串行队列
        completeQueue = dispatch_queue_create("com.TYHttpManager.completeQueue", DISPATCH_QUEUE_SERIAL);
//        dispatch_set_target_queue的第一个参数为要设置优先级的queue,第二个参数是对应的优先级参照物，既将第一个queue的优先级和第二个queue的优先级设置一样。
//        dispatch_set_target_queue()函数为你自己创建的队列指定优先级，这个过程还需借助我们的全局队列。下方的代码段中我们先创建了一个串行队列，然后通过该函数将全局队列中的高优先级赋值给我们刚创建的这个串行队列
//        dispatch_set_target_queue除了能用来设置队列的优先级之外，还能够创建队列的层次体系，当我们想让不同队列中的任务同步（sync）的执行时，我们可以创建一个串行队列，然后将这些队列的target指向新创建的队列即可
//        dispatch_set_target_queue将多个串行的queue指定到了同一目标，那么多个串行queue在目标queue上就是同步(sync)执行的，不再是并行(async)执行
        // https://www.cnblogs.com/denz/archive/2016/02/24/5214297.html
        
        // DISPATCH_QUEUE_PRIORITY_DEFAULT 优先级 默认（中）
        // dispatch_get_global_queue 获得全局并发队列
        dispatch_set_target_queue(completeQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    });
    return completeQueue;
}

- (instancetype)init
{
    if (self = [super init]) {
        // 该参数在没有外部的值设置时，默认是这个值
        _requestConfiguration = [TYRequstConfigure sharedInstance];
    }
    return self;
}

#pragma maek - add request
// 添加/发生一个请求
- (void)addRequest:(id<TYRequestProtocol>)request
{
    // 初始化一个 AFHTTPSessionManager,不是单利
    AFHTTPSessionManager *manager = [self defaultSessionManagerWithRequest:request];
    // 设置 AFHTTPSessionManager 的属性
    [self configureSessionManager:manager request:request];
    // 开始数据请求
    [self loadRequest:request sessionManager:manager];
}
// 请求取消事件
- (void)cancleRequest:(id<TYRequestProtocol>)request
{
    [request cancle];
}

#pragma mark - configure http manager
// 初始化 AFHTTPSessionManager
- (AFHTTPSessionManager *)defaultSessionManagerWithRequest:(id<TYRequestProtocol>)request
{
    // 用协议的方法初始化
    TYRequstConfigure *requestConfiguration = [request configuration];
    if (requestConfiguration == nil) { // 如果是 nil ，则用自己的参数值
        requestConfiguration = self.requestConfiguration;
    }
    
    AFHTTPSessionManager *manager = nil;
    if (requestConfiguration.sessionConfiguration) {
        // 如果 sessionConfiguration 有值，在初始化时进行参数设置
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:requestConfiguration.baseURL] sessionConfiguration:requestConfiguration.sessionConfiguration];
    }else {
        // 如果 sessionConfiguration 没值，简单初始化
        manager = [AFHTTPSessionManager manager];
    }
    // block默认在主线程执行，修改block的线程
    manager.completionQueue = [[self class] completeQueue];
    return manager;
}
// 设置 AFHTTPSessionManager 的属性
- (void)configureSessionManager:(AFHTTPSessionManager *)manager request:(id<TYRequestProtocol>)request
{
    // `AFJSONRequestSerializer`是`AFHTTPRequestSerializer`的子类，它使用`NSJSONSerialization`将参数编码为JSON，将编码请求的`Content-Type`设置为`application / json`。
    if ([request serializerType] == TYRequestSerializerTypeJSON) {
        // 如果是 JSON 类型
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
    } else if ([request serializerType] == TYRequestSerializerTypeString) {
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        // NSJSONReadingAllowFragments：被解析的JSON数据如果既不是字典也不是数组, 那么就必须使用这
        manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    }
    // headerFieldValues：HTTP报头添加的自定义参数
    // request 是外面传进来的协议参数
    NSDictionary *headerFieldValue = [request headerFieldValues];
    if (headerFieldValue) {
        // 如果HTTP报头有自定义的参数，遍历，设置
        [headerFieldValue enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL * stop) {
            if ([key isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
                [manager.requestSerializer setValue:value forHTTPHeaderField:key];
            }
        }];
    }
    
    manager.requestSerializer.cachePolicy = [request cachePolicy];// 缓存策略
    manager.requestSerializer.timeoutInterval = [request timeoutInterval];// 请求的连接超时时间，默认为60秒
    // 响应可接受的MIME类型。 如果非``nil`，那么MIME类型与该集合不相交的`Content-Type`的响应将在验证期间导致错误。
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
}

// 获取 URL 的全路径
- (NSString *)buildRequstURL:(id<TYRequestProtocol>)request
{
    // 请求的URLString,或者 URL path
    NSString *URLPath = [request URLString];
    if ([URLPath hasPrefix:@"http:"] ) {
        // 如果有 http 的前缀，直接返回这个链接
        return URLPath;
    }
    
    // baseURL 如果为空，则为requestConfigure.baseURL
    NSString *baseURL = request.baseURL.length > 0 ? request.baseURL : (request.configuration ? request.configuration.baseURL : [TYRequstConfigure sharedInstance].baseURL);
    // 返回链接的全路径
    return [NSString stringWithFormat:@"%@%@",baseURL?baseURL:@"",URLPath];
}
// 开始数据请求
- (void)loadRequest:(id<TYRequestProtocol>)request sessionManager:(AFHTTPSessionManager *)manager
{
    // 获取 URL 的全路径
    NSString *URLString = [self buildRequstURL:request];
    NSDictionary *parameters = [request parameters];// 请求参数
    
    TYRequestMethod requestMethod = [request method];// 请求的方法 默认get
    AFProgressBlock progressBlock = [request progressBlock];// 返回进度block
    
    if (requestMethod == TYRequestMethodGet) { // get
        
        request.dataTask = [manager GET:URLString parameters:parameters progress:progressBlock success:^(NSURLSessionDataTask * task, id responseObject) {
            [request requestDidResponse:responseObject error:nil];
        } failure:^(NSURLSessionDataTask * task, NSError * error) {
            [request requestDidResponse:nil error:error];
        }];
    }else if (requestMethod == TYRequestMethodPost) { // post
        // 返回post组装body
        AFConstructingBodyBlock constructingBodyBlock = [request constructingBodyBlock];
        if (constructingBodyBlock) {
            // 有body时
            request.dataTask =  [manager POST:URLString parameters:parameters constructingBodyWithBlock:constructingBodyBlock progress:progressBlock  success:^(NSURLSessionDataTask * task, id responseObject) {
                [request requestDidResponse:responseObject error:nil];
            } failure:^(NSURLSessionDataTask * task, NSError * error) {
                [request requestDidResponse:nil error:error];
            }];
        }else {
            // 没body时
            request.dataTask =  [manager POST:URLString parameters:parameters progress:progressBlock success:^(NSURLSessionDataTask * task, id responseObject) {
                [request requestDidResponse:responseObject error:nil];
            } failure:^(NSURLSessionDataTask * task, NSError * error) {
                [request requestDidResponse:nil error:error];
            }];
        }
    }else if (requestMethod == TYRequestMethodHead) { // head
        
        request.dataTask = [manager HEAD:URLString parameters:parameters success:^(NSURLSessionDataTask * task) {
            [request requestDidResponse:nil error:nil];
        } failure:^(NSURLSessionDataTask * task, NSError * error) {
            [request requestDidResponse:nil error:error];
        }];
    }else if (requestMethod == TYRequestMethodPut) { // put
        
        request.dataTask = [manager PUT:URLString parameters:parameters success:^(NSURLSessionDataTask * task, id responseObject) {
            [request requestDidResponse:responseObject error:nil];
        } failure:^(NSURLSessionDataTask * task, NSError * error) {
            [request requestDidResponse:nil error:error];
        }];
    }else if (requestMethod == TYRequestMethodPatch) { // patch
        
        request.dataTask = [manager PATCH:URLString parameters:parameters success:^(NSURLSessionDataTask * task, id responseObject) {
            [request requestDidResponse:responseObject error:nil];
        } failure:^(NSURLSessionDataTask * task, NSError * error) {
            [request requestDidResponse:nil error:error];
        }];
    }
}

@end
