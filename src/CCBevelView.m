//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCBevelView.h"


/*!
   Author: StadiaJack
   Date: 10/19/09
 */
@implementation CCBevelView

@synthesize bevelWidth;
@synthesize raised;
@synthesize skipFlags;
@synthesize fillColor;

-(id)init
{
    if (self = [super init]) {
        bevelWidth = 3;
        raised = YES;
        self.backgroundColor = [UIColor clearColor];
        fillColor = KRGBColorMake(0.75, 0.75, 0.75, 1);
    }
    return self;
}


-(void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    int left = (skipFlags & CCBevelSkipLeft) ? bevelWidth : 0;
    int right = (skipFlags & CCBevelSkipRight) ? bevelWidth : 0;
    int top = (skipFlags & CCBevelSkipTop) ? bevelWidth : 0;
    int bottom = (skipFlags & CCBevelSkipBottom) ? bevelWidth : 0;
    CGRect clipRect = CGRectMake(left, top, self.bounds.size.width-left-right, self.bounds.size.height-top-bottom);
    CGContextAddRect(context, clipRect);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextBeginPath(context);
    if (raised) {
        CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
        CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    } else {
        CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1);
        CGContextSetRGBFillColor(context, 0.5, 0.5, 0.5, 1);
    }
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width-bevelWidth, bevelWidth);
    CGContextAddLineToPoint(context, bevelWidth, bevelWidth);
    CGContextAddLineToPoint(context, bevelWidth, self.bounds.size.height-bevelWidth);
    CGContextAddLineToPoint(context, 0, self.bounds.size.height);
    CGContextFillPath(context);
    
    CGContextBeginPath(context);
    if (raised) {
        CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1);
        CGContextSetRGBFillColor(context, 0.5, 0.5, 0.5, 1);
    } else {
        CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
        CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    }
    CGContextMoveToPoint(context, self.bounds.size.width, self.bounds.size.height);
    CGContextAddLineToPoint(context, 0, self.bounds.size.height);
    CGContextAddLineToPoint(context, bevelWidth, self.bounds.size.height-bevelWidth);
    CGContextAddLineToPoint(context, self.bounds.size.width-bevelWidth, self.bounds.size.height-bevelWidth);
    CGContextAddLineToPoint(context, self.bounds.size.width-bevelWidth, bevelWidth);
    CGContextAddLineToPoint(context, self.bounds.size.width, 0);
    CGContextFillPath(context);
    
    
//    CGContextBeginPath(context);
//    if (raised) {
//        CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
//        CGContextSetRGBFillColor(context, 1, 1, 1, 1);
//    } else {
//        CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1);
//        CGContextSetRGBFillColor(context, 0.5, 0.5, 0.5, 1);
//    }
//    if (skipFlags & CCBevelSkipTop) {
//        CGContextMoveToPoint(context, 0, bevelWidth);
//    } else {
//        CGContextMoveToPoint(context, 0, 0);
//        CGContextAddLineToPoint(context, self.bounds.size.width, 0);
//        CGContextAddLineToPoint(context, self.bounds.size.width-bevelWidth, bevelWidth);
//    }
//    CGContextAddLineToPoint(context, bevelWidth, bevelWidth);
//    CGContextAddLineToPoint(context, bevelWidth, self.bounds.size.height-bevelWidth);
//    if (skipFlags & CCBevelSkipBottom) {
//        CGContextAddLineToPoint(context, 0, self.bounds.size.height-bevelWidth);
//    } else {
//        CGContextAddLineToPoint(context, 0, self.bounds.size.height);
//    }
//    CGContextFillPath(context);
//    
//    CGContextBeginPath(context);
//    if (raised) {
//        CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1);
//        CGContextSetRGBFillColor(context, 0.5, 0.5, 0.5, 1);
//    } else {
//        CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
//        CGContextSetRGBFillColor(context, 1, 1, 1, 1);
//    }
//    if (skipFlags & CCBevelSkipBottom) {
//        CGContextMoveToPoint(context, self.bounds.size.width, self.bounds.size.height-bevelWidth);
//    } else {
//        CGContextMoveToPoint(context, self.bounds.size.width, self.bounds.size.height);
//        CGContextAddLineToPoint(context, 0, self.bounds.size.height);
//        CGContextAddLineToPoint(context, bevelWidth, self.bounds.size.height-bevelWidth);
//    }
//    CGContextAddLineToPoint(context, self.bounds.size.width-bevelWidth, self.bounds.size.height-bevelWidth);
//    CGContextAddLineToPoint(context, self.bounds.size.width-bevelWidth, bevelWidth);
//    if (skipFlags && CCBevelSkipTop) {
//        CGContextAddLineToPoint(context, self.bounds.size.width, bevelWidth);
//    } else {
//        CGContextAddLineToPoint(context, self.bounds.size.width, 0);
//    }
//    CGContextFillPath(context);
    
    CGContextBeginPath(context);
    CGContextSetRGBFillColor(context, fillColor.r, fillColor.g, fillColor.b, fillColor.a);
    CGContextFillRect(context, CGRectInset(self.bounds, bevelWidth, bevelWidth));
}

@end
