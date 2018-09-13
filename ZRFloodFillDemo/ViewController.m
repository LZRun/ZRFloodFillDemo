//
//  ViewController.m
//  FloodFillDemo
//
//  Created by LZR on 2018/8/21.
//  Copyright © 2018 Run. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+FloodFill.h"

@interface ViewController () {
    UIView *indicatorView;
    NSInteger imageIndex;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageRatioConstraint;
@property (nonatomic, strong) UIColor *color;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.color = [UIColor redColor];
    
    indicatorView = [[UIView alloc] init];
    indicatorView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:indicatorView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (CGRectEqualToRect(indicatorView.frame, CGRectZero)) {
        indicatorView.frame = CGRectMake(0, self.view.frame.size.height -  self.view.safeAreaInsets.bottom - 5, self.view.frame.size.width / 6, 1);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:_imageView];
    if (![_imageView pointInside:point withEvent:event]) {
        NSLog(@"点远了");
        return;
    }
    
    point.x = roundf(_imageView.image.size.width / _imageView.bounds.size.width * point.x);
    point.y = roundf(_imageView.image.size.height / _imageView.bounds.size.height * point.y);
    [self covertImageToBitmapWithPoint:point];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeColorAction:(UIButton *)sender {
    self.color = sender.backgroundColor;
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = indicatorView.frame;
        frame.origin.x = sender.frame.origin.x;
        indicatorView.frame = frame;
    }];
}
- (IBAction)changeImageAction {
    NSArray *imageNames = @[@"8BDD22B45708C65C3C240B88F3042EBD", @"star", @"1", @"2.jpg"];
    ++imageIndex;
    imageIndex %= imageNames.count;
    _imageView.image = [UIImage imageNamed:imageNames[imageIndex]];
    _imageRatioConstraint.constant = _imageView.image.size.height / _imageView.image.size.width;
}

- (void)covertImageToBitmapWithPoint: (CGPoint)point {
    UIImage *oldImage = _imageView.image;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       UIImage *image = [oldImage floodFillImageFromStartPoint:point newColor:_color tolerance:10 useAntialias:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            _imageView.image = image;
        });
    });
}

@end
