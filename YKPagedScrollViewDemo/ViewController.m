//
//  ViewController.m
//  YKPagedScrollViewDemo
//
//  Created by Yoshiki Kurihara on 2013/10/04.
//  Copyright (c) 2013年 Yoshiki Kurihara. All rights reserved.
//

#import "ViewController.h"

#define kYKPagedScrollViewDemoNumberOfPages 4

@interface ViewController ()

@property (nonatomic, strong) YKPagedScrollView *scrollView;
@property (nonatomic, strong) NSMutableDictionary *colorCache;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _colorCache = @{}.mutableCopy;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    CGRect frame = CGRectInset(self.view.bounds, 30, 30);
    _scrollView = [[YKPagedScrollView alloc] initWithFrame:frame];
    _scrollView.delegate = self;
    _scrollView.dataSource = self;
    _scrollView.clipsToBounds = NO;
    _scrollView.pagingEnabled = YES;
    //_scrollView.pagingEnabled = NO;
    //_scrollView.direction = YKPagedScrollViewDirectionVertical;
    _scrollView.infinite = YES;
    [self.view addSubview:_scrollView];
    [_scrollView reloadData];
}

- (UIColor *)randomizedColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 );
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

#pragma mark - YKPagedScrollViewDelegate

- (void)pagedScrollView:(YKPagedScrollView *)pagedScrollView pageWillChangeFrom:(NSInteger)index {
    NSLog(@"A page will change from %d", index);
}

- (void)pagedScrollView:(YKPagedScrollView *)pagedScrollView pageDidChangeTo:(NSInteger)index {
    NSLog(@"A page changed to %d", index);
}

#pragma mark - YKPagedScrollViewDataSource

- (NSInteger)numberOfPagesInPagedScrollView {
    return kYKPagedScrollViewDemoNumberOfPages;
}

- (NSInteger)numberOfPagesForLazyLoading {
    return 2;
}

//- (CGRect)rectForPageAtIndex:(NSInteger)index {
//}

- (UIView *)pagedScrollView:(YKPagedScrollView *)pagedScrollView viewForPageAtIndex:(NSInteger)index {
    UIView *page = [pagedScrollView dequeueReusablePage];
    
    if (page == nil) {
        page = [[UIView alloc] initWithFrame:self.view.bounds];
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize:48.0f];
        label.tag = 999;
        [page addSubview:label];
    }
    
    UIColor *backgroundColor = [_colorCache objectForKey:@(index)];
    if (backgroundColor == nil) {
        backgroundColor = [self randomizedColor];
        [_colorCache setObject:backgroundColor forKey:@(index)];
    }
    page.backgroundColor = backgroundColor;
    
    UILabel *l = (UILabel *)[page viewWithTag:999];
    l.text = [NSString stringWithFormat:@"%d", index];
    [l sizeToFit];

    return page;
}

@end
