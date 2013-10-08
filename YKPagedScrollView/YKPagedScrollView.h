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
- (void)pagedScrollView:(YKPagedScrollView *)pagedScrollView pageWillChangedFrom:(NSInteger)index;
- (void)pagedScrollView:(YKPagedScrollView *)pagedScrollView pageDidChangedTo:(NSInteger)index;

@end

@protocol YKPagedScrollViewDataSource <UIScrollViewDelegate>

@required
- (NSInteger)numberOfPagesInPagedScrollView;
- (UIView *)pagedScrollView:(YKPagedScrollView *)pagedScrollView viewForPageAtIndex:(NSInteger)index;

@optional
- (NSInteger)numberOfPagesForLazyLoading;

@end

@interface YKPagedScrollView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableSet *visiblePages;
@property (nonatomic, unsafe_unretained) id<YKPagedScrollViewDelegate> delegate;
@property (nonatomic, unsafe_unretained) id<YKPagedScrollViewDataSource> dataSource;
@property (nonatomic, assign) YKPagedScrollViewDirection direction;
@property (nonatomic, assign) BOOL infinite;

- (void)reloadData;
- (UIView *)dequeueReusablePageWithIdentifier:(NSString *)identifier;
- (NSArray *)storedPages;
- (NSInteger)currentIndex;

@end
