// The MIT License (MIT)
//
// Copyright (c) 2015-2016 forkingdog ( https://github.com/forkingdog )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import "UITableView+FDIndexPathHeightCache.h"
#import <objc/runtime.h>
//#define 是宏命令，在编译前，由预处理器做替代，如同文本编辑的替代命令，把程序中的所有遇到的词，全部替代。
//#define PINT int*
//就是把所有的词 PINT 替换成 int * ，替换完毕再编译。
//typedef int* pint; 是语句，由编译器在编译过程中编译处理。
//常见用法：先看：http://blog.sina.com.cn/s/blog_790bb7190101bvcz.html
//再看：https://zhidao.baidu.com/question/181081049.html
typedef NSMutableArray<NSMutableArray<NSNumber *> *> FDIndexPathHeightsBySection;

@interface FDIndexPathHeightCache ()
// 数组属性
//纵向 （在竖屏下）这个数组里没有装@1，本来应该是 @1 ，结果因为是 @1，后面才进行了重新赋值
@property (nonatomic, strong) FDIndexPathHeightsBySection *heightsBySectionForPortrait;
//横向 （在竖屏下）这个数组里全是@1
@property (nonatomic, strong) FDIndexPathHeightsBySection *heightsBySectionForLandscape;
@end

@implementation FDIndexPathHeightCache

- (instancetype)init {
    self = [super init];
    if (self) {
        _heightsBySectionForPortrait = [NSMutableArray array];
        _heightsBySectionForLandscape = [NSMutableArray array];
    }
    return self;
}
/*
 UIDeviceOrientation      是机器硬件的当前旋转方向   这个你只能取值 不能设置
 UIInterfaceOrientation   是你程序界面的当前旋转方向   这个可以设置
 Portrait 表示 纵向，Landscape 表示 横向。
 http://blog.csdn.net/qq515383106/article/details/8765360
 */

- (FDIndexPathHeightsBySection *)heightsBySectionForCurrentOrientation {
//    根据设备的朝向，决定返回哪个数组（是否是纵向）
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? self.heightsBySectionForPortrait: self.heightsBySectionForLandscape;
}
///把定义的两个数组回调
- (void)enumerateAllOrientationsUsingBlock:(void (^)(FDIndexPathHeightsBySection *heightsBySection))block {
    block(self.heightsBySectionForPortrait);
    block(self.heightsBySectionForLandscape);
}

- (BOOL)existsHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];// 根据 indexPath 初始化 数组属性内的元素
    NSNumber *number = self.heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row];// 拿到这个数组里面的具体元素，判断是否为 @1
    NSLog(@"%@",number);
    return ![number isEqualToNumber:@-1];// 如果不相等，返回 YES
}

- (void)cacheHeight:(CGFloat)height byIndexPath:(NSIndexPath *)indexPath {
    self.automaticallyInvalidateEnabled = YES;
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];// 初始化 数组
//    根据设备的朝向,取出数组，重新赋值（缓存cell高度）
    self.heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row] = @(height);
}

- (CGFloat)heightForIndexPath:(NSIndexPath *)indexPath {
    // 根据 indexPath 初始化 数组属性内的元素
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    NSNumber *number = self.heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row];
#if CGFLOAT_IS_DOUBLE              // 这个判断方法可以
    return number.doubleValue;
#else
    return number.floatValue;
#endif
}

- (void)invalidateHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    [self enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
        heightsBySection[indexPath.section][indexPath.row] = @-1;
    }];
}

- (void)invalidateAllHeightCache {
    [self enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
        [heightsBySection removeAllObjects];
    }];
}
/*
 遍历方式的优点:
 1.遍历顺序有正序/倒序/并发混序三种, 可根据枚举值控制比 for循环方便许多.
 2.遍历中自带 *stop参数, 跳出方便.
 3.可以在遍历的 block中增删数据, 比 forin 遍历方便许多
 4.在庞大的数据量下, 此方式是比 for循环, forin 等方式,要快许多的方式.在其执行过程中可以利用到多核cpu的优势
 
-enumerateKeysAndObjectsWithOptions:usingBlock:----------------------字典-------------------
        NSEnumerationConcurrent 当前的排序状态
        NSEnumerationReverse    倒序排列

    [tmpdic enumerateKeysAndObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOLBOOL * _Nonnull stop) {
        NSLog(@"tmpdis2:key=%@ value=%@\n",key,obj);  // (字典是无顺序的)
    }];

- enumerateKeysAndObjectsUsingBlock:--------------------------字典----------------------------
   NSDictionary有一个方法叫enumerateKeysAndObjectsUsingBlock，这个block携带了三个参数，它会遍历dictionary并把里面所有的key和value一组一组的展示给你，每组都会执行这个block。直到通过重新赋值那个BOOL *stop来停止运行，停止遍历同时停止调用block。
 
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:@"obj1",@"key1",@"obj2",@"key2", nil];
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSLog(@"value for key %@ is %@ ", key, value);
        if ([@"key2" isEqualToString:key]) {
            *stop = YES;
        }
    }];
- enumerateObjectsWithOptions:usingBlock:---------------------------数组----------------------
 option参数:
 NSEnumerationReverse 倒序执行
 NSEnumerationConcurrent 并行发生, 并发混序
 
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5", nil];
    [arr enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%ld===%@",idx,obj);
        if (idx == 3){
            *stop = YES;
        }
    }];
 
- enumerateObjectsAtIndexes:options:usingBlock:---------------------数组---------------------
 根据indexSet进行倒序/并发混序的遍历方法
 
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5", nil];
    //根据indexSet 中包含的下标, 在 arr 中进行遍历
    //    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:1];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)];
    [arr enumerateObjectsAtIndexes:indexSet options:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%ld===%@",idx,obj);
    }];
 
-enumerateObjectsUsingBlock:----------------------------数组----------------------------
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5", nil];
    //按顺序对 arr 进行遍历
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%ld===%@",idx,obj);
        if (idx == 4){
            *stop = YES;
        }
    }];
 
 -------------------------------字符串--------------------------------------------
    //字符串
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"girl" ofType:@"txt"];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSString *fileStr = [[NSString alloc]initWithData:fileData encoding:NSUTF8StringEncoding];
 
    //一行一行的读取
    [fileStr enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOLBOOL * _Nonnull stop) {
        NSLog(@"%@\n",line);
    }];
 
    //一个字符一字符的读取 (NSStringEnumerationByWords)
    [fileStr enumerateSubstringsInRange:NSMakeRange(0, fileStr.length) options:NSStringEnumerationByWords usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOLBOOL * _Nonnull stop) {
        NSLog(@"tmp111===%@",substring);
    }];
 
 
 
 --------------------NSEnumerator枚举器的用法：-------------------------------------
 1、字典中的：
 - (NSEnumerator<KeyType> *)keyEnumerator;//获取所有key值
 - (NSEnumerator<ObjectType> *)objectEnumerator;//获取所有value值
 2、数组中的
 - (NSEnumerator<ObjectType> *)objectEnumerator;//正向遍历数组    ——>完全可用 for in 语法代替
 - (NSEnumerator<ObjectType> *)reverseObjectEnumerator;//反向遍历数组,从后往前看
 
 具体细节：http://blog.csdn.net/queenlysun/article/details/60958868
 */

// 初始化 数组
- (void)buildCachesAtIndexPathsIfNeeded:(NSArray *)indexPaths {
    // Build every section array or row array which is smaller than given index path.
//    构建小于给定索引路径的每个部分数组或行数组。
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        // 给数组属性根据section添加元素(空数组)
        [self buildSectionsIfNeeded:indexPath.section];
        // 给数组属性的元素(空数组)根据row再添加元素(NSNumber(@-1))
        [self buildRowsIfNeeded:indexPath.row inExistSection:indexPath.section];
    }];
}
// 设置数组内属性
- (void)buildSectionsIfNeeded:(NSInteger)targetSection {
//    返回定义的两个数组(这里为空数组，没有元素)
    [self enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
        NSLog(@"%@",heightsBySection);
//        这里根据 cell 组的多少决定循环次数
        for (NSInteger section = 0; section <= targetSection; ++section) {
            if (section >= heightsBySection.count) {
                //根据循环次数，内部添加几个元素(空数组)
                heightsBySection[section] = [NSMutableArray array];
            }
        }
    }];
}
// 设置数组内属性的元素
- (void)buildRowsIfNeeded:(NSInteger)targetRow inExistSection:(NSInteger)section {
    //    返回定义的两个数组(这里已经有元素(空数组))
    [self enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
//        拿到数组
        NSLog(@"%@",heightsBySection);
        NSMutableArray<NSNumber *> *heightsByRow = heightsBySection[section];
        for (NSInteger row = 0; row <= targetRow; ++row) {
            if (row >= heightsByRow.count) {
                heightsByRow[row] = @-1;// 给数组里的元素(空数组)根据cell的个数，添加 NSNumber(@-1) 属性
            }
        }
    }];
}

@end

@implementation UITableView (FDIndexPathHeightCache)

// 这种写法值得注意
- (FDIndexPathHeightCache *)fd_indexPathHeightCache {
    FDIndexPathHeightCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        cache = [FDIndexPathHeightCache new];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

@end

// We just forward primary call, in crash report, top most method in stack maybe FD's,
// but it's really not our bug, you should check whether your table view's data source and
// displaying cells are not matched when reloading.
static void __FD_TEMPLATE_LAYOUT_CELL_PRIMARY_CALL_IF_CRASH_NOT_OUR_BUG__(void (^callout)(void)) {
    callout();
}
#define FDPrimaryCall(...) do {__FD_TEMPLATE_LAYOUT_CELL_PRIMARY_CALL_IF_CRASH_NOT_OUR_BUG__(^{__VA_ARGS__});} while(0)

@implementation UITableView (FDIndexPathHeightCacheInvalidation)

- (void)fd_reloadDataWithoutInvalidateIndexPathHeightCache {
    FDPrimaryCall([self fd_reloadData];);
}

+ (void)load {
    // All methods that trigger height cache's invalidation
    // 所有触发高度缓存失效的方法，该方式有使用多次
    SEL selectors[] = {
        @selector(reloadData),
        @selector(insertSections:withRowAnimation:),
        @selector(deleteSections:withRowAnimation:),
        @selector(reloadSections:withRowAnimation:),
        @selector(moveSection:toSection:),
        @selector(insertRowsAtIndexPaths:withRowAnimation:),
        @selector(deleteRowsAtIndexPaths:withRowAnimation:),
        @selector(reloadRowsAtIndexPaths:withRowAnimation:),
        @selector(moveRowAtIndexPath:toIndexPath:)
    };
    
    for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
        SEL originalSelector = selectors[index];
        SEL swizzledSelector = NSSelectorFromString([@"fd_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
        Method originalMethod = class_getInstanceMethod(self, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)fd_reloadData {
    if (self.fd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.fd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
            [heightsBySection removeAllObjects];
        }];
    }
    FDPrimaryCall([self fd_reloadData];);
}

- (void)fd_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.fd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.fd_indexPathHeightCache buildSectionsIfNeeded:section];
            [self.fd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
                [heightsBySection insertObject:[NSMutableArray array] atIndex:section];
            }];
        }];
    }
    FDPrimaryCall([self fd_insertSections:sections withRowAnimation:animation];);
}

- (void)fd_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.fd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.fd_indexPathHeightCache buildSectionsIfNeeded:section];
            [self.fd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
                [heightsBySection removeObjectAtIndex:section];
            }];
        }];
    }
    FDPrimaryCall([self fd_deleteSections:sections withRowAnimation:animation];);
}

- (void)fd_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.fd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock: ^(NSUInteger section, BOOL *stop) {
            [self.fd_indexPathHeightCache buildSectionsIfNeeded:section];
            [self.fd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
                [heightsBySection[section] removeAllObjects];
            }];

        }];
    }
    FDPrimaryCall([self fd_reloadSections:sections withRowAnimation:animation];);
}

- (void)fd_moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    if (self.fd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.fd_indexPathHeightCache buildSectionsIfNeeded:section];
        [self.fd_indexPathHeightCache buildSectionsIfNeeded:newSection];
        [self.fd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
            [heightsBySection exchangeObjectAtIndex:section withObjectAtIndex:newSection];
        }];
    }
    FDPrimaryCall([self fd_moveSection:section toSection:newSection];);
}

- (void)fd_insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.fd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.fd_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.fd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
                [heightsBySection[indexPath.section] insertObject:@-1 atIndex:indexPath.row];
            }];
        }];
    }
    FDPrimaryCall([self fd_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];);
}

- (void)fd_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.fd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.fd_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        
        NSMutableDictionary<NSNumber *, NSMutableIndexSet *> *mutableIndexSetsToRemove = [NSMutableDictionary dictionary];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            NSMutableIndexSet *mutableIndexSet = mutableIndexSetsToRemove[@(indexPath.section)];
            if (!mutableIndexSet) {
                mutableIndexSet = [NSMutableIndexSet indexSet];
                mutableIndexSetsToRemove[@(indexPath.section)] = mutableIndexSet;
            }
            [mutableIndexSet addIndex:indexPath.row];
        }];
        
        [mutableIndexSetsToRemove enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSIndexSet *indexSet, BOOL *stop) {
            [self.fd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
                [heightsBySection[key.integerValue] removeObjectsAtIndexes:indexSet];
            }];
        }];
    }
    FDPrimaryCall([self fd_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];);
}

- (void)fd_reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.fd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.fd_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.fd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
                heightsBySection[indexPath.section][indexPath.row] = @-1;
            }];
        }];
    }
    FDPrimaryCall([self fd_reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];);
}

- (void)fd_moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (self.fd_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.fd_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:@[sourceIndexPath, destinationIndexPath]];
        [self.fd_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(FDIndexPathHeightsBySection *heightsBySection) {
            NSMutableArray<NSNumber *> *sourceRows = heightsBySection[sourceIndexPath.section];
            NSMutableArray<NSNumber *> *destinationRows = heightsBySection[destinationIndexPath.section];
            NSNumber *sourceValue = sourceRows[sourceIndexPath.row];
            NSNumber *destinationValue = destinationRows[destinationIndexPath.row];
            sourceRows[sourceIndexPath.row] = destinationValue;
            destinationRows[destinationIndexPath.row] = sourceValue;
        }];
    }
    FDPrimaryCall([self fd_moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];);
}

@end
