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
// 向任何获得本软件和相关文档文件（“软件”）副本的人免费授予许可，无限制地处理本软件，包括但不限于使用，复制，修改的权利，合并，发布，分发，再许可和/或出售本软件的副本，并允许提供本软件的人员遵守以下条件：
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 上述版权声明和本许可声明应包含在本软件的所有副本或重要部分。
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// 该软件“按原样”提供，不附带明示或暗示的任何形式的保证，包括但不限于适销性，适用于特定用途和非侵权的担保。在任何情况下，作者或版权所有者均不对任何索赔，损害或其他责任负责，无论是否因与本软件或本软件的使用或其他交易相关的任何合同，侵权行为或其他方面的行为软件。

#import <UIKit/UIKit.h>
#import "UITableView+FDKeyedHeightCache.h"
#import "UITableView+FDIndexPathHeightCache.h"
#import "UITableView+FDTemplateLayoutCellDebug.h"

@interface UITableView (FDTemplateLayoutCell)

/// 访问内部模板布局单元格以获得给定的重用标识符。 通常，您不需要知道这些模板布局单元格。
///
/// @param 标识符必须注册的单元格的重用标识符。
///
- (__kindof UITableViewCell *)fd_templateCellForReuseIdentifier:(NSString *)identifier;

/// 返回由重用标识符指定的类型的单元格的高度，并由配置块进行配置。
///
/// 使用自动布局，单元格将以相对于其动态内容的固定宽度，垂直扩展的方式进行布局。 因此，必须将单元设置为self-satisfied，即其宽度等于tableview的内容总是确定其高度。
///
/// @param  identifier用于使用系统的“-dequeueReusableCellWithIdentifier：”调用来检索和维护模板单元的字符串标识符。
/// @param configuration用于配置和提供内容到模板单元的可选块。 对于滚动性能而言，配置应该是最小的，但足以计算单元格的高度。
///
- (CGFloat)fd_heightForCellWithIdentifier:(NSString *)identifier configuration:(void (^)(id cell))configuration;

///该方法执行“-fd_heightForCellWithIdentifier：configuration”，计算出的高度将由其索引路径缓存，在需要时返回缓存的高度。 因此，可以节省大量额外的高度计算。
///
/// 无需担心在数据源更改时使缓存高度无效，当您调用“-reloadData”或触发UITableView重新加载的任何方法时，它将自动完成。
///
/// @param 此单元格的高度缓存所属的indexPath。
///
- (CGFloat)fd_heightForCellWithIdentifier:(NSString *)identifier cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(id cell))configuration;

/// 此方法通过模型实体的标识来高速缓存。 如果您的模型已更改，请调用“-invalidateHeightForKey：（id <NSCopying>）”键来使缓存无效并重新计算，它比“cacheByIndexPath”便宜得多。
///
/// @param 密钥模型实体的数据配置单元的标识符。
///
- (CGFloat)fd_heightForCellWithIdentifier:(NSString *)identifier cacheByKey:(id<NSCopying>)key configuration:(void (^)(id cell))configuration;

@end

@interface UITableView (FDTemplateLayoutHeaderFooterView)

/// 返回在表视图中使用重用标识符注册的页眉或页脚视图的高度。
///

/// 在调用“ - [UITableView registerNib / Class：forHeaderFooterViewReuseIdentifier]”之后使用它，与“-fd_heightForCellWithIdentifier：configuration：”相同，它将调用“-sizeThatFits：”用于不使用自动布局的UITableViewHeaderFooterView的子类。
///
- (CGFloat)fd_heightForHeaderFooterViewWithIdentifier:(NSString *)identifier configuration:(void (^)(id headerFooterView))configuration;

@end

@interface UITableViewCell (FDTemplateLayoutCell)

/// Indicate this is a template layout cell for calculation only.
/// You may need this when there are non-UI side effects when configure a cell.
// 指示这是仅用于计算的模板布局单元格。 配置单元时，当有非UI副作用时，可能需要这样做。
/// Like:
///   - (void)configureCell:(FooCell *)cell atIndexPath:(NSIndexPath *)indexPath {
///       cell.entity = [self entityAtIndexPath:indexPath];
///       if (!cell.fd_isTemplateLayoutCell) {
///           [self notifySomething]; // non-UI side effects
///       }
///   }
///
@property (nonatomic, assign) BOOL fd_isTemplateLayoutCell;

/// 启用强制此模板布局单元格使用“框架布局”而不是“自动布局”
/// 并通过调用“-sizeThatFits：”来询问单元格的高度，因此您必须覆盖此方法。
/// 仅当您要手动控制此模板布局单元格的高度时才使用此属性
/// 计算模式，默认为NO。
///
@property (nonatomic, assign) BOOL fd_enforceFrameLayout;

@end
