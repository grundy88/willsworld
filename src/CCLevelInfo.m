//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCLevelInfo.h"


/*!
   Author: StadiaJack
   Date: 10/21/09
 */
@implementation CCLevelInfo

@synthesize title;
@synthesize password;
@synthesize bestTime;
@synthesize highScore;
@synthesize unsuccessfulAttempts;

-(id)init
{
    if (self = [super init]) {
        bestTime = -1;
        highScore = 0;
        unsuccessfulAttempts = 0;
    }
    return self;
}


-(void)dealloc
{
    [title release];
    [password release];
    [super dealloc];
}

@end
