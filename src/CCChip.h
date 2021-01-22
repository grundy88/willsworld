//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCEntity.h"

@class CCMainView;

/*!
   Author: StadiaJack
   Date: 10/7/09
 */
@interface CCChip : CCCreature {
    CCMainView *mainView;
    BOOL draw;
    NSTimeInterval lastMove;
    byte lastCode;
    BOOL didOverride;
    BOOL didSlide;
    BOOL playOof;
}

@property (nonatomic, assign) CCMainView *mainView;
@property (nonatomic, assign) BOOL playOof;

-(void)checkDirReset;

@end
