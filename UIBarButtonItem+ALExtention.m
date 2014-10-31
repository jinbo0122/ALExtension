//
//  ALExtention.m
//  ALExtension
//
//  Created by Albert Lee on 10/31/14.
//  Copyright (c) 2014 Albert Lee. All rights reserved.
//

#import "UIBarButtonItem+ALExtention.h"

@implementation UIBarButtonItem(ALExtension)
+ (UIBarButtonItem*)loadBarButtonItemWithTitle:(NSString*)title
                                         color:(UIColor*)textColor
                                          font:(UIFont*)font
                                        target:(id)target
                                        action:(SEL)action{
  UIBarButtonItem *bbtn;
  UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(isRunningOnIOS7?10:5, 0, 60, 40)];
  lblTitle.backgroundColor = [UIColor clearColor];
  lblTitle.text = title;
  lblTitle.textColor = textColor;
  lblTitle.textAlignment = NSTextAlignmentRight;
  lblTitle.font = font;
  UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 70, 40) ];
  [view addSubview:lblTitle];
  
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
  tapGesture.numberOfTouchesRequired = 1;
  [view addGestureRecognizer:tapGesture];
  
  bbtn = [[UIBarButtonItem alloc] initWithCustomView:view];
  return bbtn;
}

+ (UIBarButtonItem*)loadLeftBarButtonItemWithTitle:(NSString*)title color:(UIColor*)textColor
                                              font:(UIFont*)font target:(id)target action:(SEL)action{
  UIBarButtonItem *bbtn;
  UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(isRunningOnIOS7?0:5, 1, 50, 40)];
  lblTitle.backgroundColor = [UIColor clearColor];
  lblTitle.text = title;
  lblTitle.textColor = textColor;
  lblTitle.textAlignment = NSTextAlignmentLeft;
  lblTitle.font = font;
  
  UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50, 40) ];
  [view addSubview:lblTitle];
  
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
  tapGesture.numberOfTouchesRequired = 1;
  [view addGestureRecognizer:tapGesture];
  
  bbtn = [[UIBarButtonItem alloc] initWithCustomView:view];
  return bbtn;
}

+ (UIBarButtonItem*)loadBarButtonItemWithImage:(NSString*)imageName rect:(CGRect)rect arget:(id)target action:(SEL)action{
  UIBarButtonItem *bbtn;
  
  UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
  UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamedNoCache:imageName]];
  imageView.frame = rect;
  [view addSubview:imageView];
  
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
  tapGesture.numberOfTouchesRequired = 1;
  [view addGestureRecognizer:tapGesture];
  
  bbtn = [[UIBarButtonItem alloc] initWithCustomView:view];
  return bbtn;
}

+ (UIBarButtonItem*)loadBarButtonItemWithImage:(NSString*)imageName
                                          rect:(CGRect)rect
                                          text:(NSString*)text
                                     textColor:(UIColor *)textColor
                                        target:(id)target
                                        action:(SEL)action{
  UIBarButtonItem *bbtn;
  
  UIButton *loadButton = [[UIButton alloc] initWithFrame:rect];
  UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamedNoCache:imageName] stretchableImageWithLeftCapWidth:5 topCapHeight:0]];
  imageView.frame =loadButton.bounds;
  [loadButton addSubview:imageView];
  
  [imageView addSubview:[UILabel initWithFrame:imageView.bounds
                                       bgColor:[UIColor clearColor]
                                     textColor:textColor
                                          text:text
                                 textAlignment:NSTextAlignmentCenter
                                          font:[UIFont systemFontOfSize:14]
                                 numberOfLines:0]];
  [loadButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
  bbtn = [[UIBarButtonItem alloc] initWithCustomView:loadButton];
  return bbtn;
}

+ (UIBarButtonItem*)loadBarButtonItemWithShortImage:(NSString*)imageName rect:(CGRect)rect arget:(id)target action:(SEL)action{
  UIBarButtonItem *bbtn;
  
  UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
  UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamedNoCache:imageName]];
  imageView.frame = rect;
  [view addSubview:imageView];
  imageView.contentMode = UIViewContentModeRight;
  
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
  tapGesture.numberOfTouchesRequired = 1;
  [view addGestureRecognizer:tapGesture];
  
  bbtn = [[UIBarButtonItem alloc] initWithCustomView:view];
  return bbtn;
}

+ (UIBarButtonItem*)loadRightBarButtonItemWithImage:(NSString*)imageName rect:(CGRect)rect target:(id)target action:(SEL)action{
  UIBarButtonItem *bbtn;
  
  UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
  UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamedNoCache:imageName]];
  imageView.frame = rect;
  [view addSubview:imageView];
  
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
  tapGesture.numberOfTouchesRequired = 1;
  [view addGestureRecognizer:tapGesture];
  view.userInteractionEnabled = YES;
  
  bbtn = [[UIBarButtonItem alloc] initWithCustomView:view];
  return bbtn;
}
@end
