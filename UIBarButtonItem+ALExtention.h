//
//  ALExtention.h
//  ALExtension
//
//  Created by Albert Lee on 10/31/14.
//  Copyright (c) 2014 Albert Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem(ALExtension)
+ (UIBarButtonItem*)loadBarButtonItemWithTitle:(NSString*)title color:(UIColor*)textColor
                                          font:(UIFont*)font target:(id)target action:(SEL)action;
+ (UIBarButtonItem*)loadBarButtonItemWithImage:(NSString*)imageName rect:(CGRect)rect arget:(id)target action:(SEL)action;
+ (UIBarButtonItem*)loadLeftBarButtonItemWithTitle:(NSString*)title color:(UIColor*)textColor
                                              font:(UIFont*)font target:(id)target action:(SEL)action;
+ (UIBarButtonItem*)loadBarButtonItemWithShortImage:(NSString*)imageName rect:(CGRect)rect arget:(id)target action:(SEL)action;
+ (UIBarButtonItem*)loadRightBarButtonItemWithImage:(NSString*)imageName
                                               rect:(CGRect)rect target:(id)target action:(SEL)action;
+ (UIBarButtonItem*)loadBarButtonItemWithImage:(NSString*)imageName rect:(CGRect)rect
                                          text:(NSString*)text textColor:(UIColor *)textColor
                                        target:(id)target action:(SEL)action;
@end
