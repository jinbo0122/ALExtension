//
//  UIImage+Category.h
//  pandora
//
//  Created by Albert Lee on 1/10/14.
//  Copyright (c) 2014 Albert Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
@interface UIImage (ALExtension)
- (UIImage *)applyLightEffectWithBlur:(NSInteger)blur;
- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;
+ (UIImage *)imageWithView:(UIView *)view;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageWithColor:(UIColor *)color;
- (CGFloat  )imageLuminosity;
+ (CGFloat  )imageLuminosityWithColor:(UIColor *)color;
- (NSNumber*)imageAverageColor;
+ (UIColor *)colorFromARGB:(NSNumber *)number;
+ (UIImage*)thumbImage:(NSData*)imageData;
+ (UIImage*)imageNamedNoCache:(NSString *)name;
@end
