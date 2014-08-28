//
//  UILabel+ALExtension.m
//  ALExtension
//
//  Created by Albert Lee on 8/28/14.
//  Copyright (c) 2014 Albert Lee. All rights reserved.
//

#import "UILabel+ALExtension.h"

@implementation UILabel (ALExtension)
+ (UILabel *)initWithFrame:(CGRect)frame
                   bgColor:(UIColor *)bgColor
                 textColor:(UIColor *)textColor
                      text:(NSString *)text
             textAlignment:(NSTextAlignment)alignment
                      font:(UIFont *)font
             numberOfLines:(NSInteger)numberOfLines{
  UILabel *label = [[UILabel alloc] initWithFrame:frame];
  if (label) {
    label.backgroundColor = bgColor;
    label.text = text;
    label.textColor = textColor;
    label.textAlignment = alignment;
    label.font = font;
    label.numberOfLines = numberOfLines;
  }
  return label;
}
@end
