//
//  UIImage+FloodFill.m
//  FloodFillDemo
//
//  Created by LZR on 2018/8/31.
//  Copyright © 2018 Run. All rights reserved.
//

#import "UIImage+FloodFill.h"
#import "LinkedListQueue.h"

/// 将RGBA转为NSUInteger
NSUInteger getColorCode(NSUInteger byteIndex, unsigned char *imageData) {
    NSUInteger red = imageData[byteIndex];
    NSUInteger green = imageData[byteIndex + 1];
    NSUInteger blue = imageData[byteIndex + 2];
    NSUInteger alpha = imageData[byteIndex + 3];
    
    return red << 24 | green << 16 | blue << 8 | alpha;
}

/// 对比两种颜色是否在容差内
BOOL compareColor(NSUInteger color1, NSUInteger color2, NSInteger tolerance) {
    if(color1 == color2)
        return true;
    
    NSInteger red1   = ((0xff000000 & color1) >> 24);
    NSInteger green1 = ((0x00ff0000 & color1) >> 16);
    NSInteger blue1  = ((0x0000ff00 & color1) >> 8);
    NSInteger alpha1 =  (0x000000ff & color1);
    
    NSInteger red2   = ((0xff000000 & color2) >> 24);
    NSInteger green2 = ((0x00ff0000 & color2) >> 16);
    NSInteger blue2  = ((0x0000ff00 & color2) >> 8);
    NSInteger alpha2 =  (0x000000ff & color2);
    
    NSInteger diffRed   = labs(red2   - red1);
    NSInteger diffGreen = labs(green2 - green1);
    NSInteger diffBlue  = labs(blue2  - blue1);
    NSInteger diffAlpha = labs(alpha2 - alpha1);
    
    if(diffRed   > tolerance ||
       diffGreen > tolerance ||
       diffBlue  > tolerance ||
       diffAlpha > tolerance)
        return false;
    return true;
}

// 抗锯齿化
void antiAliasOperation(NSUInteger byteIndex, unsigned char *imageData, NSUInteger blendedColor) {
    NSInteger red1   = ((0xff000000 & blendedColor) >> 24);
    NSInteger green1 = ((0x00ff0000 & blendedColor) >> 16);
    NSInteger blue1  = ((0x0000ff00 & blendedColor) >> 8);
    NSInteger alpha1 =  (0x000000ff & blendedColor);
    
    NSInteger red2   = imageData[byteIndex];
    NSInteger green2 = imageData[byteIndex + 1];
    NSInteger blue2  = imageData[byteIndex + 2];
    NSInteger alpha2 = imageData[byteIndex + 3];
    
    imageData[byteIndex] = (red1 + red2) / 2;
    imageData[byteIndex + 1] = (green1 + green2) / 2;
    imageData[byteIndex + 2] = (blue1 + blue2) / 2;
    imageData[byteIndex + 3] = (alpha1 + alpha2) / 2;
}

@implementation UIImage (FloodFill)

- (UIImage *)floodFillImageFromStartPoint: (CGPoint) startPoint newColor: (UIColor *)newColor tolerance: (CGFloat)tolerance useAntialias: (BOOL)antialias {
    if (!self.CGImage || !newColor) return self;
    
    // 将图片转为位图，获取像素信息
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imageRef = self.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    NSUInteger bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    NSUInteger bytesPerPixel = CGImageGetBitsPerPixel(imageRef) / bitsPerComponent;
    NSUInteger bytesPerRow = CGImageGetBytesPerRow(imageRef);

    unsigned char *imageData = malloc(height * bytesPerRow);

    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    if (kCGImageAlphaLast == (uint32_t)bitmapInfo ||
        kCGImageAlphaFirst == (uint32_t)bitmapInfo)
    {
        bitmapInfo = (uint32_t)kCGImageAlphaPremultipliedLast;
    }

    CGContextRef context = CGBitmapContextCreate(imageData,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef); // 解码

    
//    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
//    CFDataRef data = CGDataProviderCopyData(dataProvider); // 解码
//    unsigned char *imageData = (unsigned char *)CFDataGetBytePtr(data);
    
    
    // 获取开始的点
    
    NSUInteger byteIndex = roundf(startPoint.x) * bytesPerPixel + roundf(startPoint.y) * bytesPerRow;
    NSUInteger statrColor = getColorCode(byteIndex, imageData);
    //if (compareColor(statrColor, 0, 0)) return self;

    
    // 将UIColor转为RGBA值
    
    NSUInteger red, green, blue, alpha = 0;
    const CGFloat *components = CGColorGetComponents(newColor.CGColor);
    if (CGColorGetNumberOfComponents(newColor.CGColor) == 2) {
        red = green = blue  = components[0] * 255;
        alpha = components[1] * 255;
    } else {
        red = components[0] * 255;
        green = components[1] * 255;
        blue = components[2] * 255;
        alpha = components[3] * 255;
    }
    NSUInteger nColor = red << 24 | green << 16 | blue << 8 | alpha;
    if (compareColor(statrColor, nColor, 0)) return self;
    
    // 开始点入栈
    
    LinkedListQueue *points = [[LinkedListQueue alloc] initWithCapacity:500 cacheSizeIncrements:500 multiplier:height];
    LinkedListQueue *antialiasPoints = [[LinkedListQueue alloc] initWithCapacity:500 cacheSizeIncrements:500 multiplier:height];
    [points pushWithX:roundf(startPoint.x) y:roundf(startPoint.y)];
    
    // 循环到栈内无节点
    
    NSInteger color;
    BOOL panLeft, panRight;
    NSInteger x, y;
    while ([points popWithX:&x y:&y] != INVALID_NODE_CONTENT) {
        byteIndex = bytesPerPixel * x + bytesPerRow * y;
        color = getColorCode(byteIndex, imageData);
        while (y >= 0 && compareColor(statrColor, color, tolerance)) {
            --y;
            if (y >= 0) {
                byteIndex = bytesPerPixel * x + bytesPerRow * y;
                color = getColorCode(byteIndex, imageData);
            }
        }
        if (y >= 0) {
            [antialiasPoints pushWithX:x y:y];
        }
        
        ++y;
        byteIndex = bytesPerPixel * x + bytesPerRow * y;
        color = getColorCode(byteIndex, imageData);
        panLeft = panRight = false;
        while (y < height && compareColor(statrColor, color, tolerance) && color != nColor) {
            // 颜色替换
            imageData[byteIndex] = red;
            imageData[byteIndex + 1] = green;
            imageData[byteIndex + 2] = blue;
            imageData[byteIndex + 3] = alpha;
            
            if (x > 0) {
                byteIndex = bytesPerPixel * (x - 1) + bytesPerRow * y;
                color = getColorCode(byteIndex, imageData);
                if (!panLeft && compareColor(statrColor, color, tolerance) && color != nColor) { // 左侧点入栈
                    [points pushWithX:x - 1 y:y];
                    panLeft = true;
                } else if (panLeft && !compareColor(statrColor, color, tolerance)) {
                    panLeft = false;
                }
                
                if (!panLeft && !compareColor(statrColor, color, tolerance) && color != nColor) { // 边缘点入栈
                    [antialiasPoints pushWithX:x - 1 y:y];
                }
            }
            
            if (x < width - 1) {
                byteIndex = bytesPerPixel * (x + 1) + bytesPerRow * y;
                color = getColorCode(byteIndex, imageData);
                if (!panRight && compareColor(statrColor, color, tolerance) && color != nColor) { // 右侧点入栈
                    [points pushWithX:x + 1 y:y];
                    panRight = true;
                } else if (panRight && !compareColor(statrColor, color, tolerance)){
                    panRight = false;
                }
                
                if (!panRight && !compareColor(statrColor, color, tolerance) && color != nColor) {
                    [antialiasPoints pushWithX:x + 1 y:y];
                }
            }
            
            ++y;
            if (y < height) {
                byteIndex = bytesPerPixel * x + bytesPerRow * y;
                color = getColorCode(byteIndex, imageData);
            }
        }
    }
    
    void (^block)(NSUInteger, NSUInteger) = ^(NSUInteger pointX, NSUInteger pointY) {
        NSUInteger byteIndex = bytesPerPixel * x + bytesPerRow * y;
        NSUInteger color = getColorCode(byteIndex, imageData);
        if (color != nColor) {
            antiAliasOperation(byteIndex, imageData, nColor);
        }
    };
    
    if (antialias) { // 抗锯齿化
        while ([antialiasPoints popWithX:&x y:&y] != INVALID_NODE_CONTENT) {
            NSUInteger byteIndex = bytesPerPixel * x + bytesPerRow * y;
            antiAliasOperation(byteIndex, imageData, nColor);
            if (x > 0) block(x-1, y);
            if (x < width-1) block(x+1, y);
            if (y > 0) block(x, y-1);
            if (y < height-1) block(x, y+1);
        }
    }
    
    // 将位图转为UIImage
    
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    //    colorSpace = CGColorSpaceCreateDeviceRGB()
    //    CGDataProviderRef newDataProvider = CGDataProviderCreateWithData(NULL, imageData, CFDataGetLength(data), NULL);
    //    CGImageRef newImage = CGImageCreate(width, height, CGImageGetBitsPerComponent(self.CGImage), CGImageGetBitsPerPixel(self.CGImage), bytesPerRow, colorSpace, CGImageGetBitmapInfo(self.CGImage), newDataProvider, NULL, false, kCGRenderingIntentDefault);
    //    CGColorSpaceRelease(colorSpace);
    //    CGDataProviderRelease(newDataProvider);
    
    UIImage *nImage = [UIImage imageWithCGImage:newImage];
    CGImageRelease(newImage);
    return nImage;
}

@end


