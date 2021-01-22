
#import "VPageControl.h"

@implementation VPageControl

@synthesize numberOfPages;
@synthesize currentPage;

@synthesize indicatorSize;
@synthesize indicatorSpace;
@synthesize activeColor;
@synthesize inactiveColor;

-(id)init
{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        indicatorSize = 6;
        indicatorSpace = 10;
        activeColor = [[UIColor whiteColor] retain];
        inactiveColor = [[UIColor colorWithRed:0.86 green:1 blue:0.86 alpha:1] retain];
    }
    return self;
}

-(void)setCurrentPage:(int)page
{
    currentPage = page;
    [self setNeedsDisplay];
}

-(void)setNumberOfPages:(int)n
{
    numberOfPages = n;
    self.bounds = CGRectMake(0, 0, (indicatorSize + indicatorSpace) * numberOfPages - indicatorSpace, indicatorSize);
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)clip
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    // start in the middle (or slightly left if even number of positions)
    const float startX = self.bounds.origin.x + (self.bounds.size.width / 2) - 
		((self.numberOfPages % 2) * (indicatorSize / 2)) + 
		((1 - (self.numberOfPages % 2)) * (indicatorSpace / 2)) - 
		((indicatorSize + indicatorSpace) * (self.numberOfPages / 2));

    float x = startX;

    for (int i = 0; i < self.numberOfPages; i++) {
        if (i == self.currentPage) {
            CGContextSetFillColorWithColor(context, [activeColor CGColor]);
        } else {
            CGContextSetFillColorWithColor(context, [inactiveColor CGColor]);
        }
        CGContextFillEllipseInRect(context, CGRectMake(x, 0, indicatorSize, indicatorSize));
        
		x += indicatorSize + indicatorSpace;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject] locationInView:self];
    int newPage = currentPage;
    if (p.x < (indicatorSize + indicatorSpace) * currentPage && currentPage > 0) {
        newPage = currentPage-1;
    } else if (p.x > (indicatorSize + indicatorSpace) * currentPage + indicatorSize && (currentPage < numberOfPages-1)) {
        newPage = currentPage+1;
    }

    if (newPage != currentPage) {
        currentPage = newPage;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        [self setNeedsDisplay];
    }
}

-(void)dealloc
{
    [activeColor release];
    [inactiveColor release];
    
    [super dealloc];
}

@end
