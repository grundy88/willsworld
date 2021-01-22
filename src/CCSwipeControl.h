//  Copyright 2009 StadiaJack. All rights reserved.
#import "CCCommon.h"

@class CCMainView;

/*!
   Author: StadiaJack
   Date: 11/13/09
 */
@interface CCSwipeControl : UIView {
    CCMainView *mainView;
    
    CGPoint startPoint;
    CCDirection lastDirection;
}

@property (nonatomic, assign) CCMainView *mainView;

@end
