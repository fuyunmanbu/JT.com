//
//  TYResponseObject.m
//  LovePlayNews
//
//  Created by tany on 16/9/7.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYResponseObject.h"

@interface TYResponseObject ()

@property (nonatomic, assign) Class modelClass;

@end

@implementation TYResponseObject

- (instancetype)initWithModelClass:(Class)modelClass
{
    if (self = [super init]) {
        _modelClass = modelClass;//(记录模型类)
    }
    return self;
}
// 无效返回NO，有效返回YES
- (BOOL)isValidResponse:(id)response request:(TYHttpRequest *)request error:(NSError *__autoreleasing *)error
{
    if (!response) {
        // response 是 nil
        *error = [NSError errorWithDomain:@"response is nil" code: -1 userInfo:nil];
        return NO;
    }
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)request.dataTask.response;
    NSInteger responseStatusCode = [httpResponse statusCode];
    
    // StatusCode
    if (responseStatusCode < 200 || responseStatusCode > 299) {
        // 无效的http请求
        *error = [NSError errorWithDomain:@"invalid http request" code: responseStatusCode userInfo:nil];
        return NO;
    }
    return YES;
}

- (id)parseResponse:(id)response request:(TYHttpRequest *)request
{
    _data = response;
    return  self;
}
/*
 在使用NSObject类替换%@占位符时，会调用description相关方法，所以只要实现此方法，就可以起到修改打印内容的作用。因此对于系统的类，才用增加分类的方式实现，而自己的类，就是增加方法。
 
 优先级： (descriptionWithLocale:indent:) > (description)
 所以，例如NSDictionary，NSArray等，已经实现了- (NSString )descriptionWithLocale:(id)locale indent:(NSUInteger)level此方法，所以如果实现- (NSString )description则没有效果。
 */
- (NSString *)description
{
    // 设置控制台打印的结果：状态码 + 消息
    return [NSString stringWithFormat:@"\nstatus:%d\nmsg:%@\n",(int)_status,_msg?_msg : @""];
}

@end
