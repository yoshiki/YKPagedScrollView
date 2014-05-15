//
//  YKPagedScrollView.m
//  YKPagedScrollView
//
//  Created by Yoshiki Kurihara on 2013/10/04.
//  Copyright (c) 2013年 Yoshiki Kurihara. All rights reserved.
//

#import "YKPagedScrollView.h"

#define kYKPagedScrollViewAdvancedLengthFactor 4
#define kYKPagedScrollViewNumberOfLazyLoading 1

@interface YKPagedScrollView ()

@property (nonatomic, strong) NSMutableSet *reusablePages;
@property (nonatomic, assign) NSInteger numberOfPage;

@end

@implementation YKPagedScrollView

@synthesize delegate = delegate_;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _initialize];
    }
    return self;
}

- (void)setDataSource:(id<YKPagedScrollViewDataSource>)dataSource {
    _dataSource = dataSource;
    // Set bounds
    self.bounds = (CGRect){
        .origin = CGPointZero,
        .size = [self sizeForPage],
    };
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_infinite) {
        [self relocateContentOffset];
    }
    
    NSArray *indexes = [self indexesForPage];
    
    NSMutableSet *visiblePages = [NSMutableSet set];
    for (NSNumber *i in indexes) {
        NSInteger index = [i integerValue];
        UIView *page = [self pageAtIndex:index];
        page.tag = index;
        page.frame = [self rectForPageAtIndex:index];
        [self addSubview:page];
        [visiblePages addObject:page];
    }
    
    // remove current visible pages temporary.
    [_visiblePages minusSet:visiblePages];
    
    // now _visiblePages has only reusable pages.
    NSSet *reusablePages = _visiblePages;
    for (UIView *reusablePage in reusablePages) {
        [reusablePage removeFromSuperview];
    }
    [_reusablePages unionSet:reusablePages];
    
    // set new visible pages.
    _visiblePages = visiblePages;
}

#pragma mark - Private methods

- (void)_initialize {
    [super setDelegate:self];
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.pagingEnabled = YES;
    _reusablePages = [NSMutableSet set];
    _visiblePages = [NSMutableSet set];
    _direction = YKPagedScrollViewDirectionHorizontal; // default
    _infinite = NO; // default
}

- (NSArray *)indexesForPage {
    NSMutableArray *indexes = @[].mutableCopy;
    int startIndex = [self startIndex];
    int endIndex = [self endIndex];
    for (int i = startIndex; i <= endIndex; i++) {
        [indexes addObject:@(i)];
    }
    return indexes;
}

- (int)originalStartIndex {
    int startIndex = ((_direction == YKPagedScrollViewDirectionHorizontal)
                      ? (int)(self.contentOffset.x / [self sizeForPage].width)
                      : (int)(self.contentOffset.y / [self sizeForPage].height));
    return startIndex;
}

- (int)startIndex {
    int originalStartIndex = [self originalStartIndex];
    int startIndex = 0;
    if (_infinite) {
        startIndex = MAX(originalStartIndex - [self numberOfLazyLoading], 0);
    } else {
        if (originalStartIndex == 0) {
            startIndex = originalStartIndex;
        } else {
            startIndex = MAX(originalStartIndex - [self numberOfLazyLoading], 0);
        }
    }
    return startIndex;
}

- (int)endIndex {
    int originalStartIndex = [self originalStartIndex];
    int endIndex;
    if (_infinite) {
        endIndex = originalStartIndex + [self numberOfLazyLoading];
    } else {
        if (originalStartIndex == 0) {
            endIndex = originalStartIndex + [self numberOfLazyLoading];
        } else if (originalStartIndex == [self numberOfPage] - 2) {
            endIndex = originalStartIndex + [self numberOfLazyLoading] - 1;
        } else if (originalStartIndex == [self numberOfPage] - 1) {
            endIndex = originalStartIndex;
        } else {
            endIndex = originalStartIndex + [self numberOfLazyLoading];
        }
    }
    return endIndex;
}

- (UIView *)pageAtIndex:(NSInteger)index {
    UIView *page = [self visiblePageAtIndex:index];
    if (page != nil) {
        [page removeFromSuperview];
        return page;
    } else {
        NSInteger externalIndex = [self convertIndexFromInternalIndex:index];
        UIView *page = [self.dataSource pagedScrollView:self viewForPageAtIndex:externalIndex];
        return page;
    }
}

- (NSInteger)convertIndexFromInternalIndex:(NSInteger)index {
    return ((index < _numberOfPage)
            ? index
            : index % _numberOfPage);
}

- (CGSize)sizeForPage {
    if ([self.dataSource respondsToSelector:@selector(sizeForPage)]) {
        return [self.dataSource sizeForPage];
    } else {
        return self.bounds.size;
    }
}

- (CGRect)rectForPageAtIndex:(NSInteger)index {
    return (CGRect){
        .origin = ((_direction == YKPagedScrollViewDirectionHorizontal)
                   ? (CGPoint){
                       [self sizeForPage].width * index + (CGRectGetWidth(self.bounds) - [self sizeForPage].width)/2,
                       (CGRectGetHeight(self.bounds) - [self sizeForPage].height)/2
                   }
                   : (CGPoint){ 0.0f, [self sizeForPage].height * index }),
        .size = [self sizeForPage],
    };
}

- (UIView *)visiblePageAtIndex:(NSInteger)index {
    UIView *page = nil;
    for (UIView *_page in [_visiblePages allObjects]) {
        if (_page.tag == index) {
            page = _page;
            break;
        }
    }
    return page;
}

- (void)relocateContentOffset {
    if (_direction == YKPagedScrollViewDirectionHorizontal) {
        CGFloat offsetX = self.contentOffset.x;
        CGFloat maxX = [self sizeForPage].width * _numberOfPage * (kYKPagedScrollViewAdvancedLengthFactor - 1);
        CGFloat minX = [self sizeForPage].width * _numberOfPage;
        
        if (offsetX >= maxX) {
            self.contentOffset = (CGPoint){
                [self sizeForPage].width * _numberOfPage * ((int)kYKPagedScrollViewAdvancedLengthFactor/2) + abs(offsetX - maxX),
                0.0f
            };
        } else if (offsetX <= minX) {
            self.contentOffset = (CGPoint){
                [self sizeForPage].width * _numberOfPage * ((int)kYKPagedScrollViewAdvancedLengthFactor/2) + abs(offsetX - minX),
                0.0f
            };
        }
    } else {
        CGFloat offsetY = self.contentOffset.y;
        CGFloat maxY = [self sizeForPage].height * _numberOfPage * (kYKPagedScrollViewAdvancedLengthFactor - 1);
        CGFloat minY = [self sizeForPage].height * _numberOfPage;
        
        if (offsetY >= maxY) {
            self.contentOffset = (CGPoint){
                0.0f,
                [self sizeForPage].height * _numberOfPage * ((int)kYKPagedScrollViewAdvancedLengthFactor/2) + abs(offsetY - maxY)
            };
        } else if (offsetY <= minY) {
            self.contentOffset = (CGPoint){
                0.0f,
                [self sizeForPage].height * _numberOfPage * ((int)kYKPagedScrollViewAdvancedLengthFactor/2) + abs(offsetY - minY)
            };
        }
    }
}

- (NSInteger)numberOfLazyLoading {
    NSInteger num = 0;
    if ([self.dataSource respondsToSelector:@selector(numberOfPagesForLazyLoading)]) {
        num = [self.dataSource numberOfPagesForLazyLoading];
    } else {
        num = kYKPagedScrollViewNumberOfLazyLoading;
    }
    return (num > _numberOfPage) ? _numberOfPage : num;
}

- (CGSize)_contentSize {
    if (_infinite) {
        if (_direction == YKPagedScrollViewDirectionHorizontal) {
            return (CGSize){
                [self sizeForPage].width * _numberOfPage * kYKPagedScrollViewAdvancedLengthFactor,
                [self sizeForPage].height,
            };
        } else {
            return (CGSize){
                [self sizeForPage].width,
                [self sizeForPage].height * _numberOfPage * kYKPagedScrollViewAdvancedLengthFactor,
            };
        }
    } else {
        if (_direction == YKPagedScrollViewDirectionHorizontal) {
            return (CGSize){
                [self sizeForPage].width * _numberOfPage,
                [self sizeForPage].height,
            };
        } else {
            return (CGSize){
                [self sizeForPage].width,
                [self sizeForPage].height * _numberOfPage,
            };
        }
    }
}

- (CGPoint)_contentOffset {
    if (_infinite) {
        if (_direction == YKPagedScrollViewDirectionHorizontal) {
            return (CGPoint){
                [self sizeForPage].width * _numberOfPage * ((int)kYKPagedScrollViewAdvancedLengthFactor/2),
                0.0f
            };
        } else {
            return (CGPoint){
                0.0f,
                [self sizeForPage].height * _numberOfPage * ((int)kYKPagedScrollViewAdvancedLengthFactor/2),
            };
        }
    } else {
        return (CGPoint){
            0.0f,
            0.0f
        };
    }
}

- (void)pageDidChange {
    if ([self.delegate respondsToSelector:@selector(pagedScrollView:pageDidChangeTo:)]) {
        [self.delegate pagedScrollView:self pageDidChangeTo:[self currentIndex]];
    }
}

- (void)pageWillChange {
    if ([self.delegate respondsToSelector:@selector(pagedScrollView:pageWillChangeFrom:)]) {
        [self.delegate pagedScrollView:self pageWillChangeFrom:[self currentIndex]];
    }
}

#pragma mark - Public methods

- (void)setDelegate:(id<YKPagedScrollViewDelegate>)delegate {
    [super setDelegate:self];
    if (delegate_ != delegate) {
        delegate_ = delegate;
    }
}

- (void)reloadData {
    for (UIView *page in [_visiblePages allObjects]) {
        [page removeFromSuperview];
    }
    
    [_reusablePages removeAllObjects];
    [_visiblePages removeAllObjects];
    
    _numberOfPage = [self.dataSource numberOfPagesInPagedScrollView];
    self.contentSize = [self _contentSize];
    self.contentOffset = [self _contentOffset];
}

- (UIView *)dequeueReusablePage {
    UIView *reusablePage = [_reusablePages anyObject];
    if (reusablePage != nil) {
        [_reusablePages removeObject:reusablePage];
        return reusablePage;
    } else {
        return nil;
    }
}

- (NSArray *)storedPages {
    NSMutableArray *pages = @[].mutableCopy;
    [pages addObjectsFromArray:[_visiblePages allObjects]];
    [pages addObjectsFromArray:[_reusablePages allObjects]];
    return pages;
}

- (NSInteger)currentIndex {
    int index = [self startIndex];
    return [self convertIndexFromInternalIndex:index];
}

- (UIView *)currentPage {
    return [self visiblePageAtIndex:[self startIndex]];
}

- (void)scrollToIndex:(NSInteger)index animated:(BOOL)animated {
    [self performSelector:@selector(pageWillChange) withObject:nil afterDelay:0.0f];
    [self scrollRectToVisible:[self rectForPageAtIndex:index] animated:animated];
    [self performSelector:@selector(pageDidChange) withObject:nil afterDelay:0.1f];
}

- (void)scrollToNextPageAnimated:(BOOL)animated {
    if (!_infinite && [self currentIndex] == _numberOfPage - 1) return;
    NSInteger nextPageIndex = [self startIndex] + 1;
    [self performSelector:@selector(pageWillChange) withObject:nil afterDelay:0.0f];
    [self scrollRectToVisible:[self rectForPageAtIndex:nextPageIndex] animated:animated];
    [self performSelector:@selector(pageDidChange) withObject:nil afterDelay:0.1f];
}

- (void)scrollToPreviousPageAnimated:(BOOL)animated {
    if (!_infinite && [self currentIndex] == 0) return;
    NSInteger previousPageIndex = [self startIndex] - 1;
    [self performSelector:@selector(pageWillChange) withObject:nil afterDelay:0.0f];
    [self scrollRectToVisible:[self rectForPageAtIndex:previousPageIndex] animated:animated];
    [self performSelector:@selector(pageDidChange) withObject:nil afterDelay:0.1f];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self pageDidChange];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self pageWillChange];
}

@end
