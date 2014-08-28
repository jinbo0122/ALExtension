//
//  ALEmojiKeyboardView.m
//  AGEmojiKeyboard
//
//  Created by Ayush on 09/05/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//

#import "ALEmojiKeyBoardView.h"
#import "ALEmojiPageView.h"

static const CGFloat ButtonWidth = 45;
static const CGFloat ButtonHeight = 40;

static const NSUInteger DefaultRecentEmojisMaintainedCount = 50;

static NSString *const segmentRecentName = @"Recent";
NSString *const RecentALUsedEmojiCharactersKey = @"RecentALUsedEmojiCharactersKey";


@interface ALEmojiKeyboardView () <UIScrollViewDelegate, ALEmojiPageViewDelegate>

@property (nonatomic) UISegmentedControl *segmentsBar;
@property (nonatomic) UIPageControl *pageControl;
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) NSDictionary *emojis;
@property (nonatomic) NSMutableArray *pageViews;
@property (nonatomic) NSString *category;
@property (nonatomic) UIView *bgBarView;
@property (nonatomic) NSArray *categories;
@end

@implementation ALEmojiKeyboardView

- (NSDictionary *)emojis {
  if (!_emojis) {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"EmojisList"
                                                          ofType:@"plist"];
    _emojis = [[NSDictionary dictionaryWithContentsOfFile:plistPath] copy];
  }
  return _emojis;
}

- (NSString *)categoryNameAtIndex:(NSUInteger)index customCategory:(NSArray *)categories{
  NSMutableArray *categoryList = [@[segmentRecentName] mutableCopy];
  [categoryList addObjectsFromArray:categories];
  return categoryList[index];
}

- (ALEmojiKeyboardViewCategoryImage)defaultSelectedCategory {
  if ([self.dataSource respondsToSelector:@selector(defaultCategoryForEmojiKeyboardView:)]) {
    return [self.dataSource defaultCategoryForEmojiKeyboardView:self];
  }
  return ALEmojiKeyboardViewCategoryImageRecent;
}

- (NSUInteger)recentEmojisMaintainedCount {
  if ([self.dataSource respondsToSelector:@selector(recentEmojisMaintainedCountForEmojiKeyboardView:)]) {
    return [self.dataSource recentEmojisMaintainedCountForEmojiKeyboardView:self];
  }
  return DefaultRecentEmojisMaintainedCount;
}

- (NSArray *)imagesForSelectedSegments {
  static NSMutableArray *array;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    array = [NSMutableArray array];
    for (ALEmojiKeyboardViewCategoryImage i = ALEmojiKeyboardViewCategoryImageRecent;
         i <= ALEmojiKeyboardViewCategoryImageEmoBB;
         ++i) {
      [array addObject:[self.dataSource emojiKeyboardView:self imageForSelectedCategory:i]];
    }
  });
  return array;
}

- (NSArray *)imagesForNonSelectedSegments {
  static NSMutableArray *array;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    array = [NSMutableArray array];
    for (ALEmojiKeyboardViewCategoryImage i = ALEmojiKeyboardViewCategoryImageRecent;
         i <= ALEmojiKeyboardViewCategoryImageEmoBB;
         ++i) {
      [array addObject:[self.dataSource emojiKeyboardView:self imageForNonSelectedCategory:i]];
    }
  });
  return array;
}

// recent emojis are backed in NSUserDefaults to save them across app restarts.
- (NSMutableArray *)recentEmojis {
  NSArray *emojis = [[NSUserDefaults standardUserDefaults] arrayForKey:RecentALUsedEmojiCharactersKey];
  NSMutableArray *recentEmojis = [emojis mutableCopy];
  if (recentEmojis == nil) {
    recentEmojis = [NSMutableArray array];
  }
  return recentEmojis;
}

- (void)setRecentEmojis:(NSMutableArray *)recentEmojis {
  // remove emojis if they cross the cache maintained limit
  if ([recentEmojis count] > self.recentEmojisMaintainedCount) {
    NSIndexSet *indexesToBeRemoved = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.recentEmojisMaintainedCount, [recentEmojis count] - self.recentEmojisMaintainedCount)];
    [recentEmojis removeObjectsAtIndexes:indexesToBeRemoved];
  }
  [[NSUserDefaults standardUserDefaults] setObject:recentEmojis forKey:RecentALUsedEmojiCharactersKey];
}

- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<ALEmojiKeyboardViewDataSource>)dataSource categories:(NSArray*)categories{
  self = [super initWithFrame:frame];
  if (self) {
    // initialize category
    
    _dataSource = dataSource;
    
    self.backgroundColor = [UIColor colorWithRGBHex:0xf0f1f2];
    
    UIView *lineA = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    lineA.backgroundColor = [UIColor colorWithRGBHex:0xe0e0e0];
    [self addSubview:lineA];
    
    self.categories = [categories copy];
    
    self.category = [self categoryNameAtIndex:self.defaultSelectedCategory customCategory:self.categories];
    
    self.bgBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 171, 320, 45)];
    self.bgBarView.backgroundColor= [UIColor colorWithRGBHex:0xf7f9fa];
    [self addSubview:self.bgBarView];
    
    self.btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnSend setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRGBHex:0xf7f9fa] size:CGSizeMake(60, 45)]
                            forState:UIControlStateDisabled];
    [self.btnSend setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRGBHex:0x63358e] size:CGSizeMake(60, 45)]
                            forState:UIControlStateNormal];
    [self.btnSend setTitle:@"发送" forState:UIControlStateNormal];
    [self.btnSend setTitleColor:[UIColor colorWithRGBHex:0x7f7e80] forState:UIControlStateDisabled];
    [self.btnSend setTitleColor:[UIColor colorWithRGBHex:0xffffff] forState:UIControlStateNormal];
    [self.btnSend.titleLabel setFont:[UIFont systemFontOfSize:16]];
    self.btnSend.frame = CGRectMake(260, 171, 60, 46);
    UIView *btnLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.5, 45)];
    btnLine.backgroundColor = [UIColor colorWithRGBHex:0xd7d7d9];
    [self.btnSend addSubview:btnLine];
    [self addSubview:self.btnSend];
    
    
    NSArray *items = [self.imagesForSelectedSegments subarrayWithRange:NSMakeRange(0, self.categories.count+1)];
    
    self.segmentsBar = [[UISegmentedControl alloc] initWithItems:items];
    self.segmentsBar.frame = CGRectMake(0, 171, 60*([self.categories count]+1), 45);
    self.segmentsBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.segmentsBar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRGBHex:0xf7f9fa]
                                                            size:CGSizeMake(80, 45)]
                                forState:UIControlStateNormal
                              barMetrics:UIBarMetricsDefault];
    [self.segmentsBar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRGBHex:0xe3e4e6]
                                                            size:CGSizeMake(80, 45)]
                                forState:UIControlStateSelected
                              barMetrics:UIBarMetricsDefault];
    [self.segmentsBar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRGBHex:0xe3e4e6]
                                                            size:CGSizeMake(80, 45)]
                                forState:UIControlStateHighlighted
                              barMetrics:UIBarMetricsDefault];
    [self.segmentsBar setDividerImage:[UIImage imageWithColor:[UIColor colorWithRGBHex:0xd7d7d9] size:CGSizeMake(0.5, 45)]
                  forLeftSegmentState:UIControlStateSelected
                    rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [self.segmentsBar addTarget:self action:@selector(categoryChangedViaSegmentsBar:) forControlEvents:UIControlEventValueChanged];
    [self setSelectedCategoryImageInSegmentControl:self.segmentsBar AtIndex:self.defaultSelectedCategory];
    self.segmentsBar.selectedSegmentIndex = self.defaultSelectedCategory;
    
    [self addSubview:self.segmentsBar];
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.currentPage = 0;
    self.pageControl.backgroundColor = [UIColor clearColor];
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithRGBHex:0xd7d8d9];
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRGBHex:0xb1b2b3];
    CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:3];
    NSUInteger numberOfPages = [self numberOfPagesForCategory:self.category
                                                  inFrameSize:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetHeight(self.segmentsBar.bounds) - pageControlSize.height)];
    self.pageControl.numberOfPages = numberOfPages;
    pageControlSize = [self.pageControl sizeForNumberOfPages:numberOfPages];
    self.pageControl.frame = CGRectIntegral(CGRectMake((CGRectGetWidth(self.bounds) - pageControlSize.width) / 2,
                                                       CGRectGetHeight(self.bounds) - pageControlSize.height,
                                                       pageControlSize.width,
                                                       pageControlSize.height));
    [self.pageControl addTarget:self action:@selector(pageControlTouched:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.pageControl];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                     7.5,
                                                                     CGRectGetWidth(self.bounds),
                                                                     CGRectGetHeight(self.bounds) - CGRectGetHeight(self.segmentsBar.bounds) - pageControlSize.height)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    
    [self addSubview:self.scrollView];
    
    UIView *lineB = [[UIView alloc] initWithFrame:CGRectMake(0, 171, 320, 1)];
    lineB.backgroundColor = [UIColor colorWithRGBHex:0xe0e0e0];
    [self addSubview:lineB];
  }
  return self;
}

- (void)layoutSubviews {
  CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:3];
  NSUInteger numberOfPages = [self numberOfPagesForCategory:self.category
                                                inFrameSize:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetHeight(self.segmentsBar.bounds) - pageControlSize.height)];
  
  NSInteger currentPage = (self.pageControl.currentPage > numberOfPages) ? numberOfPages : self.pageControl.currentPage;
  
  // if (currentPage > numberOfPages) it is set implicitly to max pageNumber available
  self.pageControl.numberOfPages = numberOfPages;
  pageControlSize = [self.pageControl sizeForNumberOfPages:numberOfPages];
  self.pageControl.frame = CGRectIntegral(CGRectMake((CGRectGetWidth(self.bounds) - pageControlSize.width) / 2,134,
                                                     pageControlSize.width,
                                                     pageControlSize.height));
  
  self.scrollView.frame = CGRectMake(0,7.5,320,134);
  [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.bounds) * currentPage, 0);
  self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds) * numberOfPages, CGRectGetHeight(self.scrollView.bounds));
  [self purgePageViews];
  self.pageViews = [NSMutableArray array];
  [self setPage:currentPage];
}

#pragma mark event handlers

- (void)setSelectedCategoryImageInSegmentControl:(UISegmentedControl *)segmentsBar AtIndex:(NSInteger)index {
  for (int i=0; i < self.segmentsBar.numberOfSegments; ++i) {
    if ([[UIDevice currentDevice] isIOS7]) {
      [segmentsBar setImage:[self.imagesForNonSelectedSegments[i]
                             imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
          forSegmentAtIndex:i];
    }
    else{
      [segmentsBar setImage:self.imagesForNonSelectedSegments[i]
          forSegmentAtIndex:i];
    }
  }
  if ([[UIDevice currentDevice] isIOS7]) {
    [segmentsBar setImage:[self.imagesForSelectedSegments[index]
                           imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:index];
  }
  else{
    [segmentsBar setImage:self.imagesForSelectedSegments[index] forSegmentAtIndex:index];
    
  }
}

- (void)categoryChangedViaSegmentsBar:(UISegmentedControl *)sender {
  // recalculate number of pages for new category and recreate emoji pages
  DDLogInfo(@"%@", @( sender.selectedSegmentIndex ));
  
  self.category = [self categoryNameAtIndex:sender.selectedSegmentIndex customCategory:self.categories];
  [self setSelectedCategoryImageInSegmentControl:sender AtIndex:sender.selectedSegmentIndex];
  self.pageControl.currentPage = 0;
  [self setNeedsLayout];
}

- (void)pageControlTouched:(UIPageControl *)sender {
  DDLogInfo(@"%@", @( sender.currentPage ));
  CGRect bounds = self.scrollView.bounds;
  bounds.origin.x = CGRectGetWidth(bounds) * sender.currentPage;
  bounds.origin.y = 0;
  // scrollViewDidScroll is called here. Page set at that time.
  [self.scrollView scrollRectToVisible:bounds animated:YES];
}

// Track the contentOffset of the scroll view, and when it passes the mid
// point of the current view’s width, the views are reconfigured.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
  NSInteger newPageNumber = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
  if (self.pageControl.currentPage == newPageNumber) {
    return;
  }
  self.pageControl.currentPage = newPageNumber;
  [self setPage:self.pageControl.currentPage];
}

#pragma mark change a page on scrollView

// Check if setting pageView for an index is required
- (BOOL)requireToSetPageViewForIndex:(NSUInteger)index {
  if (index >= self.pageControl.numberOfPages) {
    return NO;
  }
  for (ALEmojiPageView *page in self.pageViews) {
    if ((page.frame.origin.x / CGRectGetWidth(self.scrollView.bounds)) == index) {
      return NO;
    }
  }
  return YES;
}

// Create a pageView and add it to the scroll view.
- (ALEmojiPageView *)synthesizeEmojiPageView {
  NSUInteger rows = [self numberOfRowsForFrameSize:self.scrollView.bounds.size];
  NSUInteger columns = [self numberOfColumnsForFrameSize:self.scrollView.bounds.size];
  ALEmojiPageView *pageView = [[ALEmojiPageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds), CGRectGetHeight(self.scrollView.bounds))
                                                backSpaceButtonImage:[self.dataSource backSpaceButtonImageForEmojiKeyboardView:self]
                                                          buttonSize:CGSizeMake(ButtonWidth, ButtonHeight)
                                                                rows:rows
                                                             columns:columns
                                                            category:self.category];
  pageView.delegate = self;
  [self.pageViews addObject:pageView];
  [self.scrollView addSubview:pageView];
  return pageView;
}

// return a pageView that can be used in the current scrollView.
// look for an available pageView in current pageView-s on scrollView.
// If all are in use i.e. are of current page or neighbours
// of current page, we create a new one

- (ALEmojiPageView *)usableEmojiPageView {
  ALEmojiPageView *pageView = nil;
  for (ALEmojiPageView *page in self.pageViews) {
    NSUInteger pageNumber = page.frame.origin.x / CGRectGetWidth(self.scrollView.bounds);
    if (abs((int)(pageNumber - self.pageControl.currentPage)) > 1) {
      pageView = page;
      break;
    }
  }
  if (!pageView) {
    pageView = [self synthesizeEmojiPageView];
  }
  return pageView;
}

// Set emoji page view for given index.
- (void)setEmojiPageViewInScrollView:(UIScrollView *)scrollView atIndex:(NSUInteger)index {
  
  if (![self requireToSetPageViewForIndex:index]) {
    return;
  }
  
  ALEmojiPageView *pageView = [self usableEmojiPageView];
  
  NSUInteger rows = [self.category isEqualToString:@"People"]?[self numberOfRowsForFrameSize:scrollView.bounds.size]:2;
  NSUInteger columns = [self.category isEqualToString:@"People"]?[self numberOfColumnsForFrameSize:scrollView.bounds.size]:4;
  NSUInteger startingIndex = [self.category isEqualToString:@"People"]?index * (rows * columns - 1):index*(rows*columns);
  NSUInteger endingIndex = [self.category isEqualToString:@"People"]?(index + 1) * (rows * columns - 1):(index + 1) * (rows * columns);
  NSMutableArray *buttonTexts = [self emojiTextsForCategory:self.category
                                                  fromIndex:startingIndex
                                                    toIndex:endingIndex];
  DDLogInfo(@"Setting page at index %@", @( index ));
  [pageView setButtonTexts:buttonTexts];
  pageView.frame = CGRectMake(index * CGRectGetWidth(scrollView.bounds), 0, CGRectGetWidth(scrollView.bounds), CGRectGetHeight(scrollView.bounds));
}

// Set the current page.
// sets neightbouring pages too, as they are viewable by part scrolling.
- (void)setPage:(NSInteger)page {
  [self setEmojiPageViewInScrollView:self.scrollView atIndex:page - 1];
  [self setEmojiPageViewInScrollView:self.scrollView atIndex:page];
  [self setEmojiPageViewInScrollView:self.scrollView atIndex:page + 1];
}

- (void)purgePageViews {
  for (ALEmojiPageView *page in self.pageViews) {
    page.delegate = nil;
  }
  self.pageViews = nil;
}

#pragma mark data methods

- (NSUInteger)numberOfColumnsForFrameSize:(CGSize)frameSize {
  return (NSUInteger)floor(frameSize.width / ButtonWidth);
}

- (NSUInteger)numberOfRowsForFrameSize:(CGSize)frameSize {
  return (NSUInteger)floor(frameSize.height / ButtonHeight);
}

- (NSArray *)emojiListForCategory:(NSString *)category {
  if ([category isEqualToString:segmentRecentName]) {
    return [self recentEmojis];
  }
  return [self.emojis objectForKey:category];
}

// for a given frame size of scroll view, return the number of pages
// required to show all the emojis for a category
- (NSUInteger)numberOfPagesForCategory:(NSString *)category inFrameSize:(CGSize)frameSize {
  
  if ([category isEqualToString:segmentRecentName]) {
    return 1;
  }
  else if ([category isEqualToString:@"Baobao"]){
    return [[self emojiListForCategory:@"Baobao"] count]/8;
  }
  NSUInteger emojiCount = [[self emojiListForCategory:category] count];
  NSUInteger numberOfRows = [self numberOfRowsForFrameSize:frameSize];
  NSUInteger numberOfColumns = [self numberOfColumnsForFrameSize:frameSize];
  NSUInteger numberOfEmojisOnAPage = (numberOfRows * numberOfColumns) - 1;
  
  NSUInteger numberOfPages = (NSUInteger)ceil((float)emojiCount / numberOfEmojisOnAPage);
  DDLogInfo(@"%@ %@ %@ :: %@", @( numberOfRows ), @( numberOfColumns ), @( emojiCount ), @( numberOfPages ));
  return numberOfPages;
}

// return the emojis for a category, given a staring and an ending index
- (NSMutableArray *)emojiTextsForCategory:(NSString *)category fromIndex:(NSUInteger)start toIndex:(NSUInteger)end {
  NSArray *emojis = [self emojiListForCategory:category];
  end = ([emojis count] > end)? end : [emojis count];
  NSIndexSet *index = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(start, end-start)];
  return [[emojis objectsAtIndexes:index] mutableCopy];
}

#pragma mark EmojiPageViewDelegate

- (void)setInRecentsEmoji:(NSString *)emoji {
  NSAssert(emoji != nil, @"Emoji can't be nil");
  
  NSMutableArray *recentEmojis = [self recentEmojis];
  for (int i = 0; i < [recentEmojis count]; ++i) {
    if ([recentEmojis[i] isEqualToString:emoji]) {
      [recentEmojis removeObjectAtIndex:i];
    }
  }
  [recentEmojis insertObject:emoji atIndex:0];
  [self setRecentEmojis:recentEmojis];
}

// add the emoji to recents
- (void)emojiPageView:(ALEmojiPageView *)emojiPageView didUseEmoji:(NSString *)emoji {
  [self setInRecentsEmoji:emoji];
  [self.delegate emojiKeyBoardView:self didUseEmoji:emoji];
}

- (void)emojiPageViewDidPressBackSpace:(ALEmojiPageView *)emojiPageView {
  DDLogInfo(@"Back button pressed");
  [self.delegate emojiKeyBoardViewDidPressBackSpace:self];
}

@end
