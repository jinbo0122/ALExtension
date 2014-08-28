//
//
//  UIView+IDPExtension.h
//  IDP
//
//  Created by albert on 13-3-6.
//  Copyright (c) 2012年 Baobao. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface UIView (ALExtension)

//view searching

- (UIView *)viewWithTag:(NSInteger)tag type:(Class)type;
- (UIView *)viewOfType:(Class)type;
- (NSArray *)viewsWithTag:(NSInteger)tag;
- (NSArray *)viewsWithTag:(NSInteger)tag type:(Class)type;
- (NSArray *)viewsOfType:(Class)type;

//frame accessors

@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;

//bounds accessors

@property (nonatomic, assign) CGSize boundsSize;
@property (nonatomic, assign) CGFloat boundsWidth;
@property (nonatomic, assign) CGFloat boundsHeight;

//content getters

@property (nonatomic, readonly) CGRect contentBounds;
@property (nonatomic, readonly) CGPoint contentCenter;


+ (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve;
// Animate removing a view from its parent
- (void)removeWithTransition:(UIViewAnimationTransition)transition duration:(float)duration;

// Animate adding a subview
- (void)addSubview:(UIView *)view withTransition:(UIViewAnimationTransition)transition duration:(float)duration;

// Animate the changing of a views frame
- (void)setFrame:(CGRect)frame duration:(float)duration;

// Animate changing the alpha of a view
- (void)setAlpha:(float)alpha duration:(float)duration;

#pragma mark -
#pragma mark Rounded Corners
//===========================================================

- (void)setCornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;

//===========================================================
#pragma mark -
#pragma mark Shadows
//===========================================================

- (void)setShadowOffset:(CGSize)offset radius:(CGFloat)radius opacity:(CGFloat)opacity;

//===========================================================
#pragma mark -
#pragma mark Gradient Background
//===========================================================

- (void)setGradientBackgroundWithStartColor:(UIColor *)startColor endColor:(UIColor *)endColor;

-(UIImage*)getViewScreenImage;
@end
