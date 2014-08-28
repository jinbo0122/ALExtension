//
//  KGStatusBar.h
//
//  Created by Kevin Gibbon on 2/27/13.
//  Copyright 2013 Kevin Gibbon. All rights reserved.
//  @kevingibbon
//

#import <UIKit/UIKit.h>

@interface KGStatusBar : UIView
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
+ (KGStatusBar*)sharedView;
+ (void)showWithStatus:(NSString *)status
               bgColor:(UIColor  *)bgColor
              txtColor:(UIColor  *)txtColor
               txtFont:(UIFont   *)txtFont
                  time:(NSTimeInterval)time;
+ (void)dismiss;
@end
