//
//  FDFeedViewController.m
//  Demo
//
//  Created by sunnyxx on 15/4/16.
//  Copyright (c) 2015年 forkingdog. All rights reserved.
//

#import "FDFeedViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "FDFeedEntity.h"
#import "FDFeedCell.h"

//枚举定义方法一：
//typedef enum : NSUInteger {
//    Yhhhhjj = 0
//} Yhhhh;

//枚举定义方法二：
//typedef NS_ENUM(NSUInteger, Yhhhh){
//    Yhhhhjj = 0
//};

typedef NS_ENUM(NSInteger, FDSimulatedCacheMode) {
    FDSimulatedCacheModeNone = 0,
    FDSimulatedCacheModeCacheByIndexPath,
    FDSimulatedCacheModeCacheByKey
};
//UIActionSheet 与 alertview相似，同样也是弹框提示，不同的地方在于actionsheet是靠底端显示，而alertview是居中显示。
@interface FDFeedViewController () <UIActionSheetDelegate>
@property (nonatomic, copy) NSArray *prototypeEntitiesFromJSON; // 拿到 json／模型数组
@property (nonatomic, strong) NSMutableArray *feedEntitySections; // 实际使用的 json／模型数组
@property (nonatomic, weak) IBOutlet UISegmentedControl *cacheModeSegmentControl;
@end

@implementation FDFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//   是否打印调试信息
    self.tableView.fd_debugLogEnabled = YES;
    
    // 默认选中第二个 （0，1，2）
    self.cacheModeSegmentControl.selectedSegmentIndex = 1;
    
    //将加载的数据添加到 feedEntitySections 内，刷新列表。
    [self buildTestDataThen:^{
        self.feedEntitySections = @[].mutableCopy;
//        注意：一个数组里包了一个数组
        [self.feedEntitySections addObject:self.prototypeEntitiesFromJSON.mutableCopy];
        [self.tableView reloadData];
    }];
}

//加载 json 数据
- (void)buildTestDataThen:(void (^)(void))then {
//    全局的并发队列
//    在子线程执行
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Data from `data.json`
//        读取本地 json 数据
        NSString *dataFilePath = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
        NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSArray *feedDicts = rootDict[@"feed"];
        
//        遍历数据，转模型
        NSMutableArray *entities = @[].mutableCopy;
        // enumerateKeysAndObjectsUsingBlock会遍历dictionary并把里面所有的key和value一组一组的展示给你，每组都会执行这个block。
        [feedDicts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [entities addObject:[[FDFeedEntity alloc] initWithDictionary:obj]];
        }];
        self.prototypeEntitiesFromJSON = entities;
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            三目运算符，block回调(经过打印，!then == nil == NO，所以回调。应该是为了安全起见才有这一句。)
            !then ?: then();
        });
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.feedEntitySections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.feedEntitySections[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FDFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FDFeedCell"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}
// 这里没有什么需要设置的，只是抽取了对 cell 设置的部分
- (void)configureCell:(FDFeedCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    默认就是 NO,自动布局,不调用 sizeThatFits 方法
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"
    
    if (indexPath.row % 2 == 0) { // 设置 cell 样式
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
//    设置模型
    cell.entity = self.feedEntitySections[indexPath.section][indexPath.row];
}

#pragma mark - UITableViewDelegate
//返回每个 cell 的实际高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    通过点击获取的数字 获取该枚举变量，可以借鉴（每次跟改需要刷新控件的数据）
    NSLog(@"%ld",(long)indexPath.row);
//    通过打印，系统先调用一遍返回每个cell的高度，之后再根据屏幕上显示的cell再调用此方法
    FDSimulatedCacheMode mode = self.cacheModeSegmentControl.selectedSegmentIndex;
    switch (mode) {
//            不缓存
        case FDSimulatedCacheModeNone: //If you have a self-satisfied cell
            return [tableView fd_heightForCellWithIdentifier:@"FDFeedCell" configuration:^(FDFeedCell *cell) {
                // 对 cell 的设置
                [self configureCell:cell atIndexPath:indexPath];
            }];
        case FDSimulatedCacheModeCacheByIndexPath: //通过索引路径为缓存提供 ------  高度缓存API
            return [tableView fd_heightForCellWithIdentifier:@"FDFeedCell" cacheByIndexPath:indexPath configuration:^(FDFeedCell *cell) {
                
                [self configureCell:cell atIndexPath:indexPath];
            }];
        case FDSimulatedCacheModeCacheByKey: { //按键API的缓存 ------  高度缓存API -- 应该是一个比一个性能高
            FDFeedEntity *entity = self.feedEntitySections[indexPath.section][indexPath.row];
            return [tableView fd_heightForCellWithIdentifier:@"FDFeedCell" cacheByKey:entity.identifier configuration:^(FDFeedCell *cell) {
                [self configureCell:cell atIndexPath:indexPath];
            }];
        };
        default:
            break;
    }
}
//滑动删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        取出 JSON 数组删除
        NSMutableArray *mutableEntities = self.feedEntitySections[indexPath.section];
        [mutableEntities removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Actions
//刷新事件
- (IBAction)refreshControlAction:(UIRefreshControl *)sender {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.feedEntitySections removeAllObjects];
        [self.feedEntitySections addObject:self.prototypeEntitiesFromJSON.mutableCopy];
        [self.tableView reloadData];
        [sender endRefreshing];
    });
}

//点击 Action 按钮
- (IBAction)rightNavigationItemAction:(id)sender {
    [[[UIActionSheet alloc]
      initWithTitle:@"Actions"
      delegate:self
      cancelButtonTitle:@"Cancel"
      destructiveButtonTitle:nil
      otherButtonTitles:
      @"Insert a row",
      @"Insert a section",
      @"Delete a section", nil]
     showInView:self.view];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 可以使用 swith 的方式，却还要使用这种方式
    SEL selectors[] = {
        @selector(insertRow),
        @selector(insertSection),
        @selector(deleteSection)
    };
//  可以根据typeof（）括号里面的变量，自动识别变量类型并返回该类型。
//    http://www.jianshu.com/p/f27038845143
//    NSLog(@"%lu",sizeof(selectors));    / 24
//    NSLog(@"%lu",sizeof(SEL));          / 8
    if (buttonIndex < sizeof(selectors) / sizeof(SEL)) {
        void(*imp)(id, SEL) = (typeof(imp))[self methodForSelector:selectors[buttonIndex]];
        imp(self, selectors[buttonIndex]);
    }
}

- (FDFeedEntity *)randomEntity {
    NSUInteger randomNumber = arc4random_uniform((int32_t)self.prototypeEntitiesFromJSON.count);
    FDFeedEntity *randomEntity = self.prototypeEntitiesFromJSON[randomNumber];
    return randomEntity;
}

- (void)insertRow {
    if (self.feedEntitySections.count == 0) {
        [self insertSection];
    } else {
        [self.feedEntitySections[0] insertObject:self.randomEntity atIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)insertSection {
    [self.feedEntitySections insertObject:@[self.randomEntity].mutableCopy atIndex:0];
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)deleteSection {
    if (self.feedEntitySections.count > 0) {
        [self.feedEntitySections removeObjectAtIndex:0];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
