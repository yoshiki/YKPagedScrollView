YKPagedScrollView
=================

YKPagedScrollView is UIScrollView subclass has interface like UITableview. This library is based on [NNRotationBanner](https://github.com/naonya3/NNRotationBanner), and inspired [PunchScrollView](https://github.com/tapwork/PunchScrollView)

- Reusable views.
- Easy to use interface like UITableView.
- Infinite scroll supports.
- Horizontal/Vertical scroll supports.

Installation
=================

Just copy YKPagedScrollView/* to your project.

Usage
=================

### Construction

```
- (void)viewDidLoad {
    [super viewDidLoad];

    YKPagedScrollView *scrollView = [[YKPagedScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.delegate = self;
    scrollView.dataSource = self;
    scrollView.direction = YKPagedScrollViewDirectionVertical;
    scrollView.infinite = YES;
    [self.view addSubview:scrollView];
}
```

### dataSource methods

```
// Should set numberOfPagesForLazyLoading larger than '2'
// if scrollview bounds is smaller than frame.
- (NSInteger)numberOfPagesInPagedScrollView {
    return 4; // Default value is 1
}

- (UIView *)pagedScrollView:(YKPagedScrollView *)pagedScrollView viewForPageAtIndex:(NSInteger)index {
    UIView *page = [pagedScrollView dequeueReusablePage];
    
    if (page == nil) {
        page = [[UIView alloc] initWithFrame:self.view.bounds];
    }
    
    // some procee for `page` object.
    
    return page;
}

// Set rect of a page that is smaller than a view frame
- (CGRect)rectForPage {
    return CGRectInset(self.view.bounds, 10.0f, 10.0f);
}
```

### delegate methods

```
- (void)pagedScrollView:(YKPagedScrollView *)pagedScrollView pageWillChangeFrom:(NSInteger)index {
    NSLog(@"A page will change from %d", index);
}

- (void)pagedScrollView:(YKPagedScrollView *)pagedScrollView pageDidChangeTo:(NSInteger)index {
    NSLog(@"A page changed to %d", index);
}
```
