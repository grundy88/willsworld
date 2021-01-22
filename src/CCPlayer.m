//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCPlayer.h"


/*!
   Author: StadiaJack
   Date: 10/21/09
 */
@implementation CCPlayer

@synthesize name;
@synthesize currentLevelPack;
@synthesize settings;

-(void)dealloc
{
    [name release];
    [currentLevelPack release];
    [settings release];
    [super dealloc];
}

@end
