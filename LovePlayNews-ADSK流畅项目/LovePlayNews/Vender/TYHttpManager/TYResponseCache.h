//
//  TYResponseCache.h
//  TYHttpManagerDemo
//
//  Created by tany on 16/5/24.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYResponseCache : NSObject
// 读取文件，结果可能为nil，调用了下面的方法，第二个参数传了nil
- (id <NSCoding>)objectForKey:(NSString *)key;
//文件读取，同时判断文件是否过期 / overdueDate是否为nil( 为nil，object就有值,不为nil，再判断文件过期否 )
- (id <NSCoding>)objectForKey:(NSString *)key overdueDate:(NSDate *)overdueDate;
// 将 Object 用归档方式储存
- (void)setObject:(id <NSCoding>)object forKey:(NSString *)key;
// 删除一个文件
- (void)removeObjectForKey:(NSString *)key;
// 删除该文件夹（即所有文件）
- (void)removeAllObjects;
// 清除某时刻以前的所有缓存
- (void)trimToDate:(NSDate *)date;

@end
