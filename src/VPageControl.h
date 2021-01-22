
@interface VPageControl : UIControl {
    NSInteger numberOfPages;
    NSInteger currentPage;

    int indicatorSize;
    int indicatorSpace;
    UIColor *activeColor;
    UIColor *inactiveColor;
}

@property (nonatomic) NSInteger numberOfPages;
@property (nonatomic) NSInteger currentPage;

@property (nonatomic, assign) int indicatorSize;
@property (nonatomic, assign) int indicatorSpace;
@property (nonatomic, retain) UIColor *activeColor;
@property (nonatomic, retain) UIColor *inactiveColor;

@end
