//
//  TYHttpManager.h
//  TYHttpManagerDemo
//
//  Created by tany on 16/5/23.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYRequestProtocol.h"

@interface TYHttpManager : NSObject

@property (nonatomic, strong) TYRequstConfigure *requestConfiguration;// session configure
// 创建单利对象
+ (TYHttpManager *)sharedInstance;
// 添加/发生一个请求 (同步执行)
- (void)addRequest:(id<TYRequestProtocol>)request;
// 请求取消事件（只有一个方法调用，抽取在这里）
- (void)cancleRequest:(id<TYRequestProtocol>)request;
// 获取 request 保存的链接全路径
- (NSString *)buildRequstURL:(id<TYRequestProtocol>)request;

@end

/*
 特点：（2017.11.28 15:12 温州）
 1. 协议通过参数传递进来，该参数拥有协议的所有方法和定义(需导入协议头)
 需要注意：该参数对协议方法的调用引发了其他地方协议方法实现的方法的调用，观察该逻辑的实现方式
 2. 其次在 “addRequest:” 方法中，对各模块封装的细节中可以感受一下设计理念，如果是你，是否可以考虑到这些细节？
 3. 该类是对请求的封装抽取，具体好处需要在其他地方感受
 
 知识点：
 1. 对 dispatch_set_target_queue 的使用，预计是防止在频繁的数据请求中线程凌乱，无法控制
 2. 在外面暴露属性，在内部 init 方法中设置默认值，不同于 swift ，封装组件的时候应该常用
 3. 方法的抽取，在 addRequest: 的方法实现中，对每个模块处理进行封装，各成一体，方便优化调整各模块，单一思考
 4. 里面 AFN 的许多参数设置，平时也不一定用到，可以借鉴
 ...
 */
