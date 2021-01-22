//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCDPadView.h"
#import "CCMainView.h"


/*!
   Author: StadiaJack
   Date: 11/12/09
 */
@implementation CCDPadView

@synthesize mainView;

-(id)init
{
    if (self = [super init]) {
        UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dpad.png"]];
        img.userInteractionEnabled = NO;
        img.frame = self.bounds;
        img.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:img];
        [img release];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


-(CCDirection)dirForPoint:(CGPoint)p
{
    CCDirection dir;
    int c = self.bounds.size.width * 0.28;
    int s = self.bounds.size.width * 0.36;
    if (p.x >= s && p.x <= s+c && p.y >= s && p.y <= s+c) {
        dir = NONE;
    } else if (p.x >= p.y) {
        if (p.x <= self.bounds.size.height-p.y) {
            dir = NORTH;
        } else {
            dir = EAST;
        }
    } else {
        if (p.x <= self.bounds.size.height-p.y) {
            dir = WEST;
        } else {
            dir = SOUTH;
        }
    }
    return dir;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject] locationInView:self];
    [mainView submitButtonDir:[self dirForPoint:p] addToQueue:YES];
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject] locationInView:self];
    [mainView submitButtonDir:[self dirForPoint:p] addToQueue:NO];
    [super touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [mainView submitButtonDir:NONE addToQueue:NO];
    [super touchesEnded:touches withEvent:event];
}

@end
