//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCControlView.h"
#import "CCMainView.h"

static int touchCount = 0;

/*!
   Author: StadiaJack
   Date: 11/12/09
 */
@implementation CCControlView

@synthesize mainView;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    touchCount += touches.count;
#if BUTTON_DEBUG == 1
    printf("Began %d\n", touchCount);
#endif
    [mainView submitButtonDir:self.tag addToQueue:YES];

    [super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
#if BUTTON_DEBUG == 1
    printf("Moved %d\n", touchCount);
#endif
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:mainView];
    UIView *v = [mainView hitTest:p withEvent:nil];
    
    CGPoint prevPoint = [touch previousLocationInView:mainView];
    UIView *prevView = [mainView hitTest:prevPoint withEvent:nil];
    if (prevView.tag != v.tag) {
        [mainView removeButtonDir:prevView.tag];
    }
    
    [mainView submitButtonDir:v.tag addToQueue:NO];
    [super touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    touchCount -= touches.count;
#if BUTTON_DEBUG == 1
    printf("Ended %d\n", touchCount);
#endif
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:mainView];
    UIView *v = [mainView hitTest:p withEvent:nil];
    [mainView removeButtonDir:v.tag];
    
    if (touchCount <= 0) {
        [mainView clearButtonStack];
        touchCount = 0;
    }
    
    [super touchesEnded:touches withEvent:event];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    touchCount -= touches.count;
#if BUTTON_DEBUG == 1
    printf("Cancelled %d\n", touchCount);
#endif
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:mainView];
    UIView *v = [mainView hitTest:p withEvent:nil];
    [mainView removeButtonDir:v.tag];
    
    if (touchCount <= 0) {
        [mainView clearButtonStack];
        touchCount = 0;
    }
    
    [super touchesCancelled:touches withEvent:event];
}

-(void)dealloc
{
    [super dealloc];
}

@end
