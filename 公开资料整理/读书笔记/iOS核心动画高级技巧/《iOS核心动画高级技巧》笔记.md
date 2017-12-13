##《iOS核心动画高级技巧》笔记

##1.图层的树状结构
* `Core Animation`是一个复合引擎，它的职责就是尽可能快地组合屏幕上不同的可视内容，这个内容是被分解成独立的图层，存储在一个叫做图层树的体系之中。于是这个树形成了`UIKit`以及在iOS应用程序当中你所能在屏幕上看见的一切的基础。

>* **视图：**在iOS当中,视图都从一个叫做`UIVIew`的基类派生而来，可以处理事件、支持绘图、旋转缩放、做动画等。
>* **图层：**`CALayer`类在概念上和`UIView`类似，和`UIView`最大的不同是`CALayer`不处理用户的交互。
>* **平行的层级关系：**每一个`UIview`都有一个`CALayer`实例的图层属性，**视图**的职责就是创建并管理这个图层，**图层**才是真正用来在屏幕上显示和做动画,`UIView`仅仅是对它的一个封装，提供具体功能。
>
>>为什么iOS要基于`UIView`和`CALayer`提供两个平行的层级关系,不用一个简单的层级来处理所有事情呢？
>>
>>* 原因在于要做职责分离，这样也能避免很多重复代码。就好比在`iOS`和`Mac OS`两个平台上，分别有`UIView`和`NSView`。他们功能上很相似，但是在实现上有着显著的区别。
>
>* 实际上，这里并不是两个层级关系，而是四个：视图层级，图层树，呈现树和渲染树。
>* **图层的能力**：
>  * 阴影，圆角，带颜色的边框
>  * 3D变换
>  * 非矩形范围
>  * 透明遮罩
>  * 多级非线性动画
> 
> * **使用视图而不是CALayer的好处：**你能在使用所有`CALayer`底层特性的同时，也可以使用`UIView`的高级`API`。以下情况除外：
>  * 开发同时可以在`Mac OS`上运行的跨平台应用
>  * 使用多种`CALayer`的子类，并且不想创建额外的`UIView`封装它们所有
>  * 做一些对性能特别挑剔的工作

##2.寄宿图
* 图层中包含的图

>####`contents`属性
>* `CALayer`的属性，类型被定义为`id`，但在实践中，如果你给`contents`赋的不是`CGImage`，那么你得到的图层将是空白的。
>
>>* 为什么该属性为`id`类型？
>>  * 因为在`Mac OS`系统上，这个属性对`CGImage`和`NSImage`类型的值都起作用。
>
>* 要赋值的类型是`CGImageRef`：是一个指向`CGImage`结构的指针:`typedef struct CGImage *CGImageRef`，是`Core Foundation`类型,不是`Cocoa`类型,需要`bridged`关键字转换。
>
>* **设置的代码：**`layer.contents = (__bridge id _Nullable)image.CGImage;`
>
>####`contentGravity`
>* 图片可能会有点变形。在`UIView`中，我们可以通过`contentMode`属性进行调节。
>* 对`UIView`大多数视觉相关的属性操作，其实是对对应图层的操作。
>* <mark>`CALayer`与`contentMode`对应的属性叫做`contentsGravity`，`NSString`类型.</mark>
>* `contentGravity`可选取值：
>  * `kCAGravityCenter`
>  * `kCAGravityTop`
>  * `kCAGravityBottom`
>  * `kCAGravityLeft`
>  * `kCAGravityRight`
>  * `kCAGravityTopLeft`
>  * `kCAGravityTopRight`
>  * `kCAGravityBottomLeft`
>  * `kCAGravityBottomRight`
>  * `kCAGravityResize`(根据视图的比例去拉伸图片内容
)
>  * `kCAGravityResizeAspect`(保持图片内容的纵横比例，来适应视图的大小
)
>  * `kCAGravityResizeAspectFill`(用图片内容来填充视图的大小，多余得部分可以被修剪掉来填充整个视图边界。)
> 
>####`contentsScale`
>* 定义了寄宿图的像素尺寸和视图大小的比例，默认为 `1.0` 。
>* 属于支持高分辨率（又称`Hi-DPI`或`Retina`）屏幕机制的一部分。它用来判断在绘制图层的时候应该为寄宿图创建的空间大小，和需要显示的图片的拉伸度.
>* <mark>对应`UIView`的`contentScaleFactor`属性。</mark>
>* 如果`contentsScale`设置为`1.0`，将会以每个点 `1` 个像素绘制图片，如果设置为`2.0`，则会以每个点`2`个像素绘制图片，这就是我们熟知的`Retina`屏幕。
>
>* **一定要记住要手动设置图层的该属性:**`layer.contentsScale = [UIScreen mainScreen].scale;`
>
>####`maskToBounds`
>* <mark>对应`UIView`的`clipsToBounds`属性</mark>
>* 用来决定是否显示超出边界的内容
>
>####`contentsRect`
>* 允许我们在图层边框里显示寄宿图的一个子域，默认取值是`{0, 0, 1, 1}`(**简单讲就是显示图片的一部分，取值都为 0～1 ，相对值**)。
>* **图片拼合：**单张大图包含许多小图片，利用该属性，每个图层显示某一张小图片，有效地提高了载入性能（单张大图比多张小图载入地更快）。
>
>####`contentsCenter`
>* `CGRect`类型，定义了一个固定的边框和一个在图层上**可拉伸的区域**。
>* 默认取值`{0, 0, 1, 1}`,意味着如果大小改变了,图片会均匀地拉伸开
>* 效果和`UIImage`里的`resizableImageWithCapInsets:`方法效果类似，**区别**是它可以运用到任何寄宿图，包括在Core Graphics运行时绘制的图形。
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170416_1.png)
>
>####自定义绘图
>* 设置`contents`不是唯一设置寄宿图的方法。也可以直接用`Core Graphics`绘制寄宿图。通过继承`UIView`并实现`drawRect:`方法来自定义绘制。
>* 该方法没有默认的实现，如果`UIView`检测到实现了该方法，就会为视图分配一个寄宿图，这个寄宿图的像素尺寸等于视图大小乘以 `contentsScale`的值。如果不需要寄宿图，那就不要创建这个方法，会造成`CPU`资源和内存的浪费.
>
> >* `CALayer`的`delegate`属性，实现了`CALayerDelegate`协议，当`CALayer`需要一个内容特定的信息时，就会从协议中请求。`UIView`默认遵守了该协议。
> >  * 当被重绘时，`CALayer`会请求它的代理给他一个寄宿图来显示。`-(void)displayLayer:(CALayer *)layer;`,趁着这个机会，如果代理想直接设置`contents`属性的话，它就可以这么做.
> >  * <mark>如果代理不实现</mark>`-displayLayer:`方法，`CALayer`才会尝试调用这个方法：`- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx;`,在调用这个方法之前，`CALayer`创建了一个合适尺寸的空寄宿图（尺寸由`bounds`和`contentsScale`决定）和一个`Core Graphics`的绘制上下文环境，为绘制寄宿图做准备，他作为`ctx`参数传入。
> > 
> > ```swift
> > @implementation ViewController
- (void)viewDidLoad
{
  [super viewDidLoad];
  CALayer *blueLayer = [CALayer layer];
  blueLayer.frame = CGRectMake(50.0f, 50.0f, 100.0f, 100.0f);
  blueLayer.backgroundColor = [UIColor blueColor].CGColor;
  blueLayer.delegate = self;
  blueLayer.contentsScale = [UIScreen mainScreen].scale;    
  [self.layerView.layer addSublayer:blueLayer];
  //不同于UIView，当图层显示在屏幕上时，CALayer不会自动重绘它的内容。它把重绘的决定权交给了开发者。
  //文档介绍：重新加载此图层的内容。 调用-drawInContext：方法，然后更新图层的`contents'属性。 通常不直接调用。
  [blueLayer display];
}
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
  CGContextSetLineWidth(ctx, 10.0f);
  CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
  CGContextStrokeEllipseInRect(ctx, layer.bounds);
}
@end
> > ```
> > * **注意：**代码中的`display`调用。
> > * 当`UIView`创建了它的宿主图层时，它就会自动地把图层的`delegate`设置为它自己，并提供了一个`-displayLayer:`的实现。
>
>* 当使用寄宿了视图的图层的时，不必实现`-displayLayer:`和`-drawLayer:inContext:`方法来绘制你的寄宿图。通常做法是实现`UIView`的`-drawRect:`方法，`UIView`就会帮你做完剩下的工作，包括在需要重绘的时候调用`-display`方法。

##3.图层几何学
* 内部是如何根据父图层和兄弟图层来控制位置和尺寸的，如何管理图层的几何结构，如何被自动调整和自动布局影响的。

>####布局
>* <mark>`UIView`有三个比较重要的布局属性：`frame，bounds 和 center`，`CALayer`对应地叫做`frame，bounds 和 position。`</mark>
>  * `frame`代表了图层的外部坐标
>  * `bounds`是内部坐标
>  * `center`和`position`都代表了相对于父图层`anchorPoint`所在的位置。
>* 当操纵视图的`frame`，实际上是在改变位于视图下方`CALayer`的`frame`，不能够独立于图层之外改变视图的`frame`。
>* `frame`并不是一个非常清晰的属性，它其实是一个虚拟属性，是根据`bounds，position和transform`计算而来，所以当其中任何一个值发生改变，`frame`都会变化。相反，改变`frame`的值同样会影响到他们当中的值
>
>>* 如图：当对图层做变换的时候，比如旋转或者缩放，`frame`实际上代表了覆盖在图层旋转之后的整个轴对齐的矩形区域，也就是说`frame`的宽高可能和`bounds`的宽高不再一致
>>
>>![](/Users/liuzhigao/Desktop/自定义转场动画/3.2.jpeg)
>
>####锚点
>* `anchorPoint`用单位坐标来描述，默认坐标是`{0.5, 0.5}`。
>* **个人理解：**如下图，中心点左右两边边距皆为视图宽度的一半，高度同理。改变视图中心点的位置至左上角后，同样有此规则，所以看到的视图向右下角移动了。
>
>![](/Users/liuzhigao/Desktop/自定义转场动画/3.3.jpeg)
>
>####坐标系
>* 一个图层的`position`依赖于它父图层的`bounds`
>* `CALayer`提供了一些方法(把定义在一个图层坐标系下的点或者矩形转换成另一个图层坐标系下的点或者矩形):
>  * `- (CGPoint)convertPoint:(CGPoint)point fromLayer:(CALayer *)layer;`
>  * `- (CGPoint)convertPoint:(CGPoint)point toLayer:(CALayer *)layer;`
>  * `- (CGRect)convertRect:(CGRect)rect fromLayer:(CALayer *)layer;`
>  * `- (CGRect)convertRect:(CGRect)rect toLayer:(CALayer *)layer;`
>
>* **翻转的几何结构:**
>  * `iOS`:图层的`position`位于父图层的**左上角**
>  * `Mac OS`:位于**左下角**。
>  * `geometryFlipped`：决定了一个图层的坐标是否相对于父图层垂直翻转，是一个`BOOL`类型。（它的所有子图层也同理，除非把它们的`geometryFlipped`属性也设为`YES`）。
>  * **个人理解：**设置为`YES`，假设原坐标系的起始点在左上角，现改成左下角，坐标系随之改变。
>* **Z坐标轴**
>* `CALayer`存在于一个三维空间当中,还有另外两个属性:
>  * `zPosition`:最实用的功能就是改变图层的显示顺序(*图层是根据它们子图层的`sublayers`出现的顺序来类绘制的*),不能改变事件传递的顺序。
>  * `anchorPointZ`：改变锚点在`Z`轴的位置。
>
>####点击测试
>* `CALayer`不直接处理触摸，手势事件,但有方法帮你处理事件。
>  * `-containsPoint:`：接受一个在本图层坐标系下的点，如果这个点在图层`frame`范围内就返回`YES`。
>  * `[self.layerView.layer containsPoint:point]`
>  * `-hitTest:`：接受一个在本图层坐标系下的点，如果这个点在图层`frame`范围内就返回图层本身，在之外则返回`nil`。测算的顺序严格依赖于图层树当中的图层顺序。
>  * `[self.layerView.layer hitTest:point]`
>
>* 如果改变了图层的 Z 轴顺序，将不能检测到最前方的视图点击事件，因为被另一个视图遮盖住了，虽然`zPosition`值较小，但是在图层树中的顺序靠前。
>
>####自动布局
>* `CALayer`的布局
>  * 通过`CALayerDelegate`的`layoutDublayersOfLayer:`函数。当图层的`bounds`发生改变或者图层的`setNeedsLayout`方法被调用的时候，该方法就会被执行。
>  * 不能像`UIView`一样做到屏幕自适应，也是为什么使用视图而不是图层构建程序的原因之一。

##4.视觉效果
>####圆角
>* `conrnerRadius`:圆角的曲率，只影响背景颜色而不影响背景图片或是子图层。可以通过把`masksToBounds`设置成`YES`，图层里面的所有东西都会被截取。
>* 创建一个有圆角和直角的图形可以通过图层蒙板或者`CAShapeLayer`。
>
>####图层边框
>* `borderWidth`
>* `borderColor`:`CGColorRef`类型
>* 边框是跟随图层的边界变化的，而不是图层里面的内容
>
>####阴影
>* `shadowOpacity`：0(不可见) ～ 1(完全不透明)
>* `shadowColor`: 阴影的颜色
>* `shadowOffset`: 阴影的方向和距离，默认 {0, -3},宽度决定横向位移，高度决定纵向位移。(前身是 Mac OS，两者 Y 轴颠倒，Mac OS 阴影朝下，iOS就朝上了)
>* `shadowRadius`: 阴影模糊度
>
>####阴影裁剪
>* 图层的阴影继承自内容的外形，而不是根据边界和角半径来确定。
>* `masksToBounds`把阴影裁剪的解决办法：
>  * 两个图层：一个只画阴影的空的外图层，一个用`masksToBounds`裁剪内容的内图层。
> 
>####`shadowPath`属性
>* 计算阴影是个消耗性能的操作，通过该属性来告诉系统阴影的形状，提高性能。
>* `CGPathRef`类型，一个指向`CGPath`的指针，`CGPath`是一个`Core Graphics`对象，用来指定任意的一个矢量图形。
>* 该属性用来指定任意阴影形状
>
>####`图层蒙版`
>* `mask`属性：图层实心部分会被保留下来，其他地方会被抛弃。
>
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170525_2.png)
>
>```swift
>@interface ViewCOntroller
>@property (nonatomic, weak) IBOutlet UIImageView *imageView
>@end
>
>@implementation ViewController
>- (void)viewDidLoad{
>		[super viewDidLoad];
>		CALayer *maskLayer = [CALayer layer];
>		maskLayer.frame = self.layerView.bounds;
>		UIImage *maskImage = [UIImage imageNamed:@"Cone.png"];
>		maskLayer.contents = (__bridge id)maskImage.CGImage;
>
>		self.imageView.layer.mask = maskLayer;
>}
>@end
>```
>
>####拉伸过滤
>* 以正确的比例和正确的1：1像素显示在屏幕上
>	* 能够显示最好的画质，像素既没有被压缩也没有被拉伸。
>	* 能更好的使用内存，因为这就是所有你要存储的东西。
>	* 最好的性能表现，CPU不需要为此额外的计算。
>
>>* `minificationFilter`:缩小图片，`magnificationFilter`:放大图片
>>  * `kCAFilterLinear`：默认值，采用双线性滤波算法，通过对多个像素取样最终生成新的值，得到一个平滑的表现不错的拉伸。但是当放大倍数比较大的时候图片就模糊不清。
>>  * `kCAFilterTrilinear`：和`kCAFilterLinear`非常相似，采用三线性滤波算法存储了多个大小情况下的图片（也叫多重贴图），并三维取样，同时结合大图和小图的存储进而得到最后的结果。<mark>**好处：**在于算法能够从一系列已经接近于最终大小的图片中得到想要的结果，也就是说不要对很多像素同步取样。这不仅提高了性能，也避免了小概率因舍入错误引起的取样失灵的问题</mark>
>>  * `kCAFilterNearest`：采用最近过滤算法，取样最近的单像素点而不管其他的颜色。速度快不会产生模糊，但会降低质量并像素化图像，马赛克化。适用于比较小的图或者是差异特别明显，极少斜线的大图。
>
>####组透明
>* 如果你给一个图层设置了`opacity`属性，那它的子图层都会受此影响。
>* 当你显示一个`50%`透明度的图层时，图层的每个像素都会一半显示自己的颜色，另一半显示图层下面的颜色。这是正常的透明度的表现。
>  * 但是如果图层包含一个同样显示`50%`透明的子图层时，你所看到的视图，`50%`来自子视图，`25%`来了图层本身的颜色，另外的`25%`则来自背景色。
>  * **个人理解：**当只有一个图层时，`50%`是自己的颜色，`50%`是背景的；当一个图层有一个子图层时，`50%`自己，另外`50%`的一半给父图层，一半给背景颜色。
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170526_1.png)
>
>* **整体透明解决方案：**
>  * 设置`Info.plist`文件中的`UIViewGroupOpacity`为`YES`来达到这个效果，但会影响到这个应用其他部分。
>  * `CALayer`的`shouldRasterize`属性为`YES`，在应用透明度之前，图层及其子图层都会被整合成一个整体的图片，这样就没有透明度混合的问题了
>
>当`shouldRasterize`和`UIViewGroupOpacity`一起的时候，性能问题就出现了）
>

##5.变换
* 研究可以用来对图层旋转，摆放或者扭曲的`CGAffineTransform`，以及可以将扁平物体转换成三维空间对象的`CATransform3D`

>####仿射变换
>* `UIView`的`transform`属性是一个`CGAffineTransform`类型，用于在二维空间做旋转，缩放和平移，实际上它只是封装了内部图层的变换。
>
>```swift
>CGAffineTransformMakeRotation(CGFloat angle)
CGAffineTransformMakeScale(CGFloat sx, CGFloat sy)
CGAffineTransformMakeTranslation(CGFloat tx, CGFloat ty)
>```
>
>* `CALayer`同样也有一个`transform`属性，但它的类型是`CATransform3D`，而不是`CGAffineTransform`。
>* `CALayer`对应于`UIView`的`transform`属性是`affineTransform`.
>
>* 弧度换算：`#define DEGREES_TO_RADIANS(x) ((x)/180.0*M_PI)`，
>  * `M_PI`：180(度)，`M_PI_4`：180/4(度)
>
>```swift
>
>@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIView *layerView;
@end
@implementation ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_4);
    self.layerView.layer.affineTransform = transform;
}
@end
>```
>
>#####混合变换
>* 当操纵一个变换的时候，初始生成一个什么都不做的变换很重要
>  * `CGAffineTransformIdentity`
>* 混合两个已经存在的变换矩阵
>  * `CGAffineTransformConcat(CGAffineTransform t1, CGAffineTransform t2);`
>* 注意：**下一个变换是基于上一个变换的结果**
>
>```swift
>- (void)viewDidLoad
{
    [super viewDidLoad];
    CGAffineTransform transform = CGAffineTransformIdentity; 
    transform = CGAffineTransformScale(transform, 0.5, 0.5);
    transform = CGAffineTransformRotate(transform, M_PI / 180.0 * 30.0);
    transform = CGAffineTransformTranslate(transform, 200, 0);
    self.layerView.layer.affineTransform = transform;
}
>```
>
>####3D变换
>* `CG`的前缀告诉我们，`CGAffineTransform`类型属于`Core Graphics`框架，`Core Graphics`实际上是一个严格意义上的`2D`绘图`API`，并且`CGAffineTransform`仅仅对`2D`变换有效。
>
>```swift
>CATransform3DMakeRotation(CGFloat angle, CGFloat x, CGFloat y, CGFloat z)
CATransform3DMakeScale(CGFloat sx, CGFloat sy, CGFloat sz) 
CATransform3DMakeTranslation(Gloat tx, CGFloat ty, CGFloat tz)
>```
>* 简单运用。
>
>```swift
>@implementation ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    CATransform3D transform = CATransform3DMakeRotation(M_PI_4, 0, 1, 0);
    self.layerView.layer.transform = transform;
}
@end
>```
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170526_2.png)
>
>#####透视投影
>* `CATransform3D`的透视效果通过一个矩阵中一个很简单的元素来控制：`m34`
>  * `m34`的默认值是 0，我们可以通过设置`m34`为`-1.0 / d`来应用透视效果，`d`代表了想象中视角相机和屏幕之间的距离，以像素为单位,通常`500-1000`就已经很好了
>
>```swift
>@implementation ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = - 1.0 / 500.0;
    transform = CATransform3DRotate(transform, M_PI_4, 0, 1, 0);
    self.layerView.layer.transform = transform;
}
@end
>```
>
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170526_3.png)
>
>#####灭点
>* 当在透视角度绘图的时候，远离相机视角的物体将会变小变远，当远离到一个极限距离，它们  可能就缩成了一个点，于是所有的物体最后都汇聚消失在同一个点。
>* 这个点位于变换图层的`anchorPoint`,改变一个图层的`position`，你也改变了它的灭点
>* **这句话大家自己理解，为什么要共享一个灭点？我估计效果应该是让其他3D图层整体看起来更加协调一些。**
>  * 当视图通过调整`m34`来让它更加有`3D`效果，应该首先把它放置于屏幕中央，然后通过平移来把它移动到指定位置（而不是直接改变它的`position`），这样所有的`3D`图层都共享一个灭点。
>
>#####`sublayerTransform`属性
>* `sublayerTransform`：`CALayer`的属性，`CATransform3D`类型，一次性对包含这些图层的容器做变换，所有的子图层都自动继承了这个变换方法.
>* **另一个显著的优势：**灭点被设置在容器图层的中点，从而不需要再对子图层分别设置了。意味着你可以随意使用`position`和`frame`来放置子图层，而不需要把它们放置在屏幕中点，然后为了保证统一的灭点用变换来做平移。
>
>```swift
>@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIView *layerView1;
@property (nonatomic, weak) IBOutlet UIView *layerView2;
@end
@implementation ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = - 1.0 / 500.0;
    self.containerView.layer.sublayerTransform = perspective;
    CATransform3D transform1 = CATransform3DMakeRotation(M_PI_4, 0, 1, 0);
    self.layerView1.layer.transform = transform1;
    CATransform3D transform2 = CATransform3DMakeRotation(-M_PI_4, 0, 1, 0);
    self.layerView2.layer.transform = transform2;
}
>```
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170526_4.png)
>
>* **个人理解：**对于内部的图层并不直接是容器图层的子图层没有效果，如：内部图层的内部图层。
>
>#####背面
>* 图层是双面绘制的，反面显示的是正面的一个镜像图片。
>* `doubleSided`：`CALayer`的属性，控制图层的背面是否要被绘制。这是一个`BOOL`类型，默认为`YES`。
>  * 如果设置为`NO`，那么当图层正面从相机视角消失的时候，它将不会被绘制。
>
>#####扁平化图层
>
>>* 如果对包含已经做过变换的图层的图层做反方向的变换是否会回复原样？
>>  * 针对 Z 轴做平面旋转可以达到预期效果(白色内部的深灰色图层是反方向变换后的，下同)
>> ![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170526_5.png)
>>  * 针对 Y 轴做立体旋转不能达到预期效果
>> ![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170526_6.png)
>>  * 针对 Y 轴旋转预期效果
>> ![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170526_7.png)
>
>* 由于它们并不都存在同一个3D空间。每个图层的3D场景其实是扁平化的，当你从正面观察一个图层，看到的实际上由子图层创建的想象出来的3D场景，但当你倾斜这个图层，你会发现实际上这个3D场景仅仅是被绘制在图层的表面。(`CATransformLayer`子类用于解决此类问题)
>* **个人理解：**每个图层都有属于自己的3D空间，子图层3D效果是基于父图层的3D空间进行绘制的，所以父图层变换后，子图层变换是基于父图层。
>
>####固体对象(略)[原文地址](https://zsisme.gitbooks.io/ios-/chapter5/solid-objects.html)
>大概内容就是通过代码用六个视图控件拼成一个立方体，导入`GLKit`库进行阴暗面处理，最后监听 3 上按钮的点击事件。
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170526_8.png)

##6.专用图层
* [CAShapeLayer](#markdown-one)
* [CATextLayer](#markdown-two)
* [CATransformLayer](#markdown-three)
* [CAGradientLayer](#markdown-four)
* [CAReplicatorLayer](#markdown-five)
* [CAScrollLayer](#markdown-six)
* [CATiledLayer](#markdown-seven)
* [CAEmitterLayer](#markdown-eight)
* [CAEAGLLayer／CAOpenGLLayer](#markdown-night)
* [CAMetalLayer](#markdown-ten)
* [AVPlayerLayer](#markdown-onee)
* [demo](#markdown-twoo)

>####<a name="markdown-one"></a>CAShapeLayer
>* `CAShapeLayer`属性是`CGPathRef`类型，通过矢量图形而不是`bitmap`来绘制的图层子类
>  * 渲染快速。`CAShapeLayer`使用了硬件加速，绘制同一图形会比用`Core Graphics`快很多。
>  * 高效使用内存。一个`CAShapeLayer`不需要像普通`CALayer`一样创建一个寄宿图形，所以无论有多大，都不会占用太多的内存。
>  * 不会被图层边界剪裁掉。一个`CAShapeLayer`可以在边界之外绘制。你的图层路径不会像在使用`Core Graphics`的普通`CALayer`一样被剪裁掉。
>  * 不会出现像素化。当你给`CAShapeLayer`做3D变换时，它不像一个有寄宿图的普通图层一样变得像素化。
>
>```swift
>// 简单使用
>	UIBezierPath *path = [[UIBezierPath alloc] init];
  [path moveToPoint:CGPointMake(175, 100)];
  ￼
  [path addArcWithCenter:CGPointMake(150, 100) radius:25 startAngle:0 endAngle:2*M_PI clockwise:YES];
  [path moveToPoint:CGPointMake(150, 125)];
  [path addLineToPoint:CGPointMake(150, 175)];
  [path addLineToPoint:CGPointMake(125, 225)];
  [path moveToPoint:CGPointMake(150, 175)];
  [path addLineToPoint:CGPointMake(175, 225)];
  [path moveToPoint:CGPointMake(100, 150)];
  [path addLineToPoint:CGPointMake(200, 150)];

>   CAShapeLayer *shapeLayer = [CAShapeLayer layer];
  shapeLayer.strokeColor = [UIColor redColor].CGColor;
  shapeLayer.fillColor = [UIColor clearColor].CGColor;
  shapeLayer.lineWidth = 5;
  shapeLayer.lineJoin = kCALineJoinRound;
  shapeLayer.lineCap = kCALineCapRound;
  shapeLayer.path = path.CGPath;

>  [self.containerView.layer addSublayer:shapeLayer];
>```
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170527_1.png)
>
>#####圆角(可以单独指定每个角)
>* 绘制一个有三个圆角一个直角的矩形
>
>```swift
>CGRect rect = CGRectMake(50, 50, 100, 100);
CGSize radii = CGSizeMake(20, 20);
UIRectCorner corners = UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft;
//create path
UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:radii];
>```
>* 把`CAShapeLayer`作为视图的宿主图层，而不是添加一个子视图(**图层蒙板的`mask`属性**)
>
>####<a name="markdown-two"></a>CATextLayer
>* 使用了`Core text`来实现绘制的，比`UILabel`渲染得快得多.
>
>```swift
>// 简单使用
>   CATextLayer *textLayer = [CATextLayer layer];
  textLayer.frame = self.labelView.bounds;
  [self.labelView.layer addSublayer:textLayer];

>   textLayer.foregroundColor = [UIColor blackColor].CGColor;
  textLayer.alignmentMode = kCAAlignmentJustified;
  textLayer.wrapped = YES;

>   UIFont *font = [UIFont systemFontOfSize:15];

>   CFStringRef fontName = (__bridge CFStringRef)font.fontName;
  CGFontRef fontRef = CGFontCreateWithFontName(fontName);
  textLayer.font = fontRef;
  textLayer.fontSize = font.pointSize;
  CGFontRelease(fontRef);

>   textLayer.contentsScale = [UIScreen mainScreen].scale;
>   NSString *text = @"Lorem ipsum dolor sit amet, consectetur adipiscing \ elit. Quisque massa arcu, eleifend vel varius in, facilisis pulvinar \ leo. Nunc quis nunc at mauris pharetra condimentum ut ac neque. Nunc elementum, libero ut porttitor dictum, diam odio congue lacus, vel \ fringilla sapien diam at purus. Etiam suscipit pretium nunc sit amet \ lobortis";

>   textLayer.string = text;
>```
>* `CATextLayer`的`font`属性是一个`CFTypeRef`类型，可以根据你的具体需要来决定字体属性应该是用`CGFontRef`类型还是`CTFontRef`类型（`Core Text`字体）。
>* `CATextLayer`的`string`属性是 `id` 类型，这样既可以用`NSString`也可以用`NSAttributedString`来指定文本了。
>
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170531_1.png)
>
>#####富文本
>* `NSTextAttributeName`针对`iOS 6`及以上，此处演示是在`iOS 5`及以下
>
>```swift
>   CATextLayer *textLayer = [CATextLayer layer];
  textLayer.frame = self.labelView.bounds;
  textLayer.contentsScale = [UIScreen mainScreen].scale;
  [self.labelView.layer addSublayer:textLayer];

>   textLayer.alignmentMode = kCAAlignmentJustified;
  textLayer.wrapped = YES;

>   UIFont *font = [UIFont systemFontOfSize:15];

>   NSString * text = @"Lorem ipsum dolor sit amet, consectetur adipiscing \ elit. Quisque massa arcu, eleifend vel varius in, facilisis pulvinar \ leo. Nunc quis nunc at mauris pharetra condimentum ut ac neque. Nunc \ elementum, libero ut porttitor dictum, diam odio congue lacus, vel \ fringilla sapien diam at purus. Etiam suscipit pretium nunc sit amet \ lobortis";
  ￼
>   NSMutableAttributedString *string = nil;
  string = [[NSMutableAttributedString alloc] initWithString:text];

>   CFStringRef fontName = (__bridge CFStringRef)font.fontName;
  CGFloat fontSize = font.pointSize;
  CTFontRef fontRef = CTFontCreateWithName(fontName, fontSize, NULL);

>   NSDictionary *attribs = @{
     (__bridge id)kCTForegroundColorAttributeName:(__bridge id)[UIColor blackColor].CGColor,
     (__bridge id)kCTFontAttributeName: (__bridge id)fontRef
  };

>   [string setAttributes:attribs range:NSMakeRange(0, [text length])];
  attribs = @{
     (__bridge id)kCTForegroundColorAttributeName: (__bridge id)[UIColor redColor].CGColor,
     (__bridge id)kCTUnderlineStyleAttributeName: @(kCTUnderlineStyleSingle),
     (__bridge id)kCTFontAttributeName: (__bridge id)fontRef
  };
  [string setAttributes:attribs range:NSMakeRange(6, 5)];

>   CFRelease(fontRef);

>   textLayer.string = string;
>```
>
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170531_2.png)
>
>#####行距和字距
>* 用`CATextLayer`渲染和用`UILabel`渲染出的文本行距和字距不相同的。
>
>#####UILabel的替代品
>* 以下演示了一个`UILabel`子类`LayerLabel`用`CATextLayer`绘制它的问题，不是调用一般的`UILabel`使用的较慢的`-drawRect：`方法。`LayerLabel`示例既可以用代码实现，也可以在`Interface Builder`中实现，只要把普通的标签拖入视图之中，然后设置它的类是`LayerLabel`就可以了。
>
>```swift
>#import "LayerLabel.h"
#import 
> @implementation LayerLabel
+ (Class)layerClass
{
   return [CATextLayer class];
}
> - (CATextLayer *)textLayer
{
   return (CATextLayer *)self.layer;
}
>- (void)setUp
{
   self.text = self.text;
   self.textColor = self.textColor;
   self.font = self.font;

>    [self textLayer].alignmentMode = kCAAlignmentJustified;
  ￼
>    [self textLayer].wrapped = YES;
   [self.layer display];
}
>- (id)initWithFrame:(CGRect)frame
{
   if (self = [super initWithFrame:frame]) {
     [self setUp];
   }
   return self;
}
>- (void)awakeFromNib
{
   [self setUp];
}
>- (void)setText:(NSString *)text
{
   super.text = text;
   [self textLayer].string = text;
}
>- (void)setTextColor:(UIColor *)textColor
{
   super.textColor = textColor;
   [self textLayer].foregroundColor = textColor.CGColor;
}
>- (void)setFont:(UIFont *)font
{
   super.font = font;
   CFStringRef fontName = (__bridge CFStringRef)font.fontName;
   CGFontRef fontRef = CGFontCreateWithFontName(fontName);
   [self textLayer].font = fontRef;
   [self textLayer].fontSize = font.pointSize;
  ￼
   CGFontRelease(fontRef);
}
@end
>```
>* 把`CATextLayer`作为宿主图层的另一好处就是视图自动设置了`contentsScale`属性。
>* 如果你打算支持`iOS 6`及以上，基于`CATextLayer`的标签可能就有有些局限性。但是总得来说，如果想在app里面充分利用`CALayer`子类，用`+layerClass`来创建基于不同图层的视图是一个简单可复用的方法。
>
>####<a name="markdown-three"></a>CATransformLayer
>* `CATransformLayer`不能显示它自己的内容。只有当存在了一个能作用域子图层的变换它才真正存在。`CATransformLayer`并不平面化它的子图层，所以它能够用于构造一个层级的3D结构。
>
>* 同样的代码，用`CALayer`
>
>![](/Users/liuzhigao/Desktop/自定义转场动画/22.gif)
>
>* 同样的代码，用`CATransformLayer`
>
>![](/Users/liuzhigao/Desktop/自定义转场动画/11.gif)
>
>* 简单使用
>
>```swift
    // 普通的一个layer
    CALayer *plane        = [CALayer layer];
    plane.anchorPoint = CGPointMake(0.5, 0.5);                         // 锚点
    plane.frame       = (CGRect){CGPointZero, CGSizeMake(100, 100)};   // 尺寸
    plane.position    = CGPointMake(200, V_CENTER_Y);                  // 位置
    plane.opacity         = 0.6;                                       // 背景透明度
    plane.backgroundColor = CG_COLOR(0, 1, 0, 1);                      // 背景色
    plane.borderWidth     = 3;                                         // 边框宽度
    plane.borderColor     = CG_COLOR(1, 1, 1, 0.5);                    // 边框颜色(设置了透明度)
    plane.cornerRadius    = 10;                                        // 圆角值
    
>     // Z轴平移
    CATransform3D plane_3D = CATransform3DIdentity;
    plane_3D               = CATransform3DTranslate(plane_3D, 0, 0, -30);
    plane.transform        = plane_3D;
    
>     // 创建容器layer
    CATransformLayer *container = [CATransformLayer layer];
    container.frame    = self.view.bounds;
    [self.view.layer addSublayer:container];
    [container addSublayer:plane];
    
>     // 启动定时器
    _timer = [[GCDTimer alloc] initInQueue:[GCDQueue mainQueue]];
    [_timer event:^{
        static float degree = 0.f;
        
>         // 起始值
        CATransform3D fromValue = CATransform3DIdentity;
        fromValue.m34           = 1.0/ -500;
        fromValue               = CATransform3DRotate(fromValue, degree, 0, 1, 0);
        
>         // 结束值
        CATransform3D toValue   = CATransform3DIdentity;
        toValue.m34             = 1.0/ -500;
        toValue                 = CATransform3DRotate(toValue, degree += 45.f, 0, 1, 0);
        
>         // 添加3d动画
        CABasicAnimation *transform3D = [CABasicAnimation animationWithKeyPath:@"transform"];
        transform3D.duration  = 1.f;
        transform3D.fromValue = [NSValue valueWithCATransform3D:fromValue];
        transform3D.toValue   = [NSValue valueWithCATransform3D:toValue];
        
>         container.transform = toValue;
        [container addAnimation:transform3D forKey:@"transform3D"];
        
>    } timeInterval:NSEC_PER_SEC];
   [_timer start];
>```
>* 通过如下两张图片能够更好的体现出它的作用(上面用 `CALayer`，下面用`CAGradientLayer`)。
>
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170601_1.png)
>
>```swift
>//给planes应用变换
t = CATransform3DIdentity;
t = CATransform3DTranslate(t, 0, 0, -10);
purplePlane.transform = t;

> t = CATransform3DIdentity;
t = CATransform3DTranslate(t, 0, 0, -50);
redPlane.transform = t;

> t = CATransform3DIdentity;
t = CATransform3DTranslate(t, 0, 0, -90);
orangePlane.transform = t;

>t = CATransform3DIdentity;
t = CATransform3DTranslate(t, 0, 0, -130);
yellowPlane.transform = t;
>```
>* 同样的代码，可见`CALayer`不能够管理3D层级的深度。`CATransformLayer`并不平面化它的子图层，能够用于构造一个层级的3D结构，
>
>####<a name="markdown-four"></a>CAGradientLayer
>* `CAGradientLayer`是用来生成两种或更多颜色平滑渐变的，真正好处在于绘制使用了硬件加速。
>
>#####基础渐变
>* `CAGradientLayer`有`startPoint`和`endPoint`属性，决定了渐变的方向。这两个参数是以单位坐标系进行的定义，所以左上角坐标是{0, 0}，右下角坐标是{1, 1}。
>
>```swift
>   CAGradientLayer *gradientLayer = [CAGradientLayer layer];
  gradientLayer.frame = self.containerView.bounds;
  [self.containerView.layer addSublayer:gradientLayer];

>   //gradientLayer.colors = @[(id)[UIColor redColor].CGColor,(id)[UIColor blueColor].CGColor];
>   gradientLayer.colors = @[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[UIColor blueColor].CGColor];

>   gradientLayer.startPoint = CGPointMake(0, 0);
  gradientLayer.endPoint = CGPointMake(1, 1);
>```
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170531_3.png)
>
>#####多重渐变
>* `colors`属性可以包含很多颜色，在空间上均匀地被渲染。可以用`locations`属性来调整空间。`locations`属性是一个浮点数值的数组（以`NSNumber`包装）。定义了`colors`属性中每个不同颜色的位置，同样的，也是以单位坐标系进行标定。`0.0`代表着渐变的开始，`1.0`代表着结束.
>* `locations`数组并不是强制要求的，但是如果你给它赋值了就一定要确保`locations`的数组大小和`colors`数组大小一定要相同，否则你将会得到一个空白的渐变。
>
>```swift
>   CAGradientLayer *gradientLayer = [CAGradientLayer layer];
  gradientLayer.frame = self.containerView.bounds;
  [self.containerView.layer addSublayer:gradientLayer];

>   gradientLayer.colors = @[(__bridge id)[UIColor redColor].CGColor, (__bridge id) [UIColor yellowColor].CGColor, (__bridge id)[UIColor greenColor].CGColor];

>   gradientLayer.locations = @[@0.0, @0.25, @0.5];

>   gradientLayer.startPoint = CGPointMake(0, 0);
  gradientLayer.endPoint = CGPointMake(1, 1);
>```
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170531_4.png)
>
>####<a name="markdown-five"></a>CAReplicatorLayer
>* 目的是为了高效生成许多相似的图层。
>
>#####重复图层
>* `instanceCount`属性指定了图层需要重复多少次。
>* `instanceTransform`指定了一个`CATransform3D`3D变换。变换是逐步增加的，每个实例都是相对于前一实例布局。这就是为什么这些复制体最终不会出现在同意位置上.
>
>```swift
>     CAReplicatorLayer *replicator = [CAReplicatorLayer layer];
    replicator.frame = self.containerView.bounds;
    [self.containerView.layer addSublayer:replicator];

>     replicator.instanceCount = 10;

>     CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DTranslate(transform, 0, 200, 0);
    transform = CATransform3DRotate(transform, M_PI / 5.0, 0, 0, 1);
    transform = CATransform3DTranslate(transform, 0, -200, 0);
    replicator.instanceTransform = transform;

>     replicator.instanceBlueOffset = -0.1;
    replicator.instanceGreenOffset = -0.1;

>     CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(100.0f, 100.0f, 100.0f, 100.0f);
    layer.backgroundColor = [UIColor whiteColor].CGColor;
    [replicator addSublayer:layer];
>```
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170601_5.png)
>
>* `instanceBlueOffset`和`instanceGreenOffset`属性通过逐步减少蓝色和绿色通道，逐渐将图层颜色转换成了红色。
>
>#####反射
>* 使用`CAReplicatorLayer`并应用一个负比例变换于一个复制图层，你就可以创建指定视图内容的镜像图片，这样就创建了一个实时的『反射』效果。
>
>```swift
>#import "ReflectionView.h"
#import 
@implementation ReflectionView
+ (Class)layerClass
{
    return [CAReplicatorLayer class];
}
- (void)setUp
{
    CAReplicatorLayer *layer = (CAReplicatorLayer *)self.layer;
    layer.instanceCount = 2;

>     CATransform3D transform = CATransform3DIdentity;
    CGFloat verticalOffset = self.bounds.size.height + 2;
    transform = CATransform3DTranslate(transform, 0, verticalOffset, 0);
    transform = CATransform3DScale(transform, 1, -1, 0);
    layer.instanceTransform = transform;

>     layer.instanceAlphaOffset = -0.6;
}
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setUp];
    }
    return self;
}
>- (void)awakeFromNib
{
    [self setUp];
}
@end
>```
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170601_2.png)
>
>####<a name="markdown-six"></a>CAScrollLayer
>* 作用相当于`UIScrollView`，但`scrollerView`是控件与控件之间的滑动，这是图层与图层之间的滑动。
>* `CAScrollLayer`的可滚动区域的范围是由它的子层布局来确定的。`CAScrollLayer`不提供键盘或鼠标事件处理，也没有提供可见滚动条。
>
>```swift
>#import "ScrollLayer.h"
@interface ScrollLayer ()
@property (nonatomic, strong) CAScrollLayer *scrollLayer;
@end
@implementation ScrollLayer
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
>     CALayer *layer = [CALayer layer];
    layer.contents = (id)[UIImage imageNamed:@"bg.jpg"].CGImage;
    layer.frame = CGRectMake(80, 80, 100, 100);
    
>     self.scrollLayer = [CAScrollLayer layer];
    self.scrollLayer.frame = CGRectMake(60, 80, 200, 200);
    self.scrollLayer.backgroundColor = [UIColor orangeColor].CGColor;
    [self.scrollLayer addSublayer:layer];
    self.scrollLayer.scrollMode = kCAScrollBoth;
    [self.view.layer addSublayer:self.scrollLayer];
    
>     // 这个判断只是判断手势，可以先判断出发点是否在当前的大小里再去响应手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:pan];
}
- (void)pan:(UIPanGestureRecognizer *)recognizer {
    CGPoint offset = self.scrollLayer.bounds.origin;
    offset.x -= [recognizer translationInView:self.view].x;
    offset.y -= [recognizer translationInView:self.view].y;
    
>     [self.scrollLayer scrollToPoint:offset];
    
>     [recognizer setTranslation:CGPointZero inView:self.view];
}
>```
>![](/Users/liuzhigao/Desktop/自定义转场动画/333.gif)
>
>* `scrollMode`:设置滚动的方向。
>* `scrollToPoint`:自动适应`bounds`的原点以便图层内容出现在滑动的地方。
>* `scrollToRect`:滚动图层的内容以确保该区域可见。
>* 扩展分类
>  * `scrollPoint:`方法是从自身开始往父图层找到最近的`CAScrollLayer`层，然后调用`scrollToPoint:`方法，如果没有找到`CAScrollLayer`层则不做任何处理。
>  * `scrollRectToVisible:`方法是从自身开始往父图层找到最近的`CAScrollLayer`层，然后调用`scrollToRect:`方法，如果没有找到`CAScrollLayer`层则不做任何处理。
>  * `visibleRect`返回可见区域范围。 
> 
>####<a name="markdown-seven"></a>CATiledLayer
>* 所有显示在屏幕上的图片最终都会被转化为`OpenGL`纹理，同时`OpenGL`有一个最大的纹理尺寸（通常是`2048*2048`，或`4096*4096`，这个取决于设备型号）。
>* 如果你想在单个纹理中显示一个比这大的图，即便图片已经存在于内存中了，你仍然会遇到很大的性能问题，因为`Core Animation`强制用`CPU`处理图片而不是更快的`GPU`
>* `CATiledLayer`为载入大图造成的性能问题提供了一个解决方案：将大图分解成小片然后将他们单独按需载入。
>* `CATiledLayer`优势的基础是先把这个图片裁切成许多小一些的图片。如果在运行时读入整个图片并裁切，那`CATiledLayer`的性能优点就损失殆尽了。	
>
>#####小片裁剪
>* 将一张大的图片裁切成许多小一些的图片。(Mac程序)
>
>```swift
>#import 
int main(int argc, const char * argv[])
{
    @autoreleasepool{
        if (argc < 2) {
            NSLog(@"TileCutter arguments: inputfile");
            return 0;
        }
        NSString *inputFile = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
        
>         CGFloat tileSize = 256; //output path
        NSString *outputPath = [inputFile stringByDeletingPathExtension];

>         NSImage *image = [[NSImage alloc] initWithContentsOfFile:inputFile];
        NSSize size = [image size];
        NSArray *representations = [image representations];
        if ([representations count]){
            NSBitmapImageRep *representation = representations[0];
            size.width = [representation pixelsWide];
            size.height = [representation pixelsHigh];
        }
        NSRect rect = NSMakeRect(0.0, 0.0, size.width, size.height);
        CGImageRef imageRef = [image CGImageForProposedRect:&rect context:NULL hints:nil];

>         NSInteger rows = ceil(size.height / tileSize);
        NSInteger cols = ceil(size.width / tileSize);

>        for (int y = 0; y < rows; ++y) {
            for (int x = 0; x < cols; ++x) {
            CGRect tileRect = CGRectMake(x*tileSize, y*tileSize, tileSize, tileSize);
            CGImageRef tileImage = CGImageCreateWithImageInRect(imageRef, tileRect);

>             NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithCGImage:tileImage];
            NSData *data = [imageRep representationUsingType: NSJPEGFileType properties:nil];
            CGImageRelease(tileImage);

>            NSString *path = [outputPath stringByAppendingFormat: @"_%02i_%02i.jpg", x, y];
            [data writeToFile:path atomically:NO];
            }
        }
    }
    return 0;
}
>```
>* `256*256`是`CATiledLayer`的默认小图大小，可以通过`tileSize`属性更改。`tileSize`是以像素为单位，而不是点。
>* 运行结果是64个新图的序列
>
>```swift
>#import "ViewController.h"
#import 
@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@end
@implementation ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    CATiledLayer *tileLayer = [CATiledLayer layer];￼
    tileLayer.frame = CGRectMake(0, 0, 2048, 2048);
    tileLayer.delegate = self; 
    [self.scrollView.layer addSublayer:tileLayer];

>     self.scrollView.contentSize = tileLayer.frame.size;

>     [tileLayer setNeedsDisplay];
}
- (void)drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)ctx
{
	// 获取裁剪区域
    CGRect bounds = CGContextGetClipBoundingBox(ctx);
    // 确定坐标
    NSInteger x = floor(bounds.origin.x / layer.tileSize.width);
    NSInteger y = floor(bounds.origin.y / layer.tileSize.height);

>     NSString *imageName = [NSString stringWithFormat: @"Snowman_%02i_%02i", x, y];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
    UIImage *tileImage = [UIImage imageWithContentsOfFile:imagePath];
//使用UIKit进行绘制，因为UIKit只会对当前上下文栈顶的context操作，所以要把形参中的context设置为当前上下文
>     UIGraphicsPushContext(ctx);
> //指定位置和大小绘制图片
    [tileImage drawInRect:bounds];
    UIGraphicsPopContext();
}
@end
>```
>* 实现`-drawLayer:inContext:`方法，当需要载入新的小图时，`CATiledLayer`就会调用到这个方法。
>* **`UIGraphicsPushContext`和`UIGraphicsPopContext`的作用?**
>  * `UIGraphicsPushContext`并不能保存上下文的当前**状态**（画笔颜色、线条宽度等），而是完全切换上下文。
>  * 假设你正在当前视图上下文中绘制什么东西，这时想要在位图上下文中绘制完全不同的东西。如果要使用`UIKit`来进行任意绘图，你会希望保存当前的`UIKit`上下文，包括所有已经绘制的内容，接着切换到一个全新的绘图上下文中。这就是`UIGraphicsPushContext`的功能。创建完位图后，再将你的旧上下文出栈。而这就是`UIGraphicsPopContext`的功能。
>
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170610_1.png)
>
>* `CATiledLayer`载入小图的时候，会淡入效果，可以用`fadeDuration`属性改变淡入时长或直接禁用掉。
>* `-drawLayer:inContext:`方法可以在多个线程中同时地并发调用，所以请小心谨慎地确保你在这个方法中实现的绘制代码是线程安全的。
>
>####<a name="markdown-eight"></a>CAEmitterLayer
>* `CAEmitterLayer`是一个高性能的粒子引擎，被用来创建实时例子动画如：烟雾，火，雨等等这些效果。
>* 简单使用
>
>```swift
>   CAEmitterLayer *snowEmitter = [CAEmitterLayer layer];
  //例子发射位置
  snowEmitter.emitterPosition = CGPointMake(120,20);
  //发射源的尺寸大小
  snowEmitter.emitterSize = CGSizeMake(self.view.bounds.size.width * 20, 20);
  //发射模式
  snowEmitter.emitterMode = kCAEmitterLayerSurface;
  //发射源的形状
  snowEmitter.emitterShape = kCAEmitterLayerLine;
  
>   //创建雪花类型的粒子
  CAEmitterCell *snowflake = [CAEmitterCell emitterCell];
  //粒子的名字
  snowflake.name = @"snow";
  //粒子参数的速度乘数因子
  snowflake.birthRate = 1.0;
  snowflake.lifetime = 120.0;
  //粒子速度
  snowflake.velocity =10.0;
  //粒子的速度范围
  snowflake.velocityRange = 10;
  //粒子y方向的加速度分量
  snowflake.yAcceleration = 2;
  //周围发射角度
  snowflake.emissionRange = 0.5 * M_PI;
  //子旋转角度范围
  snowflake.spinRange = 0.25 * M_PI;
  snowflake.contents = (id)[[UIImage imageNamed:@"DazFlake"] CGImage];
  //设置雪花形状的粒子的颜色
  snowflake.color = [[UIColor colorWithRed:0.200 green:0.258 blue:0.543 alpha:1.000] CGColor];
  
>   //创建星星形状的粒子
  CAEmitterCell *snowflake1 = [CAEmitterCell emitterCell];
  //粒子的名字
  snowflake1.name = @"snow";
  //粒子参数的速度乘数因子
  snowflake1.birthRate = 1.0;
  snowflake1.lifetime = 120.0;
  //粒子速度
  snowflake1.velocity =10.0;
  //粒子的速度范围
  snowflake1.velocityRange = 10;
  //粒子y方向的加速度分量
  snowflake1.yAcceleration = 2;
  //周围发射角度
  snowflake1.emissionRange = 0.5 * M_PI;
  //子旋转角度范围
  snowflake1.spinRange = 0.25 * M_PI;
  //粒子的内容和内容的颜色
  snowflake1.contents = (id)[[UIImage imageNamed:@"DazStarOutline"] CGImage];
  snowflake1.color = [[UIColor colorWithRed:0.600 green:0.658 blue:0.743 alpha:1.000] CGColor];
  
>   snowEmitter.shadowOpacity = 1.0;
  snowEmitter.shadowRadius = 0.0;
  snowEmitter.shadowOffset = CGSizeMake(0.0, 1.0);
  //粒子边缘的颜色
  snowEmitter.shadowColor = [[UIColor redColor] CGColor];
  
>   snowEmitter.emitterCells = [NSArray arrayWithObjects:snowflake,snowflake1,nil];
  [self.view.layer insertSublayer:snowEmitter atIndex:0];
>```
>* `CAEMitterCell`属性介绍
>  * `alphaRange:` 一个粒子的颜色`alpha`能改变的范围；
>  * `alphaSpeed:`粒子透明度在生命周期内的改变速度；
>  * `birthrate：`粒子参数的速度乘数因子；
>  * `blueRange：`一个粒子的颜色能改变的范围；
>  * `blueSpeed: `粒子在生命周期内的改变速度；
>  * `color:`粒子的颜色
>  * `contents：`是个`CGImageRef`的对象,既粒子要展现的图片；
>  * `contentsRect：`应该画在`contents`里的子`rectangle：`
>  * `emissionLatitude：`发射的z轴方向的角度
>  * `emissionLongitude:`x-y平面的发射方向
>  * `emissionRange；`周围发射角度 
>  * `emitterCells：`粒子发射的粒子
>  * `enabled：`粒子是否被渲染
>  * `greenrange: `一个粒子的颜色green 能改变的范围；
>  * `greenSpeed: `粒子green在生命周期内的改变速度；
>  * `lifetime：`生命周期
>  * `lifetimeRange：`生命周期范围
>  * `magnificationFilter：`不是很清楚好像增加自己的大小
>  * `minificatonFilter：`减小自己的大小
>  * `minificationFilterBias：`减小大小的因子
>  * `name：`粒子的名字
>  * `redRange：`一个粒子的颜色red 能改变的范围；
>  * `redSpeed;` 粒子red在生命周期内的改变速度；
>  * `scale：`缩放比例：
>  * `scaleRange：`缩放比例范围；
>  * `scaleSpeed：`缩放比例速度：
>  * `spin：`子旋转角度
>  * `spinrange：`子旋转角度范围
>  * `style：`不是很清楚：
>  * `velocity：`速度
>  * `velocityRange：`速度范围
>  * `xAcceleration:`粒子x方向的加速度分量
>  * `yAcceleration:`粒子y方向的加速度分量
>  * `zAcceleration:`粒子z方向的加速度分量
>* `CAEmitterLayer`属性介绍:   
>
>>  * `birthRate:`粒子产生系数，默认`1.0`；
>>  * `emitterCells:` 装着`CAEmitterCell`对象的数组，被用于把粒子投放到`layer`上；
>>  * `emitterDepth:`决定粒子形状的深度联系：`emittershape`
>>  * `emitterMode:`发射模式
>>    * `NSString * const kCAEmitterLayerPoints;`
>>    * `NSString * const kCAEmitterLayerOutline;`
>>    * `NSString * const kCAEmitterLayerSurface;`
>>    * `NSString * const kCAEmitterLayerVolume;`
>> * `emitterPosition:`发射位置
>> * `emitterShape:`发射源的形状：
>>   * `NSString * const kCAEmitterLayerPoint;`
>>   * `NSString * const kCAEmitterLayerLine;`
>>   * `NSString * const kCAEmitterLayerRectangle;`
>>   * `NSString * const kCAEmitterLayerCuboid;`
>>   * `NSString * const kCAEmitterLayerCircle;`
>>   * `NSString * const kCAEmitterLayerSphere;`
>> * `emitterSize:`发射源的尺寸大；
>> * `emitterZposition:`发射源的z坐标位置；
>> * `lifetime:`粒子生命周期
>> * `preservesDepth:`不是多很清楚（**是否将3D例子系统平面化到一个图层（默认值）或者可以在3D空间中混合其他的图层**）
>> * `renderMode:`渲染模式：(**控制着在视觉上粒子图片是如何混合的。应该是指重叠部分。**)
>>   * `NSString * const kCAEmitterLayerUnordered;`默认
>>   * `NSString * const kCAEmitterLayerOldestFirst;`
>>   * `NSString * const kCAEmitterLayerOldestLast;`
>>   * `NSString * const kCAEmitterLayerBackToFront;`
>>   * `NSString * const kCAEmitterLayerAdditive;`
>> * `scale:`粒子的缩放比例：
>> * `seed：`用于初始化随机数产生的种子
>> * `spin:`自旋转速度
>> * `velocity：`粒子速度
>
>####<a name="markdown-night"></a>（CAEAGLLayer／CAOpenGLLayer）
> * 处理高性能图形绘制
> * `CAEAGLLayer`提供了一个`OpenGLES`渲染环境。各种各样的`OpenGL`绘图缓冲的底层可配置项仍然需要你用`CAEAGLLayer`完成，它是`CALayer`的一个子类，用来显示任意的`OpenGL`图形。`OpenGL`由近350个不同的函数调用组成，用来从简单的图元绘制复杂的三维景象，主要用途是`CAD`、科学可视化程序、虚拟现实、游戏程序设计。
> 
>####<a name="markdown-ten"></a>CAMetalLayer(需要连上真机，才会出现CAMetalLayer文件，至少5S)
> * 是核心动画层使用`Metal`管理的一个`Layer`,
> * `Metal`和`OpenGL ES`相似，它也是一个底层`API`，负责和`3D`绘图硬件交互。它们之间的不同在于，`Metal`不是跨平台的。与之相反的，它设计的在苹果硬件上运行得极其高效，与`OpenGL ES`相比，它提供了更快的速度和更低的开销。
> * 创建新项目时，选择游戏开发，如下图：
> 
> ![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170612_1.png)
> 
>####<a name="markdown-onee"></a>AVPlayerLayer
>* 不是`Core Animation`框架的一部分，由`AVFoundation`提供。
>* 是高级接口例如`MPMoivePlayer`的底层实现，提供了显示视频的底层控制。
>
>```swift
>#import "ViewController.h"
#import  AVFoundation
#import 
@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIView *containerView; 
@end
@implementation ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"Ship" withExtension:@"mp4"];

>     AVPlayer *player = [AVPlayer playerWithURL:URL];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];

>     playerLayer.frame = self.containerView.bounds;
    [self.containerView.layer addSublayer:playerLayer];

>     [player play];
}
@end
>```
>* 把它添加到了一个容器视图中，而不是直接在`controller`中的主视图上添加。这样是为了可以使用自动布局限制使得图层在最中间；否则，一旦设备被旋转了我们就要手动重新放置位置，`Core Animation`并不支持自动大小和自动布局。
>
>* 因为`AVPlayerLayer`是`CALayer`的子类，它继承了父类的所有特性。我们并不会受限于要在一个矩形中播放视频.
>
>```swift
>- (void)viewDidLoad
{
    playerLayer.frame = self.containerView.bounds;
    [self.containerView.layer addSublayer:playerLayer];

>     CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0 / 500.0;
    transform = CATransform3DRotate(transform, M_PI_4, 1, 1, 0);
    playerLayer.transform = transform;
    
>     playerLayer.masksToBounds = YES;
    playerLayer.cornerRadius = 20.0;
    playerLayer.borderColor = [UIColor redColor].CGColor;
    playerLayer.borderWidth = 5.0;

>     [player play];
}
>```
> 
> ####<a name="markdown-twoo"></a>demo
> [[简单demo]LiDechao的demo](https://github.com/LiDechao/LayerAnimation)
> 
> [[开源软件]各种layer的炫酷效果](https://github.com/scotteg/LayerPlayer)

##隐式动画
* 系统自动完成的动画

>#### 事务
>* `Core Animation`基于一个假设：**屏幕上的任何东西都可能做动画。**
>* 当你改变`CALayer`的一个可做动画的属性，它并不能立刻在屏幕上体现出来。相反，它是从先前的值平滑过渡到新的值。这一切都是默认的行为，你不需要做额外的操作，这就是隐式动画。
>* 动画执行的时间取决于当前事务的设置，动画类型取决于图层行为。
>
>>* **事务是**通过`CATransaction`类来做管理，是`Core Animation`用来包含一系列属性动画集合的机制，指定事务去改变可以做动画的图层属性不会立刻发生变化，而是用一个动画过渡到新值。
>* 你可以通过`+setAnimationDuration:`方法设置当前事务的动画时间，或者通过`+animationDuration`方法来获取值（默认`0.25`秒）。
>* `Core Animation`在每个`run loop`周期中自动开始一次新的事务，`run loop`循环中属性的改变都会被集中起来，然后做一次默认`0.25`秒的动画。
>
>####完成块
>* 基于`UIView`的`block`的动画允许你在动画结束的时候提供一个完成的动作。`CATranscation`接口提供的`+setCompletionBlock:`方法也有同样的功能。
>
>```swift
>- (IBAction)changeColor
{
    [CATransaction begin];
    [CATransaction setAnimationDuration:1.0];
    [CATransaction setCompletionBlock:^{
        CGAffineTransform transform = self.colorLayer.affineTransform;
        transform = CGAffineTransformRotate(transform, M_PI_2);
        self.colorLayer.affineTransform = transform;
    }];
    CGFloat red = arc4random() / (CGFloat)INT_MAX;
    CGFloat green = arc4random() / (CGFloat)INT_MAX;
    CGFloat blue = arc4random() / (CGFloat)INT_MAX;
    self.colorLayer.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0].CGColor;
    [CATransaction commit];
}
>```
>* 注意旋转动画要比颜色渐变快得多，因为它是用默认的`0.25`秒做动画。
>
>####图层行为
>* 改变属性时`CALayer`自动应用的动画称作**行为**，当`CALayer`的属性被修改时候，它会调用`-actionForKey:`方法，传递属性的名称。之后如下
>  * 图层首先检测它是否有委托，并且是否实现`CALayerDelegate`协议指定的`-actionForLayer:forKey`方法。如果有，直接调用并返回结果。
>   * 如果没有委托，或者委托没有实现`-actionForLayer:forKey`方法，图层接着检查包含属性名称对应行为映射的`actions`字典。
>   * 如果`actions`字典没有包含对应的属性，那么图层接着在它的`style`字典接着搜索属性名。
>   * 最后，如果在`style`里面也找不到对应的行为，那么图层将会直接调用定义了每个属性的标准行为的`-defaultActionForKey:`方法。
>* 所以`-actionForKey:`要么返回空（这种情况下将不会有动画发生），要么是`CAAction`协议对应的对象，最后`CALayer`拿这个结果去对先前和当前的值做动画。
>* **这就解释了`UIKit`是如何禁用隐式动画的**：每个`UIView`对它关联的图层都扮演了一个委托，并且提供了`-actionForLayer:forKey`的实现方法。当不在一个动画块的实现中，`UIView`对所有图层行为返回`nil`，但是在动画`block`范围之内，它就返回了一个非空值。
>
>```swift
>- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Outside: %@", [self.layerView actionForLayer:self.layerView.layer forKey:@"backgroundColor"]);
    //begin animation 
    [UIView beginAnimations:nil context:nil];
    NSLog(@"Inside: %@", [self.layerView actionForLayer:self.layerView.layer forKey:@"backgroundColor"]);
    //end animation 
    [UIView commitAnimations];
}
// Outside: <null>
// Inside: <CABasicAnimation: 0x757f090>
// 当属性在动画块之外发生改变，UIView直接通过返回nil来禁用隐式动画。
// 但如果在动画块范围之内，根据动画具体类型返回相应的属性，在这个例子就是CABasicAnimation
>```
>* 返回`nil`并不是禁用隐式动画唯一的办法，`CATransacition`有个方法叫做`+setDisableActions:`，可以用来对所有属性打开或者关闭隐式动画。
>* 总结
>  * `UIView`关联的图层禁用了隐式动画，对这种图层做动画的唯一办法就是使用`UIView`的动画函数（而不是依赖`CATransaction`），或者继承`UIView`，并覆盖`-actionForLayer:forKey:`方法，或者直接创建一个显式动画。
>  * 对于单独存在的图层，我们可以通过实现图层的`-actionForLayer:forKey:`委托方法，或者提供一个`actions`字典来控制隐式动画。
> 
>```swift
>- (void)viewDidLoad
{
    [super viewDidLoad];
    self.colorLayer = [CALayer layer];
    self.colorLayer.frame = CGRectMake(50.0f, 50.0f, 100.0f, 100.0f);
    self.colorLayer.backgroundColor = [UIColor blueColor].CGColor;
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    self.colorLayer.actions = @{@"backgroundColor": transition};
    [self.layerView.layer addSublayer:self.colorLayer];
}
>```
>
>####呈现与模型
>* 当你改变一个图层的属性，属性值是立刻更新的（如果你读取它的数据，你会发现它的值在你设置它的那一刻就已经生效了），但是屏幕上并没有马上发生改变。这是因为你设置的属性并没有直接调整图层的外观，相反，他只是定义了图层动画结束之后将要变化的外观。
>* 当设置`CALayer`的属性，实际上是在定义当前事务结束之后图层如何显示的模型。
>* 每个图层属性的显示值都被存储在一个叫做**呈现图层**的独立图层当中，他可以通过`-presentationLayer`方法来访问。这个呈现图层实际上是模型图层的复制，但是它的属性值代表了在任何指定时刻当前外观效果。换句话说，你可以通过呈现图层的值来获取当前屏幕上真正显示出来的值。
>* 在呈现图层上调用`–modelLayer`将会返回它正在呈现所依赖的`CALayer`。通常在一个图层上调用`-modelLayer`会返回`–self`.
>* 两种情况下呈现图层会变得很有用，一个是同步动画，一个是处理用户交互。
>  * 如果你在实现一个基于定时器的动画，而不仅仅是基于事务的动画，这个时候准确地知道在某一时刻图层显示在什么位置就会对正确摆放图层很有用了。
>  * 如果你想让你做动画的图层响应用户输入，你可以使用`-hitTest:`方法来判断指定图层是否被触摸，这时候对呈现图层调用`-hitTest:`会显得更有意义，因为呈现图层代表了用户当前看到的图层位置，而不是当前动画结束之后的位置。
> 
>```swift
>- (void)viewDidLoad
{
    [super viewDidLoad];
    self.colorLayer = [CALayer layer];
    self.colorLayer.frame = CGRectMake(0, 0, 100, 100);
    self.colorLayer.position = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    self.colorLayer.backgroundColor = [UIColor redColor].CGColor;
    [self.view.layer addSublayer:self.colorLayer];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.view];
    if ([self.colorLayer.presentationLayer hitTest:point]) {
        CGFloat red = arc4random() / (CGFloat)INT_MAX;
        CGFloat green = arc4random() / (CGFloat)INT_MAX;
        CGFloat blue = arc4random() / (CGFloat)INT_MAX;
        self.colorLayer.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0].CGColor;
    } else {
        [CATransaction begin];
        [CATransaction setAnimationDuration:4.0];
        self.colorLayer.position = point;
        [CATransaction commit];
    }
}
>```
>####总结
>* 这一章讨论了隐式动画，还有`Core Animation`对指定属性选择合适的动画行为的机制。同时你知道了`UIKit`是如何充分利用`Core Animation`的隐式动画机制来强化它的显式系统，以及动画是如何被默认禁用并且当需要的时候启用的。最后，你了解了呈现和模型图层，以及`Core Animation`是如何通过它们来判断出图层当前位置以及将要到达的位置。

##显式动画
* 能够对一些属性做指定的自定义动画，或者创建非线性动画，比如沿着任意一条曲线移动。

>#####属性动画
>* `CAAnimationDelegate`在任何头文件中都找不到，但是可以在`CAAnimation`头文件或者苹果开发者文档中找到相关函数。
>* 当更新属性的时候，我们需要设置一个新的事务，并且禁用图层行为。否则动画会发生两次，一个是因为显式的`CABasicAnimation`，另一次是因为隐式动画，
>* 在`-animationDidStop:finished:`中
>	* 动画本身会作为一个参数传入委托的方法，也许你会认为可以控制器中把动画存储为一个属性，然后在回调用比较，但实际上并不起作用，因为委托传入的动画参数是原始值的一个深拷贝，从而不是同一个值。
>	* 使用`-addAnimation:forKey:`把动画添加到图层,`key`是对应动画的唯一标识符，
>	* 当前动画的所有键都可以用`animationKeys`获取
>	* `-animationForKey:`方法找到对应动画
>	* 一种更加简单的方法。像所有的`NSObject`子类一样，`CAAnimation`实现了`KVC`（键-值-编码）协议，于是你可以用`-setValue:forKey:`和`-valueForKey:`方法来存取属性。
>
>```swift
>@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *hourHand;
@property (nonatomic, weak) IBOutlet UIImageView *minuteHand;
@property (nonatomic, weak) IBOutlet UIImageView *secondHand;
@property (nonatomic, weak) NSTimer *timer;
@end
@implementation ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    //adjust anchor points
    self.secondHand.layer.anchorPoint = CGPointMake(0.5f, 0.9f);
    self.minuteHand.layer.anchorPoint = CGPointMake(0.5f, 0.9f);
    self.hourHand.layer.anchorPoint = CGPointMake(0.5f, 0.9f);
    //start timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    //set initial hand positions
    [self updateHandsAnimated:NO];
}
- (void)tick
{
    [self updateHandsAnimated:YES];
}
- (void)updateHandsAnimated:(BOOL)animated
{
    //convert time to hours, minutes and seconds
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger units = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *components = [calendar components:units fromDate:[NSDate date]];
    CGFloat hourAngle = (components.hour / 12.0) * M_PI * 2.0;
    //calculate hour hand angle //calculate minute hand angle
    CGFloat minuteAngle = (components.minute / 60.0) * M_PI * 2.0;
    //calculate second hand angle
    CGFloat secondAngle = (components.second / 60.0) * M_PI * 2.0;
    //rotate hands
    [self setAngle:hourAngle forHand:self.hourHand animated:animated];
    [self setAngle:minuteAngle forHand:self.minuteHand animated:animated];
    [self setAngle:secondAngle forHand:self.secondHand animated:animated];
}
- (void)setAngle:(CGFloat)angle forHand:(UIView *)handView animated:(BOOL)animated
{
    //generate transform
    CATransform3D transform = CATransform3DMakeRotation(angle, 0, 0, 1);
    if (animated) {
        //create transform animation
        CABasicAnimation *animation = [CABasicAnimation animation];
        [self updateHandsAnimated:NO];
        animation.keyPath = @"transform";
        animation.toValue = [NSValue valueWithCATransform3D:transform];
        animation.duration = 0.5;
        animation.delegate = self;
        [animation setValue:handView forKey:@"handView"];
        [handView.layer addAnimation:animation forKey:nil];
    } else {
        //set transform directly
        handView.layer.transform = transform;
    }
}
- (void)animationDidStop:(CABasicAnimation *)anim finished:(BOOL)flag
{
    //set final position for hand view
    UIView *handView = [anim valueForKey:@"handView"];
    handView.layer.transform = [anim.toValue CATransform3DValue];
}
>```
>* 该代码在真机上会有执行顺序问题。
>
>#####关键帧动画
>* `CAKeyframeAnimation`:和`CABasicAnimation`类似,同样是`CAPropertyAnimation`的一个子类，依然作用于单一的一个属性，但是和`CABasicAnimation`不一样的是，它不限制于设置一个起始和结束的值，而是可以根据一连串随意的值来做动画。
>* 关键帧起源于传动动画，意思是指主导的动画在显著改变发生时重绘当前帧（也就是关键帧），每帧之间剩下的绘制（可以通过关键帧推算出）将由熟练的艺术家来完成。`CAKeyframeAnimation`也是同样的道理：你提供了显著的帧，然后`Core Animation`在每帧之间进行插入。
>
>```swift
>- (IBAction)changeColor
{
    //create a keyframe animation
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"backgroundColor";
    animation.duration = 2.0;
    animation.values = @[
                         (__bridge id)[UIColor blueColor].CGColor,
                         (__bridge id)[UIColor redColor].CGColor,
                         (__bridge id)[UIColor greenColor].CGColor,
                         (__bridge id)[UIColor blueColor].CGColor ];
    //apply animation to layer
    [self.colorLayer addAnimation:animation forKey:nil];
}
>```
>* 	`rotationMode`的属性。设置它为常量`kCAAnimationRotateAuto`，图层将会根据曲线的切线自动旋转。
>![](/Users/liuzhigao/Desktop/自定义转场动画/Snip20170918_3.png)
>
>#####虚拟属性
>* 之前提到过属性动画实际上是针对于关键路径而不是一个键，这就意味着可以对子属性甚至是虚拟属性做动画。
>* 	`transform.rotation`属性并不存在。
>  * 是因为`CATransform3D`并不是一个对象，它实际上是一个结构体，也没有符合`KVC`相关属性，`transform.rotation`实际上是一个`CALayer`用于处理动画变换的虚拟属性。
> * 当你对他们做动画时，`Core Animation`自动地根据通过`CAValueFunction`来计算的值来更新`transform`属性。
>* `CAValueFunction`用于把我们赋给虚拟的`transform.rotation`简单浮点值转换成真正的用于摆放图层的`CATransform3D`矩阵值。你可以通过设置`CAPropertyAnimation`的`valueFunction`属性来改变，于是你设置的函数将会覆盖默认的函数。
>* `CAValueFunction`的实现细节是私有的，所以目前不能通过继承它来自定义。
>
>####动画组
>* `CAAnimationGroup`可以把这些动画组合在一起。
>
>```swift
>- (void)viewDidLoad
{
    [super viewDidLoad];
    //create a path
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    [bezierPath moveToPoint:CGPointMake(0, 150)];
    [bezierPath addCurveToPoint:CGPointMake(300, 150) controlPoint1:CGPointMake(75, 0) controlPoint2:CGPointMake(225, 300)];
    //draw the path using a CAShapeLayer
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.path = bezierPath.CGPath;
    pathLayer.fillColor = [UIColor clearColor].CGColor;
    pathLayer.strokeColor = [UIColor redColor].CGColor;
    pathLayer.lineWidth = 3.0f;
    [self.containerView.layer addSublayer:pathLayer];
    //add a colored layer
    CALayer *colorLayer = [CALayer layer];
    colorLayer.frame = CGRectMake(0, 0, 64, 64);
    colorLayer.position = CGPointMake(0, 150);
    colorLayer.backgroundColor = [UIColor greenColor].CGColor;
    [self.containerView.layer addSublayer:colorLayer];
    //create the position animation
    CAKeyframeAnimation *animation1 = [CAKeyframeAnimation animation];
    animation1.keyPath = @"position";
    animation1.path = bezierPath.CGPath;
    animation1.rotationMode = kCAAnimationRotateAuto;
    //create the color animation
    CABasicAnimation *animation2 = [CABasicAnimation animation];
    animation2.keyPath = @"backgroundColor";
    animation2.toValue = (__bridge id)[UIColor redColor].CGColor;
    //create group animation
    CAAnimationGroup *groupAnimation = [CAAnimationGroup animation];
    groupAnimation.animations = @[animation1, animation2]; 
    groupAnimation.duration = 4.0;
    //add the animation to the color layer
    [colorLayer addAnimation:groupAnimation forKey:nil];
}
>```
>####过渡
>* 过渡动画首先展示之前的图层外观，然后通过一个交换过渡到新的外观。
>* `CATransition`同样是另一个`CAAnimation`的子类，有一个`type`和`subtype`来标识变换效果。
>
>```swift
>- (void)viewDidLoad
{
    [super viewDidLoad];
    //set up images
    self.images = @[[UIImage imageNamed:@"Anchor.png"],
                    [UIImage imageNamed:@"Cone.png"],
                    [UIImage imageNamed:@"Igloo.png"],
                    [UIImage imageNamed:@"Spaceship.png"]];
}
- (IBAction)switchImage
{
    //set up crossfade transition
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    //apply transition to imageview backing layer
    [self.imageView.layer addAnimation:transition forKey:nil];
    //cycle to next image
    UIImage *currentImage = self.imageView.image;
    NSUInteger index = [self.images indexOfObject:currentImage];
    index = (index + 1) % [self.images count];
    self.imageView.image = self.images[index];
}
>```
>* 和属性动画不同的是，对指定的图层一次只能使用一次`CATransition`.
>
>#####隐式过渡
>* 当设置了`CALayer`的`content`属性的时候，`CATransition`是默认的行为。
>  * 但是对于视图关联的图层，或者是其他隐式动画的行为，这个特性依然是被禁用的，但是对于你自己创建的图层，这意味着对图层`contents`图片做的改动都会自动附上淡入淡出的动画。
>
>#####对图层树的动画
>* `CATransition`并不作用于指定的图层属性，这就是说你可以在即使不能准确得知改变了什么的情况下对图层做动画.
>* 确保`CATransition`添加到的图层在过渡动画发生时不会在树状结构中被移除，否则`CATransition`将会和图层一起被移除。一般来说，你只需要将动画添加到被影响图层的`superlayer`。
>
>```swift
>- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    UIViewController *viewController1 = [[FirstViewController alloc] init];
    UIViewController *viewController2 = [[SecondViewController alloc] init];
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[viewController1, viewController2];
    self.tabBarController.delegate = self;
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    ￼//set up crossfade transition
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    //apply transition to tab bar controller's view
    [self.tabBarController.view.layer addAnimation:transition forKey:nil];
}
>```
>* 把动画添加到`UITabBarController`的视图图层上，于是在标签被替换的时候动画不会被移除。
>
>#####自定义动画