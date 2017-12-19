//
//  TYResponseCache.m
//  TYHttpManagerDemo
//
//  Created by tany on 16/5/24.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "TYResponseCache.h"
#import <CommonCrypto/CommonDigest.h>
// CommonCrypto 为苹果提供的系统加密接口，支持iOS 和 mac 开发；
@interface TYResponseCache ()

@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSString *cachePath;
@property (nonatomic, strong) dispatch_queue_t queue;

@end
//目录路径的目录名称
static NSString * const TYRequestManagerCacheDirectory = @"TYRequestCacheDirectory";
/*
 //    dispatch_queue_t targetQueue = dispatch_queue_create("targetQueue", DISPATCH_QUEUE_SERIAL);//目标队列 DISPATCH_QUEUE_SERIAL 串行队列
 //    dispatch_queue_t queue1 = dispatch_queue_create("queue1", DISPATCH_QUEUE_SERIAL);//串行队列
     dispatch_queue_t queue2 = dispatch_queue_create("queue1", DISPATCH_QUEUE_CONCURRENT);//并发队列
     dispatch_queue_t queue3 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
 //设置参考
 //    dispatch_set_target_queue(queue2, targetQueue);
 //    dispatch_set_target_queue(queue1, targetQueue);
     dispatch_set_target_queue(queue2, queue3);
 
     dispatch_async(queue2, ^{
         NSLog(@"job3 in");
          NSLog(@"%@",[NSThread currentThread]);
         [NSThread sleepForTimeInterval:2.f];
         NSLog(@"job3 out");
     });
     dispatch_async(queue2, ^{
         NSLog(@"job2 in");
         NSLog(@"%@",[NSThread currentThread]);
         [NSThread sleepForTimeInterval:1.f];
         NSLog(@"job2 out");
     });
     dispatch_async(queue2, ^{
         NSLog(@"job1 in");
         NSLog(@"%@",[NSThread currentThread]);
         [NSThread sleepForTimeInterval:3.f];
         NSLog(@"job1 out");
     });
 //    dispatch_async(queue2, ^{
 //        NSLog(@"job0 in");
 //        NSLog(@"%@",[NSThread currentThread]);
 //        [NSThread sleepForTimeInterval:1.f];
 //        NSLog(@"job0 out");
 //    });
 
 2017-11-29 14:29:56.663948+0800 moreText[53536:2664136] job3 in
 2017-11-29 14:29:56.663970+0800 moreText[53536:2663776] job2 in
 2017-11-29 14:29:56.663977+0800 moreText[53536:2663773] job1 in
 2017-11-29 14:29:56.664363+0800 moreText[53536:2664136] <NSThread: 0x60400046d540>{number = 5, name = (null)}
 2017-11-29 14:29:56.664907+0800 moreText[53536:2663773] <NSThread: 0x60400046d080>{number = 7, name = (null)}
 2017-11-29 14:29:56.664968+0800 moreText[53536:2663776] <NSThread: 0x6000002760c0>{number = 6, name = (null)}
 2017-11-29 14:29:57.668361+0800 moreText[53536:2663776] job2 out
 2017-11-29 14:29:58.669602+0800 moreText[53536:2664136] job3 out
 2017-11-29 14:29:59.667995+0800 moreText[53536:2663773] job1 out
 */
@implementation TYResponseCache
// 该方法是产生一个并行队列，与全局并发队列同优先级，执行方式是异步的
+ (dispatch_queue_t)cacheQueue {
    static dispatch_queue_t cacheQueue = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheQueue = dispatch_queue_create("com.TYResponseCache.cacheQueue", DISPATCH_QUEUE_CONCURRENT); // DISPATCH_QUEUE_CONCURRENT 并发队列
        // 第一个参数为要设置优先级的queue,第二个参数是参照物，既将第一个queue的优先级和第二个queue的优先级设置一样。
        dispatch_set_target_queue(cacheQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    });
    return cacheQueue;
}

- (dispatch_queue_t)queue
{
    return [[self class] cacheQueue];
}
// 在类方法中，self应该这样用
//+ (void)test {
//    [[self class] cacheQueue];
//}

//懒加载
- (NSString *)cachePath
{
    if (_cachePath == nil) {// 返回一个目录路径
        _cachePath = [self createCachesDirectory];
    }
    return _cachePath;
}

- (NSFileManager *)fileManager
{
    // @synchronized是几种iOS多线程同步机制中最慢的一个，同时也是最方便的一个
    //synchronized是使用的递归mutex来做同步。
//    @synchronized(nil)不起任何作用
//    synchronized中传入的object的内存地址，被用作key，通过hash map对应的一个系统维护的递归锁。
    @synchronized (_fileManager) { // 文件的访问线程是安全的
        if (_fileManager == nil) {
            _fileManager = [NSFileManager defaultManager];
        }
        return _fileManager;
    }
}
// 返回一个目录路径
- (NSString *)createCachesDirectory
{
    NSString *cachePathDic = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    在路径的后面拼接一个目录
    NSString *cachePath = [cachePathDic stringByAppendingPathComponent:TYRequestManagerCacheDirectory];
    BOOL isDirectory;
    // fileExistsAtPath:isDirectory:判断是否是一个目录（Directory）
    if (![self.fileManager fileExistsAtPath:cachePath isDirectory:&isDirectory]) {
        __autoreleasing NSError *error = nil;
        //createDirectoryAtPath:@"路径" withIntermediateDirectories:YES／NO 路径创建的时候，YES自动创建路径中缺少的目录，NO不会创建缺少的目录 attributes:属性的字典 error:错误对象
        BOOL created = [self.fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!created) {
            // 创建缓存目录失败，错误：
            NSLog(@"<> - create cache directory failed with error:%@", error);
        }
    }
    return cachePath;
}
// md5加密
- (NSString *)md5String:(NSString *)str
{
    const char *cStr = [str UTF8String];
    if (cStr == NULL) {
        cStr = "";
    }
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}
// 将 Object 用归档方式储存
//如果想将一个自定义对象用归档保存到文件中必须实现NSCoding协议
- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key
{
    NSString *encodedKey = [self md5String:key]; // 返回加密过的key
    NSString *cachePath = self.cachePath;  // 返回目录路径
    dispatch_async([self queue], ^{ // 并行队列，与全局并发队列同优先级，执行方式是异步的
        // 字符串以"/"符号链接（加文件）
        NSString *filePath = [cachePath stringByAppendingPathComponent:encodedKey];
        BOOL written = [NSKeyedArchiver archiveRootObject:object toFile:filePath];
        if (!written) {
            // 设置对象到文件失败
            NSLog(@"<> - set object to file failed");
        }
    });
}
// 读取文件，结果可能为nil
- (id <NSCoding>)objectForKey:(NSString *)key
{
    return [self objectForKey:key overdueDate:nil];
}
//文件读取，同时判断文件是否过期 / overdueDate是否为nil( 为nil，object就有值,不为nil，再判断文件过期否 )
- (id<NSCoding>)objectForKey:(NSString *)key overdueDate:(NSDate *)overdueDate
{
    NSString *encodedKey = [self md5String:key];
    id<NSCoding> object = nil;
    // 拼接文件路径
    NSString *filePath = [self.cachePath stringByAppendingPathComponent:encodedKey];
//    判断文件是否存在
    if ([self.fileManager fileExistsAtPath:filePath] ) {
        //获取文件的创建/修改日期
        NSDate *modificationDate = [self cacheDateFilePath:filePath];
//        在文件读取的时候，判断文件是否过期 / overdueDate是否为nil
        if (!overdueDate || modificationDate.timeIntervalSince1970 - overdueDate.timeIntervalSince1970 >= 0) {
            object = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        } else {
            // 文件缓存过期了 / overdueDate不为nil
            NSLog(@"file cache was overdue");
        }
    }
    return object;
}
// 删除一个文件
- (void)removeObjectForKey:(NSString *)key
{
    NSString *encodedKey = [self md5String:key];
    NSString *filePath = [self.cachePath stringByAppendingPathComponent:encodedKey];
    if ([self.fileManager fileExistsAtPath:filePath]) {
        __autoreleasing NSError *error = nil;
        BOOL removed = [self.fileManager removeItemAtPath:filePath error:&error];
        if (!removed) {
            NSLog(@"<> - remove item failed with error:%@", error);
        }
    }
}
// 删除该文件夹（即所有文件）
- (void)removeAllObjects
{
    __autoreleasing NSError *error;
    BOOL removed = [self.fileManager removeItemAtPath:self.cachePath error:&error];
    if (!removed) {
        NSLog(@" - remove cache directory failed with error:%@", error);
    }
}

#pragma mark - private
//获取文件的创建/修改日期
- (NSDate *)cacheDateFilePath:(NSString *)path {
    // get file attribute
    NSError *attributesRetrievalError = nil;
//    attributesOfItemAtPath 获取文件的大小、文件的内容等属性
    NSDictionary *attributes = [self.fileManager attributesOfItemAtPath:path
                                                              error:&attributesRetrievalError];
    if (!attributes) {
        // 在％@获取文件的属性时出错：％@
        NSLog(@"Error get attributes for file at %@: %@", path, attributesRetrievalError);
        return nil;
    }
    //获取文件的创建日期
    return [attributes fileModificationDate];
}
// 清除某时刻以前的所有缓存
- (void)trimToDate:(NSDate *)date
{
//    __autoreleasing：将指向的对象延迟销毁(还有其他注意的http://blog.csdn.net/junjun150013652/article/details/53149145)
    __autoreleasing NSError *error = nil;
    //contentsOfDirectoryAtURL: 获取一个文件夹的内容(获取所有缓存)
    NSArray *files = [self.fileManager contentsOfDirectoryAtURL:[NSURL URLWithString:self.cachePath]
                                                   includingPropertiesForKeys:@[NSURLContentModificationDateKey]
                                                                      options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                        error:&error];
    if (error) {
        NSLog(@" - get files error:%@", error);
    }
    
    dispatch_async([self queue], ^{ //并行队列，与全局并发队列同优先级，执行方式是异步的
        for (NSURL *fileURL in files) {
            // 返回一个字典，包含了所有指定 key 的对应资源
            NSDictionary *dictionary = [fileURL resourceValuesForKeys:@[NSURLContentModificationDateKey] error:nil];
            // 获取最近修改的日期
            NSDate *modificationDate = [dictionary objectForKey:NSURLContentModificationDateKey];
            // 比较时间大小
            if (modificationDate.timeIntervalSince1970 - date.timeIntervalSince1970 < 0) {
                //修改的日期要比date大
                NSError *error = nil;
                if ([self.fileManager removeItemAtURL:fileURL error:&error]) {
                    NSLog(@"delete cache yes");//删除缓存成功
                } else {
                    NSLog(@"delete cache no %@",fileURL.absoluteString);//删除缓存失败
                    
                }
                
            }
        }
    });
}

@end
