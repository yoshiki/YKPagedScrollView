//
//  YKPagedScrollView.h
//  YKPagedScrollView
//
//  Created by Yoshiki Kurihara on 2013/10/04.
//  Copyright (c) 2013年 Yoshiki Kurihara. All rights reserved.
//

#import <UIKit/UIKit.h>

#undef weak_delegate
#undef __weak_delegate
#if __has_feature(objc_arc) && __has_feature(objc_arc_weak) && \
(!(defined __MAC_OS_X_VERSION_MIN_REQUIRED) || \
__MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_8)
#define weak_delegate weak
#else
#define weak_delegate unsafe_unretained
#endif

typedef enum {
    YKPagedScrollViewDirectionHorizontal = 0,
    YKPagedScrollViewDirectionVertical,
} YKPagedScrollViewDirection;

@class YKPagedScrollView;

@protocol YKPagedScrollViewDelegate <UIScrollViewDelegate>

@optional
- (void)pagedScrollView:(YKPagedScrollView *)pagedScrollView pageWillChangeFrom:(NSInteger)index;
- (void)pagedScrollView:(YKPagedScrollView *)pagedScrollView pageDidChangeTo:(NSInteger)index;

@end

@protocol YKPagedScrollViewDataSource <UIScrollViewDelegate>

@required
- (NSInteger)numberOfPagesInPagedScrollView;
- (UIView *)pagedScrollView:(YKPagedScrollView *)pagedScrollView viewForPageAtIndex:(NSInteger)index;

@optional
- (NSInteger)numberOfPagesForLazyLoading;
- (CGRect)rectForPage;

@end

@interface YKPagedScrollView : UIView <UIScrollViewDelegate>

@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, readonly) NSMutableSet *visiblePages;
@property (nonatomic, readonly) NSMutableSet *reusablePages;
@property (nonatomic, weak_delegate) id<YKPagedScrollViewDelegate> delegate;
@property (nonatomic, weak_delegate) id<YKPagedScrollViewDataSource> dataSource;
@property (nonatomic, assign) YKPagedScrollViewDirection direction;
@property (nonatomic, assign) BOOL infinite;
@property (nonatomic, assign) BOOL pagingEnabled;

- (void)reloadData;
- (UIView *)dequeueReusablePage;
- (NSArray *)storedPages;
- (NSInteger)currentIndex;
- (UIView *)currentPage;

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;
- (void)scrollToNextPageAnimated:(BOOL)animated;
- (void)scrollToPreviousPageAnimated:(BOOL)animated;

@end
