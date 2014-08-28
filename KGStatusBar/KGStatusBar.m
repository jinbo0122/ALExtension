//
//  KGStatusBar.m
//
//  Created by Kevin Gibbon on 2/27/13.
//  Copyright 2013 Kevin Gibbon. All rights reserved.
//  @kevingibbon
//

#import "KGStatusBar.h"

@interface KGStatusBar ()
@property (nonatomic, strong, readonly) UIWindow *overlayWindow;
@property (nonatomic, strong) UIView *topBar;
@property (nonatomic, strong) UILabel *stringLabel;
@end

@implementation KGStatusBar

@synthesize topBar, overlayWindow, stringLabel;

+ (KGStatusBar*)sharedView {
  static dispatch_once_t once;
  static KGStatusBar *sharedView;
  dispatch_once(&once, ^ { sharedView = [[KGStatusBar alloc] initWithFrame:CGRectMake(0, 0, 320, 20)]; });
  return sharedView;
}

+ (void)showWithStatus:(NSString *)status
               bgColor:(UIColor  *)bgColor
              txtColor:(UIColor  *)txtColor
               txtFont:(UIFont   *)txtFont
                  time:(NSTimeInterval)time{
  [[KGStatusBar sharedView] showWithStatus:status barColor:bgColor textColor:txtColor font:txtFont];
  [KGStatusBar performSelector:@selector(dismiss) withObject:self afterDelay:time];
}

+ (void)dismiss {
  [[KGStatusBar sharedView] dismiss];
}

- (id)initWithFrame:(CGRect)frame {
	
  if ((self = [super initWithFrame:frame])) {
		self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
		self.alpha = 0;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  }
  return self;
}

- (void)showWithStatus:(NSString *)status barColor:(UIColor*)barColor textColor:(UIColor*)textColor font:(UIFont *)font{
  if(!self.superview)
    [self.overlayWindow addSubview:self];
  [self.overlayWindow setHidden:NO];
  [self.topBar setHidden:NO];
  self.topBar.backgroundColor = barColor;
  NSString *labelText = status;
  CGRect labelRect = CGRectZero;
  CGFloat stringWidth = 0;
  CGFloat stringHeight = 0;
  if(labelText) {
    CGSize stringSize = [labelText sizeWithFont:self.stringLabel.font constrainedToSize:CGSizeMake(self.topBar.frame.size.width, self.topBar.frame.size.height)];
    stringWidth = stringSize.width;
    stringHeight = stringSize.height;
    
    labelRect = CGRectMake((self.topBar.frame.size.width / 2) - (stringWidth / 2),
                           (self.topBar.frame.size.height / 2) - (stringHeight / 2), stringWidth, stringHeight);
  }
  self.stringLabel.frame = labelRect;
  self.stringLabel.alpha = 0.0;
  self.stringLabel.hidden = YES;
  self.stringLabel.text = labelText;
  self.stringLabel.textColor = textColor;
  self.stringLabel.font = font;
  self.stringLabel.userInteractionEnabled = YES;
  [UIView animateWithDuration:0.4 animations:^{
    self.stringLabel.alpha = 1.0;
  }];
  [self setNeedsDisplay];
}

- (void) dismiss
{
  [UIView animateWithDuration:0.4 animations:^{
    self.stringLabel.alpha = 0.0;
  } completion:^(BOOL finished) {
    [topBar removeFromSuperview];
    topBar = nil;
    
    [overlayWindow removeFromSuperview];
    overlayWindow = nil;
  }];
}

- (UIWindow *)overlayWindow {
  if(!overlayWindow) {
    overlayWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    overlayWindow.backgroundColor = [UIColor clearColor];
    overlayWindow.userInteractionEnabled = YES;
    overlayWindow.windowLevel = UIWindowLevelStatusBar;
    
    // Transform depending on interafce orientation
    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation([self rotation]);
    self.overlayWindow.transform = rotationTransform;
    self.overlayWindow.bounds = CGRectMake(0.f, 0.f, [self rotatedSize].width, [self rotatedSize].height);
    
    self.tapGesture = [[UITapGestureRecognizer alloc] init];
    [topBar addGestureRecognizer:self.tapGesture];

    // Register for orientation changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRoration:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
  }
  return overlayWindow;
}

- (UIView *)topBar {
  if(!topBar) {
    topBar = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, [self rotatedSize].width, 20.0f)];
    [overlayWindow addSubview:topBar];
  }
  return topBar;
}

- (UILabel *)stringLabel {
  if (stringLabel == nil) {
    stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		stringLabel.textColor = [UIColor colorWithRed:191.0/255.0 green:191.0/255.0 blue:191.0/255.0 alpha:1.0];
		stringLabel.backgroundColor = [UIColor clearColor];
		stringLabel.adjustsFontSizeToFitWidth = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    stringLabel.textAlignment = UITextAlignmentCenter;
#else
    stringLabel.textAlignment = NSTextAlignmentCenter;
#endif
		stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		stringLabel.font = [UIFont boldSystemFontOfSize:10.0];
		stringLabel.shadowColor = [UIColor blackColor];
		stringLabel.shadowOffset = CGSizeMake(0, -1);
    stringLabel.numberOfLines = 0;
    stringLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
  }
  
  if(!stringLabel.superview)
    [self.topBar addSubview:stringLabel];
  
  return stringLabel;
}

#pragma mark - Handle Rotation

- (CGFloat)rotation
{
  UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
  CGFloat rotation = 0.f;
  switch (interfaceOrientation) {
    case UIInterfaceOrientationLandscapeLeft: { rotation = -M_PI_2; } break;
    case UIInterfaceOrientationLandscapeRight: { rotation = M_PI_2; } break;
    case UIInterfaceOrientationPortraitUpsideDown: { rotation = M_PI; } break;
    case UIInterfaceOrientationPortrait: { } break;
    default: break;
  }
  return rotation;
}

- (CGSize)rotatedSize
{
  UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
  CGSize screenSize = [[UIScreen mainScreen] bounds].size;
  CGSize rotatedSize = screenSize;
  switch (interfaceOrientation) {
    case UIInterfaceOrientationLandscapeLeft: { rotatedSize = CGSizeMake(screenSize.height, screenSize.width); } break;
    case UIInterfaceOrientationLandscapeRight: { rotatedSize = CGSizeMake(screenSize.height, screenSize.width); } break;
    case UIInterfaceOrientationPortraitUpsideDown: { } break;
    case UIInterfaceOrientationPortrait: {rotatedSize = CGSizeMake(320, 20);} break;
    default: break;
  }
  return rotatedSize;
}

- (void)handleRoration:(id)sender
{
  // Based on http://stackoverflow.com/questions/8774495/view-on-top-of-everything-uiwindow-subview-vs-uiviewcontroller-subview
  
  CGAffineTransform rotationTransform = CGAffineTransformMakeRotation([self rotation]);
  [UIView animateWithDuration:[[UIApplication sharedApplication] statusBarOrientationAnimationDuration]
                   animations:^{
                     self.overlayWindow.transform = rotationTransform;
                     // Transform invalidates the frame, so use bounds/center
                     self.overlayWindow.bounds = CGRectMake(0.f, 0.f, [self rotatedSize].width, [self rotatedSize].height);
                     self.topBar.frame = CGRectMake(0.f, 0.f, [self rotatedSize].width, 20.f);
                   }];
}

@end
