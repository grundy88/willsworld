//  Copyright 2009 StadiaJack. All rights reserved.

#import <QuartzCore/QuartzCore.h>

/*!
   Author: StadiaJack
   Date: 10/30/09
 */

@interface UIView (PRIVATE)

-(void)replaceSubview:(UIView *)oldView 
          withSubview:(UIView *)newView 
           transition:(NSString *)transition 
            direction:(NSString *)direction 
             duration:(NSTimeInterval)duration
             delegate:(id)delegate;

@end

@interface NSString(PRIVATE)

-(NSString *)urlEncode;

@end
