//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCDigitView.h"
#import "CCDigits.h"

#define BEVEL 2

/*!
   Author: StadiaJack
   Date: 10/20/09
 */
@implementation CCDigitView

@synthesize num;
@synthesize yellowCutoff;

-(id)init
{
    if (self = [super init]) {
        num = 0;
        yellowCutoff = -1;
        raised = NO;
        bevelWidth = BEVEL;
        self.frame = CGRectMake(0, 0, CHAR_WIDTH*3 + BEVEL*2, CHAR_HEIGHT + BEVEL*2);
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSString *s;
    if (num == -1) {
        s = @"---";
    } else {
        s = [NSString stringWithFormat:@"%3d", num];
    }
    
    [[CCDigits instance] drawString:context string:s x:BEVEL y:BEVEL yellow:(num <= yellowCutoff)];
}

@end
