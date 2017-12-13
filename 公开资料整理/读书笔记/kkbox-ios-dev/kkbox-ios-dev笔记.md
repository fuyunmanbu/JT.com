#kkbox-ios-dev笔记

##Selector
>* 简单的定义
 * `Selector`就是用字符串表示某个对象的某个方法

>* 更术语的说法
 * `Selector`就是`Objective-C`的表格中指向实际执行函数的一个 C 字符串 

>* 用途
 * 因为方法可以用字符串表示，因此，某个方法就可以变成赋值的参数
 
>####Objective-C Class/Object到底是什么？
>* `Objective-C`程序在编译运行时，编译器会编译成 `C `语言继续编译。
>* `Objective-C`类会编译成 `C `的结构体，方法和`block`会被编译成 `C` 方法，
>* 在执行的时候，运行时才会创建与`C`结构体和`C`方法的关联。

>####对类加入方法
>* 在执行的时候，`Runtime`会为每个类准备好一张表格，表格里面会以一个字符串`key`(又称：`selector`)对应到 C 方法的指定位置。把实现的 C 方法定义成`IMP`这个`type`(又称：`SEL`)。
>* 可以使用`@selector`关键字创建`selector`。
>* 对一个对象调用某个方法，`Runtime`就把方法的名称当作字符串，寻找与字符串合适的 C 方法的实现，然后执行。
>* `要求某个对象执行某个方法` = `要求某个对象执行某个 selector`
>* 在`OC`中，一个类会有哪些方法，并不是固定的。如果调用了还不存在的方法，编译器不会报编程错误，只会发出警告，如果用`performSelector:`调用，不会有警告。执行时，才会发生错误，导致程序崩溃。

>####Selector用途
>* `Selector`主要用途就是实现`target／action`

>####检查方法是否存在
>* `respondsToSelector:`

>####NSInvocation
>* `NSInvocation`其实就是将`target／action`以及这个`action`中要传递给`target`的参数这三者，在包装成一个对象。
>
>```swift
>NSMethodSignature *sig = [MyClass instanceMethodSignatureForSelector:@selector(doSomething:)];NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];[invocation setTarget:someObject];[invocation setSelector:@selector(doSomething:)];[invocation setArgument:&anArgument atIndex:2];NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0                          invocation:invocation                          repeats:YES];
>```
>* **注意**：在调用`NSInvocation`的`setArgument:atIndex:`方法时，要传递的参数至少要从 2 开始，由于是给`objc_msgSend`调用用的参数，在 0 的参数是对象自己，位置 1 的则是 `selector`.

>####在某个线程执行方法
>* `-performSelectorOnMainThread:withObject:waitUntilDone:modes:`
>* `-performSelectorOnMainThread:withObject:waitUntilDone:`>* `-performSelector:onThread:withObject:waitUntilDone:modes:`>* `-performSelector:onThread:withObject:waitUntilDone:`>* `-performSelectorInBackground:withObject:`
>* 在子线程执行完任务后，可以通过`-performSelectorOnMainThread:withObject:waitUntilDone:`通知主线程执行完毕。

>####Array排序
>* 如果一个数组里面都是字符串的话，我们就可以使用`compare:`排序。
>* `NSString`常用来比较大小顺序的方法`localizedCompare`,这个方法会参考使用者的系统语言决定排序方式，比如：简体中文下用拼音排序，繁体中文下用笔画排序等等。
>* 可变数组用的：`sortUsingSelector`
>* 不可变数组用的：`sortedArrayUsingSelector`，会产生新的数组。
>* 让数组中的所有对象执行某个方法：`makeObjectsPerformSelector:`

>####代替`if...else`与`switch...case`
>```swift
>   [super viewDidLoad];
    person * onject = [[person alloc]init];
    int condition = 0;
    switch(condition) {
        case 0:
            [onject run];
            break;
        case 1:
            [onject doSomeThing];
            break;
        default:
        break;
    }
>```
>* 代替方法：`[onject performSelector:NSSelectorFromString(@[@"run",@"doSomeThing"][condition])];`
>* 我们可以使用`NSStringFromSelector`,将`selector`转换成`NSString`，反过来，也可以使用`NSSelectorFromString`将`NSString`转成`selector`。

>####调用`Private`API
>* OC 里面没有真正所谓私有的方法，一个对象实现了哪些方法，即使没有 `import`头文件，我们都可以调用。可以通过`performSelector:`调用。但苹果不推荐，`App Store`上也会拒绝。

>####用`super`调用`performSelector:`的区别
>* `[super performSelector:@selector(doSomething)] == [self doSomething]`

>####Refactor工具
>* 在要修改名字上面点击鼠标右键，选择`Refactor`中的`Rename`。
>* 如果是通过`performSelector:`调用执行的方法，方法名就不会被换掉，只是会出现警告。

##Category
>* 	不用继承对象，就直接添加新的方法，或者替换原有的方法。

>####什么时候应该使用Category
>* 想要为某个类填充功能，增加新的成员变量与方法，我们又没有该类的代码，正规做法就是继承，创建新的子类。而我们想要填充的类又很难继承时。
>* **大概有以下几种情况很难继承：**
>
> >1. `Foundation`对象
> >
> >2. 用工厂模式实现的对象
> >
> >3. 单利对象
> >
> >4. 在代码中出现次数已经多不胜数的对象
>

>####Foundation对象
>* `Foundation`里面的基本对象，像`NSString`、`NSArray`、`NSDictionary`等类的底层实现，除了可以透过`OC`的介面调用之外，也可以透过另外一种 C 的介面，叫做`Core Foundstion`，像`NSString`其实会对应到`Core Foundstion`里面的`CFStringRef`，`NSArray`对应到`CFArrayRef`,而你甚至可以直接把`Foundation`对象转换成`Core Foundstion`的类型。
>* 所以，当你使用`alloc`、`init`产生一个`Foundation`对象的时候，其实会得到一个同时有`Foundation`与`Core Foundstion`实现的子类，而其实际产生出来的对象，往往与你的认知有很大区别。如：创建`NSString`对象，呼叫`alloc`、`init`的时候，我们真正拿到的是`__NSCFConstantString`，而创建`NSMutableString`，拿到`__NSCFString`，而`__NSCFConstantString`其实继承自`__NSCFString`!
>
>>```swift
>>#define CLS(x) NSStringFromClass([x class])NSLog(@"NSString:%@", CLS([NSString string]));NSLog(@"NSMutableString:%@", CLS([NSMutableString string]));NSLog(@"NSNumber:%@", CLS([NSNumber numberWithInt:1]));#undef CLS
执行结果：
     NSString:__NSCFConstantString     NSMutableString:__NSCFString     NSNumber:__NSCFNumber
>>```
>
>####用工厂模式实现的对象
>* 工厂模式是一套用来解决不用特别指定是哪个类，就可以创建对象的方法。
>* 在`UIKit`中，`UIButton`就是个好例子。在创建`UIButton`对象的时候，并不是调用`init`或者`initWithFrame:`,而是调用`UIButton`的类方法`buttonWithType:`，通过传入按钮的`type`创建按钮对象。在大多数状况下，会是`UIButton`对象，但假如我们传入的`type`是`UIButtonTypeRoundedRect`，却会是继承自`UIButton`的`UIRoundedRectButton`对象.
>* 后果：我们想要扩充`UIButton`，但拿到的却是`UIRoundedRectButton`，而`UIRoundedRectButton`却无法继承，因为该类不是公开的，我们无法保证以后传入`UIButtonTypeRoundedRect`一定会得到`UIRoundedRectButton`.这就造就了我们难以继承`UIButton`。
>
>####单利对象
>* 某个类只有、也只该有一个实例，每次只对这个实例操作，而不是创建新的实例。像`UIApplication`、`NSUserDefault`、`NSNotificationCenter`以及`Mac OS X`上的`NSWorkSpace`等、都是采用单利设计。
>
> ```swift
> @interface MyClass : NSObject+ (MyClass *)sharedInstance;@end
实现部分：--------------------------------------------
static MyClass *sharedInstance = nil;@implementation MyClass+ (MyClass *)sharedInstance{    return sharedInstance ?           sharedInstance : (sharedInstance = [[MyClass alloc] init]); }@end
> ``` 
> * 现在单利大多数使用`GCD`的`dispatch_once`实现.
> * 如果子类继承自`MyClass`单利，却没有重写掉`sharedInstance`方法，那么`sharedInstance`方法回调的还是`MyClass`的单利`instance`.想要重写`sharedInstance`，又不能保证该方法内部没有做其他事情，很有可能会把一些`initiailize`时该做的事情，反而放在这里做。我们直接重写了`sharedInstance`，很有可能有事情没做，而达不到预期效果。
> 
> ####在代码中出现次数已经多不胜数的对象
> * 随着项目不断成长，某些类已经频繁使用，而我们现在又需要增加新的方法，我们不可能将所有用到的地方放统统换成新的子类。
> 
> ####分类的实现
>* 一样是用`@interface`关键字声明头文件，在`@implementation`与`@end`关键字当中的内容是实现，然后在原本的类名后面，在小括号里写上新增的分类名称
>
>```swift
>@interface NSObject (SmallTalish)- (void)printNl;@end@implementation NSObject (SmallTalish)- (void)printNl{    NSLog(@"%@", self);}@end
>```
> 
> ####分类的用途
> 1. 帮原有的类增加新的方法
> 2. 将一个很大的类分成数个小部分
> 3. 替换原本的方法实现
> 
> ####扩展
>* 语法与分类非常相似，像一个没有名字的分类，在类名之后直接加上空的小括号，在头文件中定义方法，在原本的类中做方法的实现。
>* 个人添加：扩展不能继承，只有头文件，可以声明方法和属性，一般直接在原文件中定义
>
>>用途：
>>1. 拆分头文件
>>2. 管理私有方法
>
> ####分类是否可以增加新的成员变量或属性？
>* 因为 OC 对象会被编译成 C 的结构体，我们虽然可以在分类中可以增加新的方法，但是我们却不能增加新的成员变量。
>* 但在`Mac OS X 10.6`与`iOS 4`之后，苹果提出一套叫做关联对象的方法，让我们可以在分类中添加新的`getter／setter`，观念差不多是：既然我们可以用一张表格记录一个类有哪些方法，那我们不就可以另外建一张表格，记录有哪些对象与这个类相关？
>* 要使用关联对象，我们需要导入`objc/runtime.h`,然后调用`objc_setAssociatedObject`创建`setter`,用`getAssociatedObject`创建`getter`。
>
>```swift
>#import <objc/runtime.h>@interface MyClass(MyCategory)@property (strong, nonatomic) NSString *myVar;@end@implementation MyClass- (void)setMyVar:(NSString *)inMyVar{    objc_setAssociatedObject(self, "myVar",           inMyVar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);}- (NSString *)myVar{    return objc_getAssociatedObject(self, "myVar");}@end
> ``` 
>* 在`setMyVar:`中调用`objc_setAssociatedObject`时，最后一个参数`OBJC_ASSOCIATION_RETAIN_NONATOMIC`,是用来决定要用哪一种内存管理方式，管理我们传入的参数。传入的参数还可以是`OBJC_ASSOCIATION_ASSIGN`、`OBJC_ASSOCIATION_COPY_NONATOMIC`、`OBJC_ASSOCIATION_RETAIN`以及`OBJC_ASSOCIATION_COPY`。与`property`语法使用的内存管理方式一致。当`MyClass`对象在`dealloc`的时候，通过`objc_setAssociatedObject`而强引用对象会被一并释放。
>
>####对NSURLSessionTask编写分类
>* 假如我们在 iOS7 上，对`NSURLSessionTask`写一个分类之后，你会发现，如果我们用`[NSURLSession sharedSession]`产生了`NSURLSessionDataTask`对象，之后，对这个对象调用分类里的方法，会出现找不到`selector`的错误，按理说`NSURLSessionDataTask`继承自`NSURLSessionTask`,为什么编写`NSURLSessionTask`的分类没用？
>* 到了 iOS8 的环境下，可以用这个对象调用`NSURLSessionTask`分类里的方法，但如果写成`NSURLSessionDataTask`的分类，结果又是找不到`selector`的错误。
>* **细节注意**：如果有一个分类不是直接写在你的 app 中，而是在某个静态库中，你要在编译 app 的最后才把这个库连接进来，预设分类并不会被连接器给连接进来，你必须要另外在 Xcode 中设定 `other linker flag`，加上 `-Objc`或是`-all_load`.当然，上述问题不是这个原因。
>
>```swift
>NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"http://kkbox.com"]];NSLog(@"%@", [task class]);NSLog(@"%@", [task superclass]);NSLog(@"%@", [[task superclass] superclass]);NSLog(@"%@", [[[task superclass] superclass] superclass]);
在 iOS8 上的结果是：--------------------------------------
__NSCFLocalDataTask__NSCFLocalSessionTaskNSURLSessionTaskNSObject
在 iOS7 上的结果是：--------------------------------------
__NSCFLocalDataTask__NSCFLocalSessionTask__NSCFURLSessionTaskNSObject
>```
>* 结论：无论是 iOS8 或 iOS7，我们创建的`data task`,都不是直接产生`NSURLSessionDataTask`对象，而是产生`NSURLSessionDataTask`这样的私有对象。iOS8上，`__NSCFLocalDataTask`并不继承`NSURLSessionDataTask`，而 iOS7 上`__NSCFLocalDataTask`甚至连`NSURLSessionTask`都不是。
>* 像调用`[task isKindOfClass:[NSURLSessionDataTask class]]`,还是会返回`YES`，`-isKindOfClass:`是可以被重写的。
>
>```swift
>- (BOOL)isKindOfClass:(Class)aClass{    if (aClass == NSClassFromString(@"NSURLSessionDataTask")) {        return YES;    }    if (aClass == NSClassFromString(@"NSURLSessionTask")) {return YES; }    return [super isKindOfClass:aClass];}
>```
>* `-isKindOfClass:`其实并不像你所想象的那么值得信任。

##内存管理(一)
>* 内存泄漏：该释放的对象, 没有被释放(已经不再使用的对象, 没有被释放)
>* 无效内存引用：内存已经被释放了，我们还强行调用。会报`EXC_BAD_ACCESS`错误。
>
>####基本原则
>>* 如果是`init`、`new`、`copy`这些方法产生出来的对象，用完就该调用`release`.
>>* 如果是其他一般方法产生出来的对象，就会回调`auto-release`对象、或是`singleton`对象(稍晚会解释什么是`singleton`)，就不需要另外调用`release`.
>
> **而调用retain与release的时机包括:**
> 
>>* 如果是在一般代码中用了某个对象，用完就要`release`或是`auto-release`
>>* 如果是要将某个`Objective-C`对象，变成是另外一个对象的成员变量，就要将对象`retain`起来。但是`delegate`对象不该`retain`。
>>* 在一个对象被释放的时候，要同时释放自己的成员变量，也就是要在实现`delloc`的时候，释放自己的成员变量。

>* 要将某个对象设为另外一个对象的成员变量，需要写一组`getter/setter`。
>
> ####`Getter/Setter`与`Property`语法   
>>* **基本数据类型**
> 
> >```swift
> @interface MyClass:NSObject{	int number; 
}- (int)number;- (void)setNumber:(int)inNumber;@end
> ```
>> * 实现部分
> 
>> ```swift
> - (int)number{    return number;}- (void)setNumber:(int)inNumber{    number = inNumber;}
> ```
> 
>>* 如果是 OC 对象，我们则是要将原本成员变量已经指向的内存释放，然后将传入的对象`retain`起来。该写法并不安全
>
>>```swift
>- (id)myVar {    return myVar;}- (void)setMyVar:(id)inMyVar{    [myVar release];    myVar = [inMyVar retain];}
>```
>* 假如今天我们在开发中用到很多个线程，而在不同的线程中同时会用到`myVar`，在某某个线程中调用了`[myVar release]`之后，到`myVar`指定到`inMyVar`的位置之间，假如另外一个线程刚好用到了`myVar`，这时候`myVar`刚好指到了一个已経被释放的内存，这就造成了
`EXC_BAD_ACCESS`错误.
>
>>* 更安全的写法:加锁，让程序在调用`setMyVar:`的时候,不让其他线程调用`myVar`；另外一种简单的方法如下：
>
>>```swift
>- (void)setMyVar:(id)inMyVar{    id tmp = myVar;    myVar = [inMyVar retain];    [tmp release];}
>```
>
>* 上面的例子，用`property`语法可以写成：
>
>```swift
>@interface MyClass:NSObject{	id myVar;	int number; 
}@property (retain, nonatomic) id myVar;@property (assign, nonatomic) int number;@end@implementation MyClass- (void)dealloc{    [myVar release];    [super dealloc];}@end
>```
>**`myVar = nil`与`self.myVar = nil`的区别？**
>
>* 前者只是单纯的将`myVar`的指针指向`nil`，但是并没有释放原本所指向的内存位置，所以会造成内存泄漏，但后者却等同于调用`[self setMyVar:nil]`，会先释放`myVar`原本指向的位置，然后将`myVar`设成`nil`。

##内存管理(二)
>* ARC 是通过静态分析，在编译时决定应该要在代码的哪个地方加入`retain`、`release`。
>
>####循环retain
>
>>* **错误情况：**
>>* 1. 把代理设置为`strong`
>>* 2. 某对象的某`property`是一个`block`，但是在这个`block`里面把对象自己给`retain`了一份。
>>* 3. 使用`timer`的时候，到了`dealloc`的时候才停止`timer`。
>>* 假如我们在有一控制器，我们希望这个控制器可以定时更新，
那么，我可能会使用`+scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:`方法创建`timer`对象，指定定时执行某个`selector`.要特别注意，在创建这个`timer`的时候，我指定给`timer`的`target`，也曾被`timer` `retain`一份，因此，我们想要在控制器在`dealloc`的时候，才停止`timer`就曾有问题：因为控制器已经被`timer` `retain`起来了，所以只要`timer`还在执行，控制器就不
可能走到`dealloc`的地方。
>
>####对象桥接
>* 	**什么是对象桥接：**`Foundation`库里面的每一个对象，都有对应的 C 实现，这 C 的实现叫作`Core Foundation`，当我们在使用`Core Foundation`里面的 C 形态时，像`CFString`、`CFArray`等，我们可以让这些形态变成可以接受 ARC 的管理.这种让 C 形态也可以被当做 OC 对象，接受 ARC 管理的方式，就叫对象桥接。
>
>>* 有三个关键字：`__bridge`、`__bridge_retained`、`__bridge_transfer`
>>* `__bridge`:会把`Core Foundation`的 C 资料形态转换成 OC 对象，但是不会多做`retain`与`release`。
>>* `__bridge_retained`:会把`Core Foundation`的 C 资料形态转换成 OC 对象，并且会做一次`retain`，但是之后必须由我们手动调用`CFRelease`，释放内存。
>>* `__bridge_transfer`:会把`Core Foundation`转换成 OC 对象，并且会让 ARC 主动添加`retain`与`release`。
>
>* 但不一定每个`Core Foundation`型态都有办法转换成`OC`对象。详见苹果文档[详细说明](https://developer.apple.com/library/content/documentation/CoreFoundation/Conceptual/CFDesignConcepts/Articles/tollFreeBridgedTypes.html)

##内存管理(三) - 略(控制器的内存管理)

##代理
>####Delegate属性应该要用Weak，而非strong
>* **原因是：**需要设置代理对象的这个对象，往往是其代理对象的成员变量，A 的实例是 A 对象，是 B 的成员变量，可能已经被 B `retain`了一份，如果 A 又 `retain`了一次 B，就会出现循环 `retain`的问题 -- 已经被别人`retain`，又把别人`retain`一次。
>
>####命名规范
>* 至少传入一个参数，就是代理调用者本身;往往以传入的类名开头，让我们可以辨别这是哪各类的代理方法。以代理`UITableViewDelegate`为例
>  * `- (void)tableView:(UITableView *)tableView        didSelectRowAtIndexPath:(NSIndexPath *)indexPath`
>
>####我们曾经犯过的低级错误
>>* 源代码
>>
>>```swift
>>@class MyClass;@protocol MyClassDelegate <NSObject>- (void)myClassWillBegin:(MyClass *)myClasss;- (void)myClassDidBegin:(MyClass *)myClasss;- (void)myClassWillStop:(MyClass *)myClasss;- (void)myClassDidStop:(MyClass *)myClasss;@end@interface MyClass : NSObject{    id <MyClassDelegate> delegate;}- (void)begin;- (void)stop;@property (assign, nonatomic) id <MyClassDelegate> delegate;@end@implementation MyClass- (void)begin{    [delegate myClassWillBegin:self];    // Do something    [delegate myClassDidBegin:self];}- (void)stop{    [delegate myClassWillStop:self];    // Do something    [delegate myClassDidStop:self];}@synthesize delegate;@end
>>```
>>* 问题：在`myClassWillBegin:`里面想要做一些检查，如果在某些条件下，这件事情不该跑起来，而应该停止，所以在`myClassWillBegin:`里面调用了`stop`。但这么做，并不会让这件事情结束，因为`begin`这个方法在对代理调用完`myClassWillBegin:`之后，程序还是会继续走下去，所以还是把`begin`整个做完了。
>>
>>* 优化后：
>>
>>```swift
>>@class MyClass;@protocol MyClassDelegate <NSObject>- (BOOL)myClassShouldBegin:(MyClass *)myClasss;- (void)myClassDidBegin:(MyClass *)myClasss;- (BOOL)myClassShouldStop:(MyClass *)myClasss;- (void)myClassDidStop:(MyClass *)myClasss;@end@interface MyClass : NSObject{    id <MyClassDelegate> delegate;}- (void)begin;- (void)stop;@property (assign, nonatomic) id <MyClassDelegate> delegate;@end@implementation MyClass- (void)begin{    if (![delegate myClassShouldBegin:self]) {        return;	}    // Do something    [delegate myClassDidBegin:self];}- (void)stop{    if (![delegate myClassShouldStop:self]) {        return;	}    // Do something    [delegate myClassDidStop:self];}@synthesize delegate;@end
>>```

##单元测试
>* 以程序测试程序，以代码测试代码。测试每个功能是否正常运行。
>
>####AAA原则
>* 在`Xcode`里面创建项目时，可以选择`Xcode`将我们的 App 建立单元测试的绑定。会出现一个继承自`XCTestCase`的类，在里面编写任何用`test`开头的方法，都是一条测试实例。也就是我们写测试的时候，就是写出一群用`test`为开头的方法。
>* **扩展：**`Xcode`从 5.1 版开始到现在的测试框架叫作`XCTest`，在这之前是使用一套叫作`OCUnit`的测试框架，除此之外，还有[GHUnit](https://github.com/gh-unit/gh-unit)、[Kiwi](https://github.com/kiwi-bdd/Kiwi)等有名的测试框架。
>* **AAA原则：**在编写测试的时候，基本原则就是一次只测试一项函数或方法。同时一个`test`实例会包含所谓的 AAA 原则：**`Arrange`、`Act`、`Assert`**
>  * `Arrange`：先设定我们在这次测试中，所预测的结果
>  * `Act`：就是我们想要测试的函数或方法
>  * `Assert`：确认在`Act`发生后，执行了想要的函数或方法后，的确符合我们在`Arrange`阶段设定的目标。
> 
>>* **比如：**
>>* 在贪吃蛇游戏中，预期一条长度为 6、正在往左边移动的蛇，先往上移动一格、再往右走一格、再往下走一格之后，这条蛇的头一定会撞到自己的身体，如果我们的程序说蛇头没有撞到，就一定有 bug。就可以拆解成：
>>  * `Arrange`：头应该会撞到身体
>>  * `Action`：让蛇执行往上右下移动的动作
>>  * `Assert`：确认蛇头真的撞到身体了
>> 
>> ```swift
>> - (void)testHit{
    // 蛇对象    KKSnake *snake = [[KKSnake alloc]      initWithWorldSize:KKMakeSnakeWorldSize(10, 10) length:6];
    // 蛇动作    [snake changeDirection:KKSnakeDirectionUp];[[snake move];    [snake changeDirection:KKSnakeDirectionRight];[snake move];    [snake changeDirection:KKSnakeDirectionDown];[snake move];    XCTAssertEqual([snake isHeadHitBody], YES, @"must hit the body.");
}
>> ```
>> * 如果我们想要测试“蛇的尾巴加长”这段程序是否正常，`思路：`原本这条蛇的长度为 2，尾巴位在`(6, 5)`,假如蛇的身体要加长两格，预期舍得长度变成 4，尾巴为在`(8, 5)`.
>> 
>> ```swift
>> - (void)testIncreaseLength{    ZBSnake *snake = [[ZBSnake alloc] initWithWorldSize:ZBMakeSnakeWorldSize(10, 10) length:2];    XCTAssertEqual((int)[snake.points count], 2, @"Length must be 2 but %d", [snake.points count]);    NSInteger x;    NSInteger y;    x = [snake.points[[snake.points count] - 1] snakePointValue].x;    y = [snake.points[[snake.points count] - 1] snakePointValue].y;    XCTAssertEqual(x, 6, @"must be 6");    XCTAssertEqual(y, 5, @"must be 5");    [snake increaseLength:2];    XCTAssertEqual((int)[snake.points count], 4, @"Length must be 4 but %d", [snake.points count]);    x = [snake.points[[snake.points count] - 1] snakePointValue].x;    y = [snake.points[[snake.points count] - 1] snakePointValue].y;    XCTAssertEqual(x, 8, @"must be 8");    XCTAssertEqual(y, 5, @"must be 5");}
>> ```
>
>####执行测试
>* 写了测试程序之后，我们可以在 Xcode 里面点击`Product -> Test`执行单元测试。如果`XCTAssertEqual`这行`assert`出现问题，Xcode 就会立刻出现警告。
>* 在代码的编辑页面中，每一个`test`实例前方会出现一个菱形的标示，如果这个标示是空白的，代表还没有执行测试。执行完毕之后，如果成功，就会是绿色，反之就会变成红色。可以直接通过鼠标点击此棱形标示，执行测试。
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170226_4.png)
>* 在 Xcode 的左侧工具条的第四项，叫作`Test Navigator`,在这边我们可以找到我们目前所在项目的所有`test`实例，在这里可以看到每个`test`实例是成功或失败，也可以通过点击，直接跳到特定`test`的实例代码。
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170226_6.png)
>* 在 Xcode 的左侧工具条的最后一项，叫作`Report Navigator`，可以看到最近一次完整执行所有`test`实例的结果。
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170226_7.png)
>
>####测试驱动开发
>* `Kent Beck`在2002年出版的书中提出测试驱动开发的概念：在开发软件的时候，我们不是先写主要功能，而是先写测试。过程应该是`Red、Green、Refactor`三个阶段：
>  * `Red:`在还没有主要功能前，先写单元测试。由于主要功能都还没有编写，自然无法通过刚刚写出来的单元测试，所以会亮出红色的灯号。
> * `Green:`开始实现主要功能，直到可以通过单元测试，让测试的灯号变成绿色。
> * `Refactor:`继续整理写出的代码。
> 
> ####覆盖率(Coverage)
> * 所谓覆盖率就是我们的单元测试覆盖了程序的多少比例，也就是，有多少程序被测试到、以及没有被测试到。当我们发出有程序没有被测试到之后，便进一步编写跟多的`test`实例，确保我们的程序经过完整的测试。
> 
>> * 在 Xcode7及以上版本中直接包含计算覆盖率的功能。要在 Xcode 中展示覆盖率，首先是在`Scheme`中，勾选`Gather Coverage Data`.
>> ![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170226_9.png)
>> * 接着，在执行单元测试的时候，就可以看到有一个标示`Coverage`的分页，标示每个项目的覆盖率是多少。
>> ![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170226_10.png)
>> * 选择任意文件编辑，便可以看到在页面的最右方，可以看到每行程序在`test`实例中被执行了数次，如果没有执行到(执行次数为 0)，背景就会变成红色，提醒我们应该要对这部分写单元测试。
>> ![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170226_13.png)
>> ![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170226_14.png)

##Blocks
>####什么时候用Blocks？什么时候用代理？
>* **通常的区分方式：**如果一个方法或函数的调用只有单一的回调，那么使用`block`，如果可能会有多个不同的回调，那么就使用代理。
>* **这样做的好处是：**当一个方法或函数调用会有多种回调的时候，很有可能会有某些回调没有必要实现。代理可以用`@required`、`@optional`关键字做区分；用`block`处理回调，就会很难区分某个`block`是否是必须实现的：在`Xcode6.3`之前，OC 并没有`nullable`、`nonnull`等关键字，让我们知道某些方法、某些属性要传入的`block`可不可以是`nil`，我们也往往搞不清楚在这些地方传入`nil`，会不会发生什么危险的事情。
>
>####__block关键字
>* 在`block`里面如果使用了在`block`之外的变量，会将这份变量先复制一份再使用，也就是说，在没有特别宣告的状况下，对我们目前所在的`block`来说，所有外部变量都是只读取，不能更改。至于`block`里面用到的 OC 对象，则只会被`retain`一次。如果想要改变该变量，则需要在该变量前面加上`__block`关键字。
>
>####__weak关键字
>* 假如某个对象的属性是一个`block`而这个`block`里面又用到了`self`，就会遇到循环`retain`而无法释放内存的问题：`self`要被释放才会去释放这个属性，单这个属性作为`block`又`retain`了`self`，导致`self`无法被释放。
>* 如果不想让`block`对`self retain`起来，就需要使用`__weak`关键字。

##Notification Center
>* 对象之间可以不必互相知道彼此的存在，也可以相互传递消息、交换资料／状态的机制。
>
>####接受通知
>> **一个通知分成几个部分：**
>> 
>> * `object`:发送者，是谁发出了这个通知
>> * `name`:这个通知叫什么名字
>> * `user info`:这个通知还带了哪些额外信息
> 
> * 在 iOS4 之后，我们可以使用`addObserverForName: object: queue: usingBlock:`这组使用`block`语法的`API`订阅通知，由于是传入`block`，所以我们就不必另外又写一个`selector`。而`remove observer`的写法也会不太一样,该`block`语法的`API`会回调一个`observer`对象，是对`removeObserver:`传入之前拿到的`observer`对象。如下：
> 
> ```swift
> self.observer = [[NSNotificationCenter defaultCenter]    addObserverForName:NSCurrentLocaleDidChangeNotification    object:nil    queue:[NSOperationQueue mainQueue]    usingBlock:^(NSNotification *note) { // 处理 locale 改变的状态       
}];
> ```
> * `Remove observer`的时候：
> 
> ```swift
> [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
> ```
> ####发送通知
> * 在创建通知对象之后，对通知中心调用`postNotification：`即可。有以下三种方式：
> 
> ```swift
> - (void)postNotification:(NSNotification *)notification;- (void)postNotificationName:(NSString *)aName                      object:(id)anObject;- (void)postNotificationName:(NSString *)aName                      object:(id)anObject                    userInfo:(NSDictionary *)aUserInfo;
> ```
> 
> ####通知与线程
> * 当我们订阅某个通知之后，我们不能保证负责处理通知的`selector`或`block`会在哪个线程执行
> * **这个通知是在哪个线程发出的，负责接受的`selector`或是`block`，就会在哪个线程执行。**
> * 绝大多数的通知都是在主线程发出。
> 
> ####Notification Queue
> * 程序可能会在短时间内送出大量的通知，而造成资源浪费或效能问题。
> * `NSNotificationQueue`相当于是通知发送端与通知中心之间的一个缓冲器，这个缓冲器可以让我们暂缓发出的通知，而在一段缓冲期之内，决定我们是否要合并通知。
> 
>> * 首先要创建一个`Notification Queue`对象：
>> 
>> ```swift
>> notificationQueue = [[NSNotificationQueue alloc]initWithNotificationCenter:[NSNotificationCenter defaultCenter]];
>> ```
>> * 原本：
>> 
>> ```swift
>> NSNotification *n = [NSNotification    notificationWithName:@"KKSongInfoDidChangeNotification"    object:self];[[NSNotificationCenter defaultCenter] postNotification:n];
>> ```
>> * 改后：
>> 
>> ```swift
>> NSNotification *n = [NSNotification    notificationWithName:@"KKSongInfoDidChangeNotification"    object:self];[notificationQueue enqueueNotification:n    postingStyle:NSPostASAP    coalesceMask:NSNotificationCoalescingOnName | NSNotificationCoalescingOnSender    forModes:nil];
>> ```
>> * 在这边传入了`NSNotificationCoalescingOnName`和`NSNotificationCoalescingOnSender`,代表的就是请`notification queue`合并名称相同，发送者也相同的通知。

##设计模式
>####MVC
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170317_1.png)
>
>* 并不是每个平台都一致。像 `Windows` 上往往把`window`对象当成`controller`，但在 Mac 上`window`被划入到 `View`这一块。
>* 一般来说`Controller`持有`Model`与`View`对象。
>
>####Delegate
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170317_2.png)
>
>* `Controller`持有`Model`与`View`对象,可以直接调用`View`与`Model`上的各种方法，但当`View`与`Model`需要调用`Controller`的时候，会把`Controller`设定成`delegate`，而`delegate`只要符合`protocol`的定义，不需要是特定类，避免`View`与`Model`绑死在某个`Controller`上。
>
>####Singleton
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170317_3.png)
>
>* 某个类只有一个`instance`，这样在其他地方都可以集中找到同一个`instance`，像`UIApplication`等对象就是单利对象。
>* 为什么现在的单利多为 GCD？
>* 是为了避免在多个线程下，`shared instance`可能会被重复创建的问题，GCD 更保险。
>
>####Notification Center
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170317_4.png)
>
>* 一个对象改变状态的时候，其他对象不需要知道这个对象的存在，也跟着改变状态，每个对象之间通过通知中心互相通知，有互相隔绝。
>
>####Factory Method(工厂方法／类方法)
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170317_5.png)
>
>* 把`Factory`变成创建对象的唯一入口，其他地方不需要知道某个类确实确实来说是怎样做的，就可以创建需要的对象。把内部实现隔绝起来。

##一些新手常常搞混的东西
>####bool与BOOL
>* 在 64 位操作系统上，OC 的 `BOOL`会直接等于定义的`stdbool.h`里面的`bool`，其实就是`int`,但如果在 32 位操作系统上，`BOOL`就会被定义成是一个`char`,而`BOOL`与`bool`，就分别是一个`byte`或是四个`bytes`的差别。
>* 所以，在 64 位操作系统上，`BOOL`与`bool`并没有区别，但我们不能确定我们写的代码只会在这种环境下执行，当然，在其他环境下应该也没什么影响。
>
>####`NULL` `nil` `Nil` `NSNull` `NSNotFound`
>
>>* **NULL**
>>* `NULL`其实并不算是 OC 的东西，而是属于 C 语言。`NULL`就是 C 语言当中的空指针，是指向 0 的指针。`nil`、`Nil`与`NULL`可以代替使用，但在语意上，当某个 API 想要传入某个指针`(void *)`时，而不是 `id` 类型时，虽然你可以在这种状态下也可以传入 OC 对象指针`nil`，但是传入 `NULL`意义会比较清楚。
>>* 总结：`id`用`nil`，`(void *)`用`NULL`。
>
>* ---------------------------------------------------------------------
>
>>* **nil**
>>* 是空的 OC 对象指针，也一样是指向 0.如果我们创建了一个 OC 对象的变量，当我们不想要使用这个对象的时候，便可以将这个变量指向 `nil`；我们可以对`nil`调用任何的 OC 对象，都不会产生问题。
>>* 在`NSArray`和`NSDictionary`中使用`nil`，会被当成是最后一个参数，出现在`nil`之后的参数都会被忽略。另外在对字典和数组插入`nil`的时候，程序会崩溃。
>
>* ---------------------------------------------------------------------
>
>>* **Nil**
>>* `nil`是空的实例，而开头大写的`Nil`则是指空的类。当我们要判断某个类是不是空的，语意上应该用`Nil`而不是`nil`。
>>* 比较可能的应用场合，就是判断在新的 iOS 系统上出现的新类，如果无法向下兼容，则执行其他代码。
>>
>>```swift
>>Class cls = NSClassFromString(@"Abcdefg");if (cls != Nil) {    // Do something.}
>>```
>
>* ---------------------------------------------------------------------
>
>>* **NSNull**
>>* `NSNull`是 OC 对象，在数组和字典中不可以插入`nil`，但可以通过插入`NSNull`对象表示没有东西。
>>* 在 JSON 文件里，转换成 OC 对象时，JSON 里面的 `null`则会转变成 `NSNull`对象。
>
>* ---------------------------------------------------------------------
>
>>* **NSNotFound**
>>* `NSNotFound`所代表的是找不到这个东西的`index`。`NSNotFound`是整数的最大值，通常不会建立这么大的数组。在 64 位操作系统和 32 位操作系统上整数的最大值是不一样的。如下面这段代码，在 64 位操作系统下是有问题的：
>>
>>```swift
>>int x = [@[@1, @2, @3] indexOfObject:@4];if (x != NSNotFound) {    NSLog(@"Found!");}
>>```
>>* 该代码中，`NSNotFound`在 64 位操作系统上整数的最大值，但 `x` 被转变成 32 位整数的最大值，所以`x`就无法等于`NSNotFound`了。

##Responder(响应者)
>####事件的传递
>* 传递过程：
>  * 硬件把事件传到我们的 App 中，交由`UIApplication`对象分配事件
>  * `UIApplication`把事件传送到`key Window`中，接着由`key Window`负责分派事件
>  * `key Window`开始寻找在视图层次中最上面的控制器与视图，然后发现在上面的视图是我们的按钮
>  * 触发按钮的点击事件。(如果没有事件处理，事件又会回到`application`上)
> 
> ![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170319_7.png)
> 
> * 从`application`到`window`到`view`，每一层中可以处理事件的对象，都叫做响应者。最终处理事件的对象，叫做第一响应者，而这种事件一层层传递的寻找处理事件的锁链，叫做响应者链条。
> 
> ####Run loop
> * `main.m`文件里面的做法：
>   * 建立`auto-release pool`
>   * 调用`UIApplicationMain`，创建`UIApplication`单利对象
>   * 执行`run loop`
>   * 调用`UIApplication`代理方法
>
>####Application
>* 硬件事件会被传递到`window`上，而其他系统事件，包括软件的开启和关闭，前台和后台等，都有转发给`application`的代理方法中。
>* 由于`application`位于相应者链条的最底层，每个视图与`window`都不处理的时候，才会对给`application`处理，所以如果我们希望处理一些会影响整个`App`行为的事情时，就会由`application`这一层处理。
>* 通过蓝牙耳机或数据线上的按钮切换歌曲，在 iOS7.1 之前，是通过在`application`代理方法中实现`remoteControlReceivedWithEvent:`方法，
>
>```swift
>- (void)remoteControlReceivedWithEvent:(UIEvent *)theEvent{    if (theEvent.type == UIEventTypeRemoteControl) {        switch(theEvent.subtype) {            case UIEventSubtypeRemoteControlPlay:                break;            case UIEventSubtypeRemoteControlPause:                break;            case UIEventSubtypeRemoteControlStop:                break;            case UIEventSubtypeRemoteControlTogglePlayPause:                break;            case UIEventSubtypeRemoteControlNextTrack:                break;            case UIEventSubtypeRemoteControlPreviousTrack:                break;			  ... default:			  return; 
		  }	 } 
}@end
>```
>* 当然，如果想要开始接收来自耳机的事件，还要对`application`单利对象调用`beginReceivingRemoteControlEvents`方法。
>* 在 iOS7.1以后，推出来`MPRemoteCommandCenter`这个类。之前想要开始播放，会在`remoteControlReceivedWithEvent:`里面处理`UIEventSubtypeRemoteControlPlay`的状态。现在会改成向`MPRemoteCommandCenter`要求`playCommand`,然后指定`target/action`，如下：
>
>```swift
>[[MPRemoteCommandCenter sharedCommandCenter].playCommand addTarget:self action:@selector(play:)];
>```
>####Window
>* `application`在收到触控等硬件事件之后，会把事件转发给`key window`。
>* 自己创建一个`window`对象，调用`makeKeyAndOrderFront`方法，显示该`window`，`makeKeyAndOrderFront`方法不但会让这个`window`显现，同时也会使该对象成为`key window`,所有的事件都会往这个`window`送，所以，如果该`wondow`使用完毕，必须对原来的`key window`再调用一次`makeKeyAndOrderFront`，把事件处理的权限交还回去。
>
>####View
>* `application`通过`sendEvent:`将事件送到`window`，`window`也一样通过`sendEvent:`将事件送到`view`上，而`view`里面，则是通过`hitTest:withEvent:`方法，在一层又一层的子视图中查找应该处理事件的子视图。
>
>####View Controller
>`view Controller`本身也是个相应者，因此也实现了`UIResponder`协议。当触控事件发生的时候，如果某个控制器的视图都不处理传来的事件，那么就会转向询问这个视图的控制器本身是否处理这个事件。
>
>####UITouch
>* 起初是个非常单纯的对象，顶多只会使用`locationInView:`判断触控事件发生在视图的哪个位置上，用`tapCount`知道触屏了几下，用`timestamp`知道触摸的时间。
>* iOS9添加了一些新的接口`coalescedTouchesForTouch`，获取比往常一轮`run loop`收到一次`touch`对象更快的刷新频率的触控事件对象，使反应更灵敏。
>* `predictedTouchesForTouch:`预测下一个触控事件可能出现的位置，让画面看起来即时更新。

##Threading
>####Perform Selector
>
>```swift
>-performSelectorOnMainThread: withObject: waitUntilDone: modes:
>-performSelectorOnMainThread: withObject: waitUntilDone:-performSelector: onThread: withObject: waitUntilDone: modes:-performSelector: onThread: withObject: waitUntilDone:-performSelectorInBackground: withObject:
>```
>* 无法管理应该要创建多少个子线程，才达到其硬件性能的上限。
>* 如果要在子线程上调用了一个方法，这个方法里面必须要有自己的缓冲池，才能正确释放对象。要建立缓冲池，在 ARC 模式下，可以使用`@autoreleasepool`关键字。（针对该方式）
>
>```swift
>- (void)backgroundTask{    @autoreleasepool {    	// Write your code here.    }}
>```
>####GCD Grand Central Dispatch 
>
>**dispatch_async**
>>
>>* 选择要在哪个指定的线程上，用非同步的方式执行一个 `block`。
>>
>>```swift
>>dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{    [someObject doSomethingHere];});
>>```
>>* `dispatch_get_global_queue`这个方法会让系统根据目前的状况，在恰当的时机建立一个子线程，第一个参数是这个线程执行工作的优先程度，从 2 到 -2，2 为最重要，-2 为最不重要。至于第二个参数则是保留参数，目前没有，直接填 0 即可。
>>* 如果已经在子线程，想要在主线程执行任务，就把`dispatch_get_global_queue`换成`dispatch_get_main_queue`。
>>
>>```swift
>>dispatch_async(dispatch_get_main_queue(), ^{    [someObject doSomethingHere];});
>>```
>>* 组合两者调用
>>
>>```swift
>>dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{    [someObject doSomethingInBackground];    dispatch_async(dispatch_get_main_queue(), ^{        [someObject doSomethingOnMainThread];    });});
>>```
>>* 在子线程，事件保持串行队列执行
>>
>>```swift
>>dispatch_queue_t serialQueue = dispatch_queue_create("com.kkbox.queue", DISPATCH_QUEUE_SERIAL);dispatch_async(serialQueue, ^{    [someObject doSomethingHere];});dispatch_async(serialQueue, ^{    [someObject doSomethingHereAsWell];});
>>```
>
>* **dispatch_sync**
>
>>* **注意：**已经在一条线程中，调用`dispatch_sync`时所传入的线程就是目前所在的线程，就会造成程序执行时卡死。如在主线程，但我们却调用：
>>
>>```swift
>>dispatch_sync(dispatch_get_main_queue(), ^{    [someObject doSomethingHere];});
>>```
>
>* 其他一些好用的 API
>* `dispatch_once`
>* `dispatch_after`
>* `dispatch_apply`
>  * 想要重复执行某个`block`，就可以考虑使用。有三个参数：第一个表示执行的次数，第二个表示执行的方式。
> 
> ####`NSOpertation`与`NSOperationQueue`
> * 可以中途取消某个线程
> * GCD 只支持 FIFO 的队列， 而`NSOperationQueue`可以调整队列的执行顺序。（通过调整权重）
> * `NSOperationQueue`可以在`Operation`间设置依赖关系，而 GCD 不可以。
> * `NSOperationQueue`是在 GCD 基础上实现的，只不过是 GCD 更高一层的抽象。
>
>####建立 NSOperationQueue
>```swift
>#import <Foundation/Foundation.h>@interface Test : NSObject@property (nonatomic, strong) NSOperationQueue *queue;@end@implementation Test- (instancetype)init{    self = [super init];    if (self) {        self.queue = [[NSOperationQueue alloc] init];        self.queue.maxConcurrentOperationCount = 2;    }    return self;}@end
>```
>
>* 通过`maxConcurrentOperationCount`设置可以并发执行的个数。该值大于 1，表示可以并发执行，如果等于 1，表示依次执行，等于 0 则不执行任务，默认 -1，表示让系统自己决定应该同时建立多少个子线程。
>* 可以通过对`NSOperationQueue`调用`addOperation:`加入操作。用`cancelAllOperations`取消所有正在线程排队执行的操作。至于已经在执行的操作，我们可以对特定的操作调用`cancel`。
>
>####建立 NSOperation
>* 包含两个`NSOperation`的子类：`NSBlockOperation`与`NSInvocationOperation`.
>* 要自定义一个`NSOperation`,最重要的就是要重写`main`这个方法，该方法里面代表的是这个操作要做什么事情
>
>```swift
>@interface RecipetUploadOperation : NSOperation@property (nonatomic, strong) UIImage *image;@property (nonatomic, strong) NSString *JSON;@end@implementation RecipetUploadOperation- (void)main{    @autoreleasepool {    	// 1. Upload image    	// 2. Upload JSON    }}@end
>```
>* 在 `main` 里面也要建立缓存池。
>
>####在Operation中等待与取消
>* **NSRunloop**
>* 除了主线程的`runloop`外（`[NSRunloop mainRunLoop]`），每一个线程都有自己的`runloop`，只要调用`[NSRunloop currentRunLoop]`便可以拿到当前线程的`runloop`。`NSRunloop`不可以手动建立，只能使用系统提供的。
>* 在`operation`执行到一半的时候可以被取消，调用`cancel`方法即可。如果是`operation`的子类，改变了`operation`里面做的事情。那么就得重写`cancel`:当该`operation`在跑`runloop`时，`cancel`必须要能够通知`runloop`停止。
>* 当一个线程跑在自己的`runloop`内时。如果不同线程间需要相互通信，就必须在当前线程建立`NSPort`对象，注册到`runloop`内，才能让信息传入到`runloop`内。所以，当外部要求对`port`调用`invalidate`时，就会让`runloop`收到消息，停止继续执行，继续执行`- main`方法接下来的动作。
>
>```swift
>@interface RecipetUploadOperation : NSOperation{    NSPort *port;    BOOL runloopRunning;}@property (nonatomic, strong) UIImage *image;@property (nonatomic, strong) NSString *JSON;@end@implementation RecipetUploadOperation- (void)main{    @autoreleasepool {        [someAPI uploadImageData:UIImagePNGRepresentation(self.image) callback:^ {            [self quitRunLoop];        }];        [self doRunloop];        if (self.isCancelled) {
        	  return; 
        }        [someAPI uploadJSON:self.JSON callback:^ {            [self quitRunLoop];
        }];        [self doRunloop];    }}- (void)doRunloop {    runloopRunning = YES;    port = [[NSPort alloc] init];    [[NSRunLoop currentRunLoop] addPort:port forMode:NSRunLoopCommonModes];    while (runloopRunning && !self.isCancelled) {        @autoreleasepool {            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];        }	}	port = nil; 
}- (void)quitRunLoop{    [port invalidate];    runloopRunning = NO;}- (void)cancel{    [super cancel];    [self quitRunLoop];}
@end
>```
>* **GCD**
>* 当我们想要在执行到一半的时候暂停下来，现在可以建立`semaphore`对象。
>  * 在要对`semaphore`调用`dispatch_semaphore_wait`,程序就会在这个地方停止等候。
> 对已经等候中的`semaphore`，再调用`dispatch_semaphore_signal`,发送`signal`，程序就会继续往下执行。
> 
> ```swift
> @import UIKit;@interface RecipetUploadOperation : NSOperation@property (nonatomic, strong) UIImage *image;@property (nonatomic, strong) NSString *JSON;@property (nonatomic, strong) dispatch_semaphore_t semaphore;@end@implementation RecipetUploadOperation- (void)main{    @autoreleasepool {        self.semaphore = dispatch_semaphore_create(0);        [someAPI uploadImageData:UIImagePNGRepresentation(self.image) callback:^ {            dispatch_semaphore_signal(self.semaphore);}];        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);        if (self.cancelled) {            return;        }        self.semaphore = dispatch_semaphore_create(0);        [someAPI uploadJSON:self.JSON callback:^ {            dispatch_semaphore_signal(self.semaphore);        }];        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);} }- (void)cancel{    [super cancel];    dispatch_semaphore_signal(self.semaphore);}@end
> ```

##实现`NSCoding`
>* `NSCoding`是一个协议，只有两个方法。
  * `encodeWithCoder:`将对象通过`NSCoder`转成`NSData`。
  * `initWithCoder:`通过`NSCoder`，再把`NSData`转回对象。


>```swift
@protocol NSCoding- (void)encodeWithCoder:(NSCoder *)aCoder;- (id)initWithCoder:(NSCoder *)aDecoder;@end
```
>归档／解档，详细细节（略）
>
>####State Preservation and Restoration
>* iOS6 新增 API，让 APP 可以在开始的时候，可以立即到上次关闭 APP 时的状态，方便用户恢复到之前的动作，而不受 APP 的开关闭／开启而打断。
>* **原理**：在应用程序关闭的时候，将 APP 的状态统统保存起来，下次应用程序开启的时候，如果发现存在之前保存的状态，就读取出来，重建上次保存的控制器。
>
>* 保存控制器的方法
>  * `- (void)encodeRestorableStateWithCoder:(NSCoder *)coder`
>  * `- (void)decodeRestorableStateWithCoder:(NSCoder *)coder`
>* 在`AppDelegate`则要实现
>  * `application: shouldSaveApplicationState:`
>  * `application: shouldRestoreApplicationState:`
>  * `application: willEncodeRestorableStateWithCoder:`>  * `application: didDecodeRestorableStateWithCoder:`>  * `application: willFinishLaunchingWithOptions:`
> * 步骤：
>  * 在程序关闭时，系统通过`application: shouldSaveApplicationState:`询问是否保存，返回 `BOOL` 值。
>  * 在返回需要保存时，系统就会通过`application:  shouldRestoreApplicationState:`,提供我们一个`NSCoder`，把必要的状态保存起来。如果 App 里面有一个导航控制器，而我们想把整个导航控制器存储起来，可以这样写：
> 
>   ```swift
> - (void)application:(UIApplication *)applicationwillEncodeRestorableStateWithCoder:(NSCoder *)coder{    	NSMutableArray *viewControllers = [self.navigationControllers.viewControllers copy];    	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:viewControllers];    	[coder encodeObject:data forKey:@"viewControllers"];}
>  ```
>  * 在程序重新启动时，如果系统发现之前已通过`NSCoder`保存状态，就会通过` application: shouldRestoreApplicationState:`,询问是否使用上次的状态，返回布尔值。
>  * 接下来，`application: didDecodeRestorableStateWithCoder:`就会被调用到，如果想要复原上次存起来的导航控制器，可以这样写：
>  
>  ```swift
> - (void)application:(UIApplication *)applicationdidDecodeRestorableStateWithCoder:(NSCoder *)coder{    	NSData *data = [coder decodeObjectForKey:@"viewControllers"];    	NSArray *viewControllers = [NSKeyedUnarchiver unarchiveObjectWithData:data];    	self.navigationController.viewControllers = viewControllers;}
> ```

##Crash Reports(崩溃报表)
>####通过`Xcode`收集
>* 链接真机，在 Xcode的设置条中，选择 `Window` -> `Devices`。
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170328_4.png)
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170328_7.png)
>* 在发生`crash`时，在`console`上面同时也会打印出来一些重要的信息。
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170328_8.png)
>
>####通过iTunes Connect收集
>* 在 `iTunes Connect` 中 指定 APP 的详细信息内，最下方，有一个额外信息：**崩溃报告**
>* 在 Xcode 的设置条中，选择 `Window` -> `Organizer`，也可以浏览线上的崩溃报告，是浏览变的方便，但都无法找到特定的用户。
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170329_1.png)
>
>####直接在设备上浏览（略）
>####通过第三方服务收集（略）

##Core Animation
>####CALayer
>iOS 上从某个`view`上面的`CALayer`开始着手。Mac 上的`NSView`预设没有`CALayer`,需要先把`NSView`的`wantsLayer`设置成`YES`，然后自己建立一个`CALayer`对象，设置`NSView`的`layer`属性。
>
>####CALayer与UIView的关系
>* `UIView`的外观呈现，都是由`Core Animation`实现，看到的`UIView`的样子，其实是里面的`CALayer`的样子。
>* `UIView`里面的`CALayer`本身就具有产生动画的能力，而改动`CALayer`的任何属性，都会产生 0.25 秒的动画，只是`UIKit`的设计是刻意把动画关闭了。
>* `drawRect:`用途不是绘制 `view`，而是绘制`CALayer`的内容。
>* `drawViewHierarchyInRect:afterScreenUpdates:`：iOS7 之后，由于此时的 UI 设计大量使用半透明毛玻璃效果的`View`，而用`CALayer`截出的图片无法抓到这部分。而新的 API 可以抓到无论是`UIKit`、`Quartz`、`OpenGL ES`、`SpriteKit`等这种绘图系统产生的画面。
>
> > ```swift
> > + (UIImage *)screenshotOfView:(UIView *)view{
> >     if (CGRectIsEmpty(view.frame)) {
        return nil;
    }
    UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, 0.0);
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
    // afterScreenUpdates的参数尽量设置为NO
       [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    }
    else{
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
> > ```
>  
>
>####设定`CALayer`的基本样式与属性
>* 因为改变任何属性都会产生动画，所以在建立`layer`之后，通常会先设定好`frame`，才把`layer`加到`super layer`上，不然反过来就会产生很奇怪的动画效果。
>* `CALayer`在建立完后，默认是一倍清晰度，所以在`Retina Display`的设备上看起来都会模糊。需要告诉`CALayer`应该要用怎样的清晰度，通过设定`contentsScale`属性
>  * `layer.contentsScale = [UIScreen mainScreen].scale;`
> 
> ####实现`drawInContext:`注意
> ```swift
> - (void)drawInContext:(CGContextRef)ctx{    UIGraphicsPushContext(ctx);    // Your drawing code here.    UIGraphicsPopContext();}
> ```

* 详细部分会从其他书籍笔记中概括

##Audio APIs
>####System Sound Services
>* 播放系统提示音
>* `AudioServicesCreateSystemSoundID` 和 `AudioServicesPlaySystemSound`
>
>```swift
>- (IBAction)testSystemSound:(id)sender 
{
    SystemSoundID soundID;
    NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"alertsound" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
    AudioServicesPlaySystemSound(soundID);
}
>```
>
>####OpenAL
>* 一般是用于游戏中提供立体的音效。
>
>####NSSound、QuickTime、AV Foundation
>* `NSSound`:主要用于在`Mac`上播放简短的提示音效，但提供了很多接口，可以支持多种格式，循环播放，调整音量等。可以说是一个完整的`Audio Player`,不过定位还是偏向用来播放系统提示音效
>
>* `AV Foundation`:按照出现时间排序
>  * `AVAudioPlayer`:支持多种格式，但只能播放本地的文件，无法在后台播放
>  * `AVPlayer`：iOS4 推出，可以满足绝大部分要求
>  * `AVAudioEngine`
> 
> ####Audio Queue
> * 更底层的用来播放与制作的 C API
> * 提供更多的播放效果，需要解密后播放。


##总结
* 做一个简单的个人总结，同时推荐给大家本书的大概内容。

>本书较为底层的概括了相关技术点，但个人感觉不是很深入。适合有一定开发经验的人概括性阅读，理解浅显的相关底层工作原理，做一个复习和巩固，但不适合作为研究深入的书籍。相关知识点还是解释的蛮详细的。

>重点介绍了`Audio APIs`,因为`KKBOX`就是一款音乐服务，从事一些跟`Audio`相关的开发。

>本笔记做了相关浓缩和整理。
>但任有少部分内容未做整理，主要原因：一坨一坨代码加文字，真没心情写。
