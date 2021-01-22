//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCExtensions.h"

/*!
   Author: StadiaJack
   Date: 10/30/09
 */

@implementation UIView (PRIVATE)

// Method to replace a given subview with another using a specified transition type, direction, and duration
-(void)replaceSubview:(UIView *)oldView 
          withSubview:(UIView *)newView 
           transition:(NSString *)transition 
            direction:(NSString *)direction 
             duration:(NSTimeInterval)duration
             delegate:(id)delegate
{
    // If a transition is in progress, do nothing
    NSArray *subViews = [self subviews];
    NSUInteger index = 0;
    
    if ([oldView superview] == self) {
        // Find the index of oldView so that we can insert newView at the same place
        for(index = 0; [subViews objectAtIndex:index] != oldView; ++index) {}
        [oldView removeFromSuperview];
    }
    
    // If there's a new view and it doesn't already have a superview, insert it where the old view was
    if (newView && ([newView superview] == nil))
        [self insertSubview:newView atIndex:index];
    
    
    // Set up the animation
    CATransition *animation = [CATransition animation];
    [animation setDelegate:delegate];
    
    // Set the type and if appropriate direction of the transition, 
    if (transition == kCATransitionFade) {
        [animation setType:kCATransitionFade];
    } else {
        [animation setType:transition];
        [animation setSubtype:direction];
    }
    
    // Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
    [animation setDuration:duration];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [[self layer] addAnimation:animation forKey:@"transitionViewAnimation"];
}

@end

@implementation NSString(PRIVATE)

-(NSString *)urlEncode
{
    NSString *s = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                               kCFStringEncodingUTF8);
    return [s autorelease];
}

@end
