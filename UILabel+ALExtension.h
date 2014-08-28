//
//  UILabel+ALExtension.h
//  ALExtension
//
//  Created by Albert Lee on 8/28/14.
//  Copyright (c) 2014 Albert Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (ALExtension)
- (id)initWithFrame:(CGRect)frame
            bgColor:(UIColor *)bgColor
          textColor:(UIColor *)textColor
               text:(NSString *)text
      textAlignment:(NSTextAlignment)alignment
               font:(UIFont *)font
      numberOfLines:(NSInteger)numberOfLines;
@end
