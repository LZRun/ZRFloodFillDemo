//
//  UIImage+FloodFill.h
//  FloodFillDemo
//
//  Created by LZR on 2018/8/31.
//  Copyright © 2018 Run. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FloodFill)


/**
 基于扫描线的泛洪算法，获取填充同颜色区域后的图片

 @param startPoint 相对于图片的起点
 @param newColor 填充的颜色
 @param tolerance 判断相邻颜色相同的容差值
 @param antialias 是否抗锯齿化
 @return 填充后的图片
 */
- (UIImage *)floodFillImageFromStartPoint: (CGPoint) startPoint newColor: (UIColor *)newColor tolerance: (CGFloat)tolerance useAntialias: (BOOL)antialias;

@end
