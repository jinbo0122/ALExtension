//
//  ALEmojiKeyboardView.h
//  ALEmojiKeyboard
//
//  Created by Albert Li on 08/25/14.
//  Copyright (c) 2013 Ayush. All rights reserved.
//
// Set as inputView to textfields, this view class gives an
// interface to the user to enter emoji characters.

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ALEmojiKeyboardViewCategoryImage) {
  ALEmojiKeyboardViewCategoryImageRecent,
  ALEmojiKeyboardViewCategoryImageFace,
  ALEmojiKeyboardViewCategoryImageEmoBB,
};

@protocol ALEmojiKeyboardViewDelegate;
@protocol ALEmojiKeyboardViewDataSource;

/**
 Keyboard class to present as an alternate.
 This keyboard presents the emojis supported by iOS.
 */
@interface ALEmojiKeyboardView : UIView


@property (nonatomic, weak) id<ALEmojiKeyboardViewDelegate> delegate;
@property (nonatomic, weak) id<ALEmojiKeyboardViewDataSource> dataSource;
@property (nonatomic, strong) UIButton *btnSend;
/**
 @param frame Frame of the view to be initialised with.

 @param dataSource dataSource is required during the initialization to
 get all the relevent images to present in the view.
 */
- (instancetype)initWithFrame:(CGRect)frame
                   dataSource:(id<ALEmojiKeyboardViewDataSource>)dataSource
                   categories:(NSArray*)categories;

@end


/**
 Protocol to be followed by the dataSource of `ALEmojiKeyboardView`.
 */
@protocol ALEmojiKeyboardViewDataSource <NSObject>

/**
 Method called on dataSource to get the category image when selected.

 @param emojiKeyBoardView EmojiKeyBoardView object on which user has tapped.

 @param category category to get the image for. @see ALEmojiKeyboardViewCategoryImage
 */
- (UIImage *)emojiKeyboardView:(ALEmojiKeyboardView *)emojiKeyboardView
      imageForSelectedCategory:(ALEmojiKeyboardViewCategoryImage)category;

/**
 Method called on dataSource to get the category image when not-selected.

 @param emojiKeyBoardView EmojiKeyBoardView object on which user has tapped.

 @param category category to get the image for. @see ALEmojiKeyboardViewCategoryImage
 */
- (UIImage *)emojiKeyboardView:(ALEmojiKeyboardView *)emojiKeyboardView
   imageForNonSelectedCategory:(ALEmojiKeyboardViewCategoryImage)category;

/**
 Method called on dataSource to get the back button image to be shown in the view.

 @param emojiKeyBoardView EmojiKeyBoardView object on which user has tapped.
 */
- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(ALEmojiKeyboardView *)emojiKeyboardView;

@optional

/**
 Method called on dataSource to get category that should be shown by
 default i.e. when the keyboard is just presented.

 @note By default `ALEmojiKeyboardViewCategoryImageRecent` is shown.

 @param emojiKeyBoardView EmojiKeyBoardView object shown.
 */
- (ALEmojiKeyboardViewCategoryImage)defaultCategoryForEmojiKeyboardView:(ALEmojiKeyboardView *)emojiKeyboardView;

/**
 Method called on dataSource to get number of emojis to be maintained in
 recent category.

 @note By default `50` is used.

 @param emojiKeyBoardView EmojiKeyBoardView object shown.
 */
- (NSUInteger)recentEmojisMaintainedCountForEmojiKeyboardView:(ALEmojiKeyboardView *)emojiKeyboardView;

@end


/**
 Protocol to be followed by the delegate of `ALEmojiKeyboardView`.
 */
@protocol ALEmojiKeyboardViewDelegate <NSObject>

/**
 Delegate method called when user taps an emoji button

 @param emojiKeyBoardView EmojiKeyBoardView object on which user has tapped.

 @param emoji Emoji used by user
 */
- (void)emojiKeyBoardView:(ALEmojiKeyboardView *)emojiKeyBoardView
              didUseEmoji:(NSString *)emoji;

/**
 Delegate method called when user taps on the backspace button

 @param emojiKeyBoardView EmojiKeyBoardView object on which user has tapped.
 */
- (void)emojiKeyBoardViewDidPressBackSpace:(ALEmojiKeyboardView *)emojiKeyBoardView;

@end
