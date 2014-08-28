//
//  UIImage+Category.m
//  pandora
//
//  Created by Albert Lee on 1/10/14.
//  Copyright (c) 2014 Albert Lee. All rights reserved.
//

#import "UIImage+ALExtension.h"
#import <Accelerate/Accelerate.h>
#import <float.h>
@implementation UIImage (ALExtension)
- (UIImage *)applyLightEffectWithBlur:(NSInteger)blur
{
  UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
  return [self applyBlurWithRadius:blur tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
{
  // Check pre-conditions.
  if (self.size.width < 1 || self.size.height < 1) {
    DDLogVerbose(@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
    return nil;
  }
  if (!self.CGImage) {
    DDLogVerbose (@"*** error: image must be backed by a CGImage: %@", self);
    return nil;
  }
  if (maskImage && !maskImage.CGImage) {
    DDLogVerbose (@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
    return nil;
  }
  
  CGRect imageRect = { CGPointZero, self.size };
  UIImage *effectImage = self;
  
  BOOL hasBlur = blurRadius > __FLT_EPSILON__;
  BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
  if (hasBlur || hasSaturationChange) {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef effectInContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(effectInContext, 1.0, -1.0);
    CGContextTranslateCTM(effectInContext, 0, -self.size.height);
    CGContextDrawImage(effectInContext, imageRect, self.CGImage);
    
    vImage_Buffer effectInBuffer;
    effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
    effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
    effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
    effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
    vImage_Buffer effectOutBuffer;
    effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
    effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
    effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
    effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
    
    if (hasBlur) {
      CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
      unsigned int radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
      if (radius % 2 != 1) {
        radius += 1; // force radius to be odd so that the three box-blur methodology works.
      }
      vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
      vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
      vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
    }
    BOOL effectImageBuffersAreSwapped = NO;
    if (hasSaturationChange) {
      CGFloat s = saturationDeltaFactor;
      CGFloat floatingPointSaturationMatrix[] = {
        0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
        0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
        0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
        0,                    0,                    0,  1,
      };
      const int32_t divisor = 256;
      NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
      int16_t saturationMatrix[matrixSize];
      for (NSUInteger i = 0; i < matrixSize; ++i) {
        saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
      }
      if (hasBlur) {
        vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
        effectImageBuffersAreSwapped = YES;
      }
      else {
        vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
      }
    }
    if (!effectImageBuffersAreSwapped)
      effectImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (effectImageBuffersAreSwapped)
      effectImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
  }
  
  // Set up output context.
  UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
  CGContextRef outputContext = UIGraphicsGetCurrentContext();
  CGContextScaleCTM(outputContext, 1.0, -1.0);
  CGContextTranslateCTM(outputContext, 0, -self.size.height);
  
  // Draw base image.
  CGContextDrawImage(outputContext, imageRect, self.CGImage);
  
  // Draw effect image.
  if (hasBlur) {
    CGContextSaveGState(outputContext);
    if (maskImage) {
      CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
    }
    CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
    CGContextRestoreGState(outputContext);
  }
  
  // Add in color tint.
  if (tintColor) {
    CGContextSaveGState(outputContext);
    CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
    CGContextFillRect(outputContext, imageRect);
    CGContextRestoreGState(outputContext);
  }
  
  // Output image is ready.
  UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return outputImage;
}

+ (UIImage *) imageWithView:(UIView *)view
{
  UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
  [view setOpaque:NO];
  [[view layer] setOpaque:NO];
  [view setBackgroundColor:[UIColor clearColor]];
  [[view layer] setBackgroundColor:[UIColor clearColor].CGColor];
  
  [view.layer renderInContext:UIGraphicsGetCurrentContext()];
  
  UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
  
  UIGraphicsEndImageContext();
  
  return img;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
  UIGraphicsBeginImageContext(size);
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGContextSetFillColorWithColor(context, color.CGColor);
  CGContextFillRect(context, (CGRect){.size = size});
  
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
  return [UIImage imageWithColor:color size:CGSizeMake(1, 1)];
}

- (CGFloat  )imageLuminosity{
  CGImageRef cgimage = self.CGImage;
  
  size_t width  = CGImageGetWidth(cgimage);
  size_t height = CGImageGetHeight(cgimage);
  
  size_t bpr = CGImageGetBytesPerRow(cgimage);
  size_t bpp = CGImageGetBitsPerPixel(cgimage);
  size_t bpc = CGImageGetBitsPerComponent(cgimage);
  size_t bytes_per_pixel = bpp / bpc;
  
  CGDataProviderRef provider = CGImageGetDataProvider(cgimage);
  NSData* data = (id)CFBridgingRelease(CGDataProviderCopyData(provider));
  
  double totalLuminance = 0.0;
  const uint8_t* bytes = [data bytes];
  for(size_t row = 0; row < height; row++){
    for(size_t col = 0; col < width; col++){
      const uint8_t* pixel =
      &bytes[row * bpr + col * bytes_per_pixel];
      for(size_t x = 0; x < bytes_per_pixel; x++){
        totalLuminance+=pixel[x]*(x==0?0.299:((x==1)?0.587:0.114));
      }
    }
  }
  totalLuminance /= height*width;
  totalLuminance /= 255.0;
  DDLogVerbose(@"Searched image luminance = %f",totalLuminance);
  
  return totalLuminance;
}

+ (CGFloat  )imageLuminosityWithColor:(UIColor *)color{
  CGImageRef cgimage = [UIImage imageWithColor:color size:CGSizeMake(5, 5)].CGImage;
  
  size_t width  = CGImageGetWidth(cgimage);
  size_t height = CGImageGetHeight(cgimage);
  
  size_t bpr = CGImageGetBytesPerRow(cgimage);
  size_t bpp = CGImageGetBitsPerPixel(cgimage);
  size_t bpc = CGImageGetBitsPerComponent(cgimage);
  size_t bytes_per_pixel = bpp / bpc;
  
  CGDataProviderRef provider = CGImageGetDataProvider(cgimage);
  NSData* data = (id)CFBridgingRelease(CGDataProviderCopyData(provider));
  
  double totalLuminance = 0.0;
  const uint8_t* bytes = [data bytes];
  for(size_t row = 0; row < height; row++){
    for(size_t col = 0; col < width; col++){
      const uint8_t* pixel =
      &bytes[row * bpr + col * bytes_per_pixel];
      for(size_t x = 0; x < bytes_per_pixel; x++){
        totalLuminance+=pixel[x]*(x==0?0.299:((x==1)?0.587:0.114));
      }
    }
  }
  totalLuminance /= height*width;
  totalLuminance /= 255.0;
  DDLogVerbose(@"Searched image luminance = %f",totalLuminance);
  
  return totalLuminance;
}


- (NSNumber *)imageAverageColor{
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  unsigned char rgba[4];
  CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
  
  CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
  CGColorSpaceRelease(colorSpace);
  CGContextRelease(context);
  long long alpha,red,green,blue;
  if(rgba[3] > 0) {
    alpha = ((NSInteger)rgba[3]);
    red = ((NSInteger)rgba[0])*alpha/255.0;
    green = ((NSInteger)rgba[1])*alpha/255.0;
    blue = ((NSInteger)rgba[2])*alpha/255.0;
  }
  else {
    alpha = ((NSInteger)rgba[3]);
    red = ((NSInteger)rgba[0]);
    green = ((NSInteger)rgba[1]);
    blue = ((NSInteger)rgba[2]);
  }
  return [NSNumber numberWithLongLong:(alpha<<24) + (red<<16) + (green << 8) + blue];
//  if(rgba[3] > 0) {
//    CGFloat alpha = ((CGFloat)rgba[3])/255.0;
//    CGFloat multiplier = alpha/255.0;
//    return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
//                           green:((CGFloat)rgba[1])*multiplier
//                            blue:((CGFloat)rgba[2])*multiplier
//                           alpha:alpha];
//  }
//  else {
//    return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
//                           green:((CGFloat)rgba[1])/255.0
//                            blue:((CGFloat)rgba[2])/255.0
//                           alpha:((CGFloat)rgba[3])/255.0];
//  }
}

+ (UIColor *)colorFromARGB:(NSNumber *)number{
  long long argb = [number longLongValue];
  long long blue = argb & 0xff;
  long long green = argb >> 8 & 0xff;
  long long red = argb >> 16 & 0xff;
  long long alpha = argb >> 24 & 0xff;
  
  return [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:alpha/255.f];
}

+ (UIImage*)thumbImage:(NSData*)imageData{
  UIImage* img = [UIImage imageWithData:imageData];
  CGSize size = CGSizeMake(img.size.width/10, img.size.height/10);
  UIGraphicsBeginImageContextWithOptions(size, NO, 0);
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextTranslateCTM(context, 0, size.height);
  CGContextScaleCTM(context, 1, -1);
  CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), [img CGImage]);
  UIImage* img2 = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return img2;
}

+ (UIImage*)imageNamedNoCache:(NSString *)name{
  if (!name) {
    return nil;
  }
  NSInteger scale = 1;
  NSString* finalName = [NSString stringWithString:name];
  if([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES)
  {
    scale = [[UIScreen mainScreen] scale];
  }
  if (scale>1) {
    finalName = [NSString stringWithFormat:@"%@@%dx",name,(int)scale];
  }

  //retina 寻找文件
  NSString *filePath = [[NSBundle mainBundle] pathForResource:finalName ofType:@"png"];
  if (!filePath) {
    filePath = [[NSBundle mainBundle] pathForResource:finalName ofType:@"jpg"];
  }
  //如果没有 那寻找正常文件
  if (!filePath) {
    filePath = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
    if (!filePath) {
      filePath = [[NSBundle mainBundle] pathForResource:name ofType:@"jpg"];
    }
  }
  return [UIImage imageWithContentsOfFile:filePath];
}
@end
