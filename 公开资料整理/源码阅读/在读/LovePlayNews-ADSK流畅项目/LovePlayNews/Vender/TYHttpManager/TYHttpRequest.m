//
//  TYHttpRequest.m
//  TYHttpManagerDemo
//
//  Created by tany on 16/5/23.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYHttpRequest.h"
#import "TYResponseCache.h"
#import "TYHttpManager.h"

@interface TYResponseCache ()<TYHttpResponseCache>
@end

@implementation TYHttpRequest

- (instancetype)init
{
    if (self = [super init]) {
        // 设置默认缓存时间
        _cacheTimeInSeconds = 60*60*24*7;
    }
    return self;
}

#pragma mark - load reqeust

- (id<TYHttpResponseCache>)responseCache
{
    if (_responseCache == nil) {
        // 奇怪：该类没有遵守该协议，可以直接懒加载成为该值，是因为有实现该协议的相同方法嘛？
        // 经过观察，在该文件的头部有声明 TYResponseCache 类遵守 TYHttpResponseCache 协议，与上面的猜测没有关系
        _responseCache = [[TYResponseCache alloc]init];
    }
    return _responseCache;
}

- (void)load
{
    _responseFromCache = NO;
    if (_requestFromCache && _cacheTimeInSeconds >= 0) {
        // 从缓存中获取数据，无需网络请求
        [self loadResponseFromCache];
    }
    //NSLog(@"responseFromCache %d",_responseFromCache);
    if (!_responseFromCache) {
        // 请求数据
        [super load];
    }
}

// 从缓存中获取数据
- (void)loadResponseFromCache
{
    id<TYHttpResponseCache> responseCache = [self responseCache];
    
    if (!responseCache) {
        return;
    }
    
    // 计算过期时间
    double pastTimeInterval = [[NSDate date] timeIntervalSince1970]-[self cacheTimeInSeconds];
    NSDate *pastDate = [NSDate dateWithTimeIntervalSince1970:pastTimeInterval];
    
    // 根据URL 和 过期时间 获取缓存
    NSString *urlKey = [self serializeURLKey];
    id responseObject = [responseCache objectForKey:urlKey overdueDate:pastDate];
    if (responseObject) {
        // 获取到缓存
        _responseFromCache = YES;
        [self requestDidResponse:responseObject error:nil];
    }
}

// 验证缓存
- (BOOL)validResponseObject:(id)responseObject error:(NSError *__autoreleasing *)error
{
    id<TYHttpResponseParser> responseParser = [self responseParser];
    if (responseParser == nil) {
        // 如果是nil，不做任何操作(这句代码有何意义？)
        [self cacheRequsetResponse:responseObject];
        // 执行父类的方法，这里没值，返回NO
        return [super validResponseObject:responseObject error:error];
    }
    
    if (_responseFromCache || [responseParser isValidResponse:responseObject request:self error:error]) {
        // 有效的数据 才可以缓存
        [self cacheRequsetResponse:responseObject];
        // 验证后 解析数据
        id responseParsedObject = [responseParser parseResponse:responseObject request:self];
        return [super validResponseObject:responseParsedObject error:error];
    }else {
        return NO;
    }
}

#pragma mark - private
// 对传进来的参数进行进行存储操作(会自动判断是否可以缓存)
- (void)cacheRequsetResponse:(id)responseObject
{
    //是否有值/是否需要缓存/且该参数值没有缓存过
    if (responseObject && _cacheResponse && !_responseFromCache) {
        NSString *urlKey = [self serializeURLKey];
        // 将下面获取的URL拼接路径当作key，存储这个值（这里是调用协议的方法,未验证）
        [[self responseCache] setObject:responseObject forKey:urlKey];
    }
}
// 拼装url key（获取链接URL全路径，并拼接上必要的参数）
- (NSString *)serializeURLKey
{
    NSDictionary *paramters = [self parameters];// 请求参数
    NSArray *ignoreParamterKeys = [self cacheIgnoreParamtersKeys];// 缓存忽略的某些Paramters的key
    if (ignoreParamterKeys) {// 如果有需要忽略的
        NSMutableDictionary *fiterParamters = [NSMutableDictionary dictionaryWithDictionary:paramters];
        [fiterParamters removeObjectsForKeys:ignoreParamterKeys];
        paramters = fiterParamters;
    }
    NSString *URLString = [[TYHttpManager sharedInstance]buildRequstURL:self];
    return [URLString stringByAppendingString:[self serializeParams:paramters]];
}

// 拼接params(返回params拼接成的字符串，已进行URL编码)
- (NSString *)serializeParams:(NSDictionary *)params {
    NSMutableArray *parts = [NSMutableArray array];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id<NSObject> obj, BOOL *stop) {
        //NSString进行URL编码 打印：http://abc.com?aaa=%E4%BD%A0%E5%A5%BD&amp;bbb=tttee
        NSString *encodedKey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *encodedValue = [obj.description stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        NSString *part = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
        [parts addObject: part];
    }];
//    数组转换为字符串
    NSString *queryString = [parts componentsJoinedByString: @"&"];
    return queryString?[NSString stringWithFormat:@"?%@", queryString]:@"";
}

@end
