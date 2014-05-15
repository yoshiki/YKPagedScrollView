//
//  YKPagedScrollView.h
//  YKPagedScrollView
//
//  Created by Yoshiki Kurihara on 2013/10/04.
//  Copyright (c) 2013年 Yoshiki Kurihara. All rights reserved.
//

#import <UIKit/UIKit.h>

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
- (CGSize)sizeForPage;

@end

@interface YKPagedScrollView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableSet *visiblePages;
@property (nonatomic, unsafe_unretained) id<YKPagedScrollViewDelegate> delegate;
@property (nonatomic, unsafe_unretained) id<YKPagedScrollViewDataSource> dataSource;
@property (nonatomic, assign) YKPagedScrollViewDirection direction;
@property (nonatomic, assign) BOOL infinite;

- (void)reloadData;
- (UIView *)dequeueReusablePage;
- (NSArray *)storedPages;
- (NSInteger)currentIndex;
- (UIView *)currentPage;

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated;
- (void)scrollToNextPageAnimated:(BOOL)animated;
- (void)scrollToPreviousPageAnimated:(BOOL)animated;

@end
