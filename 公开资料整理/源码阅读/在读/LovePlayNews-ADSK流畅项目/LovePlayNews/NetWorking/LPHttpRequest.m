//
//  TYModelRequest.m
//  TYHttpManagerDemo
//
//  Created by tany on 16/5/24.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "LPHttpRequest.h"

@implementation LPHttpRequest
/*
 @dynamic与@synthesize的区别:
 
 @property有两个对应的词，一个是@synthesize，一个是@dynamic。如果@synthesize和@dynamic都没写，那么默认的就是@syntheszie var = _var;
 
 @synthesize的语义是如果你没有手动实现setter方法和getter方法，那么编译器会自动为你加上这两个方法。
 
 @dynamic告诉编译器,属性的setter与getter方法由用户自己实现，不自动生成。（当然对于readonly的属性只需提供getter即可）。假如一个属性被声明为@dynamic var，然后你没有提供@setter方法和@getter方法，编译的时候没问题，但是当程序运行到instance.var =someVar，由于缺setter方法会导致程序崩溃；或者当运行到 someVar = var时，由于缺getter方法同样会导致崩溃。编译时没问题，运行时才执行相应的方法，这就是所谓的动态绑定。
 */

// 该属性在父类已经有了，所有不需要getter/setter方法
@dynamic responseObject;

- (instancetype)init
{
    if (self = [super init]) {
        self.baseURL = BaseURL;
        self.responseParser = [[TYResponseObject alloc]init];
    }
    return self;
}

- (instancetype)initWithModelClass:(Class)modelClass
{
    if (self = [super init]) {
        self.baseURL = BaseURL;
        self.responseParser = [[LPResponseObject alloc]initWithModelClass:modelClass];
    }
    return self;
}

+ (instancetype)requestWithModelClass:(Class)modelClass
{
    return [[self alloc]initWithModelClass:modelClass];
}

@end
