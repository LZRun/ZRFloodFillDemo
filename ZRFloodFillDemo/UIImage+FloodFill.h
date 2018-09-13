//
//  UIImage+FloodFill.h
//  FloodFillDemo
//
//  Created by LZR on 2018/8/31.
//  Copyright © 2018 Run. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FloodFill)

- (UIImage *)floodFillImageFromStartPoint: (CGPoint) startPoint newColor: (UIColor *)newColor tolerance: (CGFloat)tolerance useAntialias: (BOOL)antialias;

@end
