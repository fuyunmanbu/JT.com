//
//  LPADLaunchController.m
//  LovePlayNews
//
//  Created by tany on 16/9/1.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "LPADLaunchController.h"
#import "LPADLaunchView.h"
#import "UIImage+TYLaunchImage.h"
#import "LPHttpRequest.h"
#import <YYWebImage.h>

@interface LPADLaunchController () <TYRequestDelegate>

@property (nonatomic, weak) LPADLaunchView *adLaunchView;

@property (nonatomic, weak) LPHttpRequest *adRequest;

@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation LPADLaunchController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addADLaunchView];
    
    [self loadData];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _adLaunchView.frame = self.view.bounds;
}

- (void)addADLaunchView
{
    LPADLaunchView *adLaunchView = [[LPADLaunchView alloc]init];
    adLaunchView.skipBtn.hidden = YES;
    adLaunchView.launchImageView.image = [UIImage ty_getLaunchImage];
    [adLaunchView.skipBtn addTarget:self action:@selector(skipADAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:adLaunchView];
    _adLaunchView = adLaunchView;
}

- (void)loadData
{
    LPHttpRequest *adRequest = [[LPHttpRequest alloc]init];
    adRequest.timeoutInterval = 2.0;
    adRequest.serializerType = TYRequestSerializerTypeString;
    adRequest.URLString = @"/news/initLogo/ios_iphone6";
    adRequest.delegate = self;
    [adRequest load];
}


#pragma mark - private

- (void)showADImageWithURL:(NSURL *)url
{
    __weak typeof(self) weakSelf = self;
    [_adLaunchView.adImageView yy_setImageWithURL:url placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
        // 启动倒计时
        [weakSelf scheduledGCDTimer];
    }];
}
// 定时器中的设置方法
- (void)showSkipBtnTitleTime:(int)timeLeave
{
    NSString *timeLeaveStr = [NSString stringWithFormat:@"跳过 %ds",timeLeave];
    [_adLaunchView.skipBtn setTitle:timeLeaveStr forState:UIControlStateNormal];
    _adLaunchView.skipBtn.hidden = NO;
}
/*
 -----------------------------------dispatch_after---------------------------------
 
 dispatch_after 能让我们添加进队列的任务延时执行，比如想让一个Block在10秒后执行：
 
 var time = dispatch_time(DISPATCH_TIME_NOW, (Int64)(10 * NSEC_PER_SEC))
 dispatch_after(time, globalQueue) { () -> Void in
    println("在10秒后执行")
 }
 
 NSEC_PER_SEC表示的是秒数，它还提供了NSEC_PER_MSEC表示毫秒。
 上面这句 dispatch_after 的真正含义是在10秒后把任务添加进队列中，并不是表示在10秒后执行，大部分情况该函数能达到我们的预期，只有在对时间要求非常精准的情况下才可能会出现问题。
 -----------------------------------dispatch_time_t---------------------------------
 获取一个 dispatch_time_t 类型的值可以通过两种方式来获取，以上是第一种方式，即通过dispatch_time函数，另一种是通过dispatch_walltime函数来获取，dispatch_walltime需要使用一个timespec的结构体来得到dispatch_time_t。通常dispatch_time用于计算相对时间，dispatch_walltime用于计算绝对时间，我写了一个把NSDate转成dispatch_time_t的Swift方法：
 
 func getDispatchTimeByDate(date: NSDate) -> dispatch_time_t {
    let interval = date.timeIntervalSince1970
    var second = 0.0
    let subsecond = modf(interval, &second)
    var time = timespec(tv_sec: __darwin_time_t(second), tv_nsec: (Int)(subsecond * (Double)(NSEC_PER_SEC)))
    return dispatch_walltime(&time, 0)
 }
 
 这个方法接收一个NSDate对象，然后把NSDate转成dispatch_walltime需要的timespec结构体，最后再把dispatch_time_t返回，同样是在10秒后执行，之前的代码在调用部分需要修改成：
 
 var time = getDispatchTimeByDate(NSDate(timeIntervalSinceNow: 10))
 dispatch_after(time, globalQueue) { () -> Void in
    println("在10秒后执行")
 }
 
 这就是通过绝对时间来使用dispatch_after的例子。
 
 -------------------------------------印象笔记均有记录-----------------------------------
 */
- (void)scheduledGCDTimer
{
    [self cancleGCDTimer];
    __block int timeLeave = 3; //倒计时时间
    // 获取队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 创建一个定时器
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    // 设置定时器的各种属性（几时开始任务，每隔多长时间执行一次）
    // GCD的时间参数，一般是纳秒（1秒 == 10的9次方纳秒）
    // 何时开始执行第一个任务
    // #define NSEC_PER_SEC 1000000000ull
    // 后面的 ull 是unsigned long long的意思。
    // dispatch_walltime 上面的注释块有介绍
    // 1.0 * NSEC_PER_SEC == 1秒
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    __typeof (self) __weak weakSelf = self;
     // 设置回调
    dispatch_source_set_event_handler(_timer, ^{
        if(timeLeave <= 0){
            //倒计时结束，关闭
            dispatch_source_cancel(weakSelf.timer);
            // 回到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                //关闭界面
                [weakSelf dismissController];
            });
        }else{
            int curTimeLeave = timeLeave;
            // 回到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面
                [weakSelf showSkipBtnTitleTime:curTimeLeave];
                
            });
            --timeLeave;
        }
    });
    // 启动定时器
    dispatch_resume(_timer);
}

// 取消定时器方法
- (void)cancleGCDTimer
{
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

#pragma mark - action
// "跳过"按钮点击事件
- (void)skipADAction
{
    [self dismissController];
}

- (void)dismissController
{
    // 取消网络请求
    [_adRequest cancle];
    // 取消定时器
    [self cancleGCDTimer];
    // 页面删除动画
    [UIView animateWithDuration:0.6 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.view.transform = CGAffineTransformMakeScale(1.1, 1.1);
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController]; // 注意：需要同时删除该控制器
    }];
}

#pragma mark - TYRequestDelegate

- (void)requestDidFinish:(LPHttpRequest *)request
{
    NSString *imageURL = (NSString *)request.responseObject.data;
    if (!imageURL || ![imageURL isKindOfClass:[NSString class]]) {
        [self dismissController];
        return;
    }
    [self showADImageWithURL:[NSURL URLWithString:imageURL]];
}

- (void)requestDidFail:(LPHttpRequest *)request error:(NSError *)error
{
    [self dismissController];
}

- (void)dealloc
{
    [self cancleGCDTimer];
}

@end
