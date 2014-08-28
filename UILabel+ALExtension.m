//
//  UILabel+ALExtension.m
//  ALExtension
//
//  Created by Albert Lee on 8/28/14.
//  Copyright (c) 2014 Albert Lee. All rights reserved.
//

#import "UILabel+ALExtension.h"

@implementation UILabel (ALExtension)
- (id)initWithFrame:(CGRect)frame
            bgColor:(UIColor *)bgColor
          textColor:(UIColor *)textColor
               text:(NSString *)text
      textAlignment:(NSTextAlignment)alignment
               font:(UIFont *)font
      numberOfLines:(NSInteger)numberOfLines{
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = bgColor;
    self.text = text;
    self.textColor = textColor;
    self.textAlignment = alignment;
    self.font = font;
    self.numberOfLines = numberOfLines;
  }
  return self;
}
@end
