# ZRFloodFillDemo
 
 本Demo实现涂色App的涂色功能。
 采用泛洪算法计算图片同颜色区域，并填充新颜色。
 泛洪算法通常有3种实现,四邻域，八邻域和基于扫描线。本Demo是采用的基于扫描线的实现方式，相比其他两种来说，基于扫描线的实现绘制速度更快一些。
 了解更多泛洪算法可以查看下列链接：
 
https://en.wikipedia.org/wiki/Flood_fill

https://lodev.org/cgtutor/floodfill.html

使用:
导入头文件UIImage+FloodFill.h
调用- (UIImage *)floodFillImageFromStartPoint: (CGPoint) startPoint newColor: (UIColor *)newColor tolerance: (CGFloat)tolerance useAntialias: (BOOL)antialias;
startPoint： 相对于图片的起点
newColor: 填充的颜色
tolerance: 判断相邻颜色相同的容差值
antialias: 是否抗锯齿化

LinkedListQueue
使用NSMutableData实现的性能更高的队列

效果图：

![image](https://github.com/LZRun/ZRFloodFillDemo/blob/master/ZRFloodFillDemo/效果图/wfm_floodfill_animation_stack.gif)

![image](https://github.com/LZRun/ZRFloodFillDemo/blob/master/ZRFloodFillDemo/效果图/2018-09-13%2015_56_15.gif)
