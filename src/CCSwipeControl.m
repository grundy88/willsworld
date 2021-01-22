//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCSwipeControl.h"
#import "CCMainView.h"


/*!
   Author: StadiaJack
   Date: 11/13/09
 */
@implementation CCSwipeControl

@synthesize mainView;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    startPoint = [[touches anyObject] locationInView:self];
    lastDirection = NONE;
    [super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject] locationInView:self];
    int deltax = p.x - startPoint.x;
    int deltay = p.y - startPoint.y;
    if (abs(deltax) >= 10 || abs(deltay) >= 10) {
        CCDirection dir = NONE;
        if (abs(deltax) > abs(deltay)) {
            dir = (deltax > 0) ? EAST : WEST;
        } else {
            dir = (deltay > 0) ? SOUTH : NORTH;
        }
        startPoint = p;
        [mainView submitButtonDir:dir addToQueue:(dir != lastDirection)];
        lastDirection = dir;
    }

    [super touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [mainView submitButtonDir:NONE addToQueue:NO];
    [super touchesEnded:touches withEvent:event];
}

@end
