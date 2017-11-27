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

#import "UITableView+FDTemplateLayoutCell.h"
#import <objc/runtime.h>

@implementation UITableView (FDTemplateLayoutCell)
//(内部方法) 经过重重计算，得出 cell 最后的高度
- (CGFloat)fd_systemFittingHeightForConfiguratedCell:(UITableViewCell *)cell {
    CGFloat contentViewWidth = CGRectGetWidth(self.frame);// 该方法是 tableView 的分类，所以可以拿到宽带
//    -----------------------------0. 确定cell总宽度为tableView的宽度--------------------
    
    CGRect cellBounds = cell.bounds;
    cellBounds.size.width = contentViewWidth; // 强行把父控件的宽度设置成 cell 的宽度
    cell.bounds = cellBounds;
    
    CGFloat accessroyWidth = 0;
//    --------------------------1. 总宽度减去附件视图或系统附件的宽度--------------------
    
    // If a cell has accessory view or system accessory type, its content view's width is smaller
//    如果单元格具有附件视图或系统附件类型，则其内容视图的宽度较小
    // than cell's by some fixed values.
    if (cell.accessoryView) { // 只有自定义了添加的视图才进来
        accessroyWidth = 16 + CGRectGetWidth(cell.accessoryView.frame);
    } else {
//        代码写法应该注意
//        经测试，systemAccessoryWidths 里面的数组不可以乱写，必须是系统自带的枚举，每一个值还必须出自同一个枚举
        static const CGFloat systemAccessoryWidths[] = { // 猜测里面的数字应该是对应各控件的实际宽度。经测试，改变值没影响
            [UITableViewCellAccessoryNone] = 0,
            [UITableViewCellAccessoryDisclosureIndicator] = 34,
            [UITableViewCellAccessoryDetailDisclosureButton] = 68,
            [UITableViewCellAccessoryCheckmark] = 40,
            [UITableViewCellAccessoryDetailButton] = 48
        };
        accessroyWidth = systemAccessoryWidths[cell.accessoryType];
//        NSLog(@"%ld",(long)cell.accessoryType); //此处打印 1和3，对应着外面的使用
    }
//    得到减去以上控件宽度后宽度
    contentViewWidth -= accessroyWidth;

    
    // 如果不使用自动布局，则必须覆盖“-sizeThatFits：”，以便自己提供合适的大小。
    // 这是iOS8自定义单元实现中使用的高度计算通道。
    //
    // 1. 尝试“ - systemLayoutSizeFittingSize”：首先。 （如果'fd_enforceFrameLayout'设置为YES，请跳过此步骤。）
    // 2. 如果在使用AutoLayout时步骤1仍返回0，则警告一次
    // 3. 尝试“ - sizeThatFits：”如果步骤1返回0
    // 4. 使用有效的高度或默认行高（44）（如果不存在）
//    ---------------------------------2. 如果选择自动布局，进入--------------------------
    CGFloat fittingHeight = 0;
//    fd_enforceFrameLayout: 默认就是 NO,自动布局,不调用 sizeThatFits 方法，由外界调用决定是否自动布局
    if (!cell.fd_enforceFrameLayout && contentViewWidth > 0) {
        // 添加硬宽度约束以使动态内容视图（如标签）垂直展开
        // 以流动布局方式水平生长。
        NSLayoutConstraint *widthFenceConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:contentViewWidth];//如果您的方程式没有第二个视图和属性，请使用nil和NSLayoutAttributeNotAnAttribute。意思是 cell.contentView的宽度 == contentViewWidth

        // 在iOS 10.3之后的[bug修复]中，Auto Layout引擎将在单元格的内容视图中添加一个额外的0宽度约束，以避免在内容视图的左侧，右侧，顶部和底部增加约束。
        static BOOL isSystemVersionEqualOrGreaterThen10_2 = NO;// 用于判断系统版本号
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
//            NSOrderedAscending 小
            // 获取系统版本 和 10.2 比较，如果不比 10.2 小，为 YES
            isSystemVersionEqualOrGreaterThen10_2 = [UIDevice.currentDevice.systemVersion compare:@"10.2" options:NSNumericSearch] != NSOrderedAscending;
        });
        
        NSArray<NSLayoutConstraint *> *edgeConstraints;
        if (isSystemVersionEqualOrGreaterThen10_2) { //比 10.2 大，就为 YES
            // 为了避免冲突，使宽度约束比要求更软（1000）
            widthFenceConstraint.priority = UILayoutPriorityRequired - 1;// 降低约束的优先级
            
            // Build edge constraints
            NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
            NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeRight multiplier:1.0 constant:accessroyWidth];// contentView的右边 == cell的右边 + accessroyWidth
            NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
            NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
            edgeConstraints = @[leftConstraint, rightConstraint, topConstraint, bottomConstraint];
            [cell addConstraints:edgeConstraints];
        }
        
        [cell.contentView addConstraint:widthFenceConstraint];
//    ---------------------------------2.1. 得到系统计算的高度，删除约束--------------------------
        // Auto layout engine does its math
        //Auto layout 中用来计算View的size的，该方法需要 autolayout
        fittingHeight = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        
        // Clean-ups
//        计算高度后删除约束
        [cell.contentView removeConstraint:widthFenceConstraint];
        if (isSystemVersionEqualOrGreaterThen10_2) {// 如果上面加了这个约束，也要删除
            [cell removeConstraints:edgeConstraints];
        }
//        传递打印高度信息
        [self fd_debugLog:[NSString stringWithFormat:@"calculate using system fitting size (AutoLayout) - %@", @(fittingHeight)]];
    }
//    --------------------3. 如果高度等于 0 ，没有选择自动布局，进入手动布局--------------------------
    if (fittingHeight == 0) {
#if DEBUG
        // Warn if using AutoLayout but get zero height.
//        警告如果使用AutoLayout但得到零高度。
//        避免选择自动布局高度还等于 0 的情况
        if (cell.contentView.constraints.count > 0) {
            //_cmd：fd_systemFittingHeightForConfiguratedCell:
            if (!objc_getAssociatedObject(self, _cmd)) {
                NSLog(@"[FDTemplateLayoutCell] Warning once only: Cannot get a proper cell height (now 0) from '- systemFittingSize:'(AutoLayout). You should check how constraints are built in cell, making it into 'self-sizing' cell.");
//                [FDTemplateLayoutCell]仅一次警告：无法从' - systemFittingSize：'（AutoLayout）获取正确的单元格高度（现在为0）。 你应该检查如何在单元格中建立约束，使其成为“自定义”单元格。
                objc_setAssociatedObject(self, _cmd, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
#endif
        // Try '- sizeThatFits:' for frame layout.
        // Note: fitting height should not include separator view.
//        重写了该方法，返回总高度
        fittingHeight = [cell sizeThatFits:CGSizeMake(contentViewWidth, 0)].height;
//        传递打印高度信息
        [self fd_debugLog:[NSString stringWithFormat:@"calculate using sizeThatFits - %@", @(fittingHeight)]];
    }
//    --------------------4. 都是 0 ，那就默认 44 --------------------------
    // Still zero height after all above.
//    经过手动和自动布局，都是 0 ，那就是默认 44
    if (fittingHeight == 0) {
        // Use default row height.
        fittingHeight = 44;
    }
//    --------------------5. 是否添加额外的 1px  --------------------------
    // Add 1px extra space for separator line if needed, simulating default UITableViewCell.
//    如果需要，为分隔线添加1px额外空间，模拟默认的UITableViewCell。
    if (self.separatorStyle != UITableViewCellSeparatorStyleNone) {
        fittingHeight += 1.0 / [UIScreen mainScreen].scale;
    }
//    --------------------6. 返回最后的高度  --------------------------
    return fittingHeight;
}

//(外部方法)
- (__kindof UITableViewCell *)fd_templateCellForReuseIdentifier:(NSString *)identifier {
//    NSAssert(condition, desc)
//    condition是条件表达式，值为YES或NO；desc为异常描述，通常为NSString。
//    当conditon为YES时程序继续运行，为NO时，则抛出带有desc描述的异常信息。
//    NSAssert()可以出现在程序的任何一个位置。
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);//如果小于 0 就警告
    
    NSMutableDictionary<NSString *, UITableViewCell *> *templateCellsByIdentifiers = objc_getAssociatedObject(self, _cmd);
    if (!templateCellsByIdentifiers) {// 如果没有值，进入，动态创建一个属性，并设置一个空值
        templateCellsByIdentifiers = @{}.mutableCopy;
        objc_setAssociatedObject(self, _cmd, templateCellsByIdentifiers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    UITableViewCell *templateCell = templateCellsByIdentifiers[identifier];
    
    if (!templateCell) {// 如果取出的 cell 为空，进来（结果只进来了一次）
//        根据标识符取出 cell
        templateCell = [self dequeueReusableCellWithIdentifier:identifier];
//        警告：cell 必须已经注册
        NSAssert(templateCell != nil, @"Cell must be registered to table view for identifier - %@", identifier);
        templateCell.fd_isTemplateLayoutCell = YES;//     ?
        //        是否将AutoresizingMask转为Autolayout的约束
        templateCell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
//        将 cell 设置成字典的值
        templateCellsByIdentifiers[identifier] = templateCell;
        [self fd_debugLog:[NSString stringWithFormat:@"layout cell created - %@", identifier]];
    }
    return templateCell;
}
// (外部方法)cell的高度
- (CGFloat)fd_heightForCellWithIdentifier:(NSString *)identifier configuration:(void (^)(id cell))configuration {
    if (!identifier) {// 如果 identifier 为空，返回 0
        return 0;
    }
//    调用上面的方法，拿到 cell
    UITableViewCell *templateLayoutCell = [self fd_templateCellForReuseIdentifier:identifier];
    
    // Manually calls to ensure consistent behavior with actual cells. (that are displayed on screen)
//    手动调用以确保与实际单元格一致的行为。 （显示在屏幕上）
//    1. 当被重用的cell将要显示时，会调用这个方法，这个方法最大的用武之地是当你自定义的cell上面有图片时，如果产生了重用，图片可能会错乱（当图片来自异步下载时及其明显），这时我们可以重写这个方法把内容抹掉。
//    2. 在从dequeueReusableCellWithIdentifier取出之后,如果需要做一些额外的计算,比如说计算cell高度, 可以手动调用 prepareForReuse方法.手动调用,以确保与实际cell(显示在屏幕上)行为一致。
    [templateLayoutCell prepareForReuse];
    
    // Customize and provide content for our template cell.
//    自定义并为我们的模板单元格提供内容。
    if (configuration) { // 进入，回调
        configuration(templateLayoutCell);
    }
    
//    return cell的高度
    return [self fd_systemFittingHeightForConfiguratedCell:templateLayoutCell];
}
// (外部方法)cell的高度---------通过数组缓存cell高度
- (CGFloat)fd_heightForCellWithIdentifier:(NSString *)identifier cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(id cell))configuration {
    if (!identifier || !indexPath) {// 如果都为空，返回 0
        return 0;
    }
//-----------------------------1.是否已经缓存，缓存了就直接返回---------------------------------
    // Hit cache
//    因为都是同一类或父类的分类，所以可以在这个分类拿到另一个分类 .h 文件的属性
    if ([self.fd_indexPathHeightCache existsHeightAtIndexPath:indexPath]) {// 元素不等于 @1 才进来
//        因为已经有缓存的 Cell 高度了，所以元素不等于 @1，@1是初始值
        [self fd_debugLog:[NSString stringWithFormat:@"hit cache by index path[%@:%@] - %@", @(indexPath.section), @(indexPath.row), @([self.fd_indexPathHeightCache heightForIndexPath:indexPath])]];
//        不等于 @1 就此 return
        return [self.fd_indexPathHeightCache heightForIndexPath:indexPath];
    }
//    -------------------------2.没有缓存，就计算，再缓存，返回--------------------------------
//    这里调用上面的方法，拿到高度
    CGFloat height = [self fd_heightForCellWithIdentifier:identifier configuration:configuration];
//    （缓存cell高度）
    [self.fd_indexPathHeightCache cacheHeight:height byIndexPath:indexPath];
    [self fd_debugLog:[NSString stringWithFormat: @"cached by index path[%@:%@] - %@", @(indexPath.section), @(indexPath.row), @(height)]];
    return height;
}
// (外部方法)cell的高度------通过字典缓存cell高度-----------和上面类似
- (CGFloat)fd_heightForCellWithIdentifier:(NSString *)identifier cacheByKey:(id<NSCopying>)key configuration:(void (^)(id cell))configuration {
    if (!identifier || !key) {
        return 0;
    }
    
    // Hit cache
    if ([self.fd_keyedHeightCache existsHeightForKey:key]) {
        CGFloat cachedHeight = [self.fd_keyedHeightCache heightForKey:key];
        [self fd_debugLog:[NSString stringWithFormat:@"hit cache by key[%@] - %@", key, @(cachedHeight)]];
        return cachedHeight;
    }
    
    CGFloat height = [self fd_heightForCellWithIdentifier:identifier configuration:configuration];
    [self.fd_keyedHeightCache cacheHeight:height byKey:key];
    [self fd_debugLog:[NSString stringWithFormat:@"cached by key[%@] - %@", key, @(height)]];
    
    return height;
}

@end

@implementation UITableView (FDTemplateLayoutHeaderFooterView)

- (__kindof UITableViewHeaderFooterView *)fd_templateHeaderFooterViewForReuseIdentifier:(NSString *)identifier {
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);
    
    NSMutableDictionary<NSString *, UITableViewHeaderFooterView *> *templateHeaderFooterViews = objc_getAssociatedObject(self, _cmd);
    if (!templateHeaderFooterViews) {
        templateHeaderFooterViews = @{}.mutableCopy;
        objc_setAssociatedObject(self, _cmd, templateHeaderFooterViews, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    UITableViewHeaderFooterView *templateHeaderFooterView = templateHeaderFooterViews[identifier];
    
    if (!templateHeaderFooterView) {
        templateHeaderFooterView = [self dequeueReusableHeaderFooterViewWithIdentifier:identifier];
        NSAssert(templateHeaderFooterView != nil, @"HeaderFooterView must be registered to table view for identifier - %@", identifier);
        templateHeaderFooterView.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        templateHeaderFooterViews[identifier] = templateHeaderFooterView;
        [self fd_debugLog:[NSString stringWithFormat:@"layout header footer view created - %@", identifier]];
    }
    
    return templateHeaderFooterView;
}

- (CGFloat)fd_heightForHeaderFooterViewWithIdentifier:(NSString *)identifier configuration:(void (^)(id))configuration {
    UITableViewHeaderFooterView *templateHeaderFooterView = [self fd_templateHeaderFooterViewForReuseIdentifier:identifier];
    
    NSLayoutConstraint *widthFenceConstraint = [NSLayoutConstraint constraintWithItem:templateHeaderFooterView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:CGRectGetWidth(self.frame)];
    [templateHeaderFooterView addConstraint:widthFenceConstraint];
    CGFloat fittingHeight = [templateHeaderFooterView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    [templateHeaderFooterView removeConstraint:widthFenceConstraint];
    
    if (fittingHeight == 0) {
        fittingHeight = [templateHeaderFooterView sizeThatFits:CGSizeMake(CGRectGetWidth(self.frame), 0)].height;
    }
    
    return fittingHeight;
}

@end

@implementation UITableViewCell (FDTemplateLayoutCell)

- (BOOL)fd_isTemplateLayoutCell {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setFd_isTemplateLayoutCell:(BOOL)isTemplateLayoutCell {
    objc_setAssociatedObject(self, @selector(fd_isTemplateLayoutCell), @(isTemplateLayoutCell), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)fd_enforceFrameLayout {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setFd_enforceFrameLayout:(BOOL)enforceFrameLayout {
    objc_setAssociatedObject(self, @selector(fd_enforceFrameLayout), @(enforceFrameLayout), OBJC_ASSOCIATION_RETAIN);
    
//    由OBJC_ASSOCIATION_RETAIN所引发的思考。。。
//    这个属性是指：关联时采用的协议，一般是   OBJC_ASSOCIATION_RETAIN_NONATOMIC
//    OBJC_ASSOCIATION_ASSIGN = 0              字面意思：assign
//    OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1            retain nonatomic
//    OBJC_ASSOCIATION_COPY_NONATOMIC = 3              copy nonatomic
//    OBJC_ASSOCIATION_RETAIN = 01401                  retain
//    OBJC_ASSOCIATION_COPY = 01403                    copy
//    从字面意思看，大概都懂了！
    
    // object:给哪个对象添加属性
    // key:属性名,根据key去获取关联的对象 ,void * == id
    // value:关联的值
    // policy:策越

}

@end
