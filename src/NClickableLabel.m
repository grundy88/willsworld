#import "NClickableLabel.h"

@implementation NClickableLabel

@synthesize label;
@synthesize target;
@synthesize selector;

@dynamic text;
@dynamic textAlignment;

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        label = [[UILabel alloc] initWithFrame:self.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.opaque = NO;
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        [label release];
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];

	if (touch.phase == UITouchPhaseEnded && touch.tapCount == 1) {
		[target performSelector:selector withObject:self];
	}
}

-(NSString *)text
{
    return label.text;
}

-(void)setText:(NSString *)text
{
    label.text = text;
}

-(UITextAlignment)textAlignment
{
    return label.textAlignment;
}

-(void)setTextAlignment:(UITextAlignment)textAlignment
{
    label.textAlignment = textAlignment;
}

@end
