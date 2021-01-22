//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCSkin.h"


/*!
   Author: StadiaJack
   Date: 10/22/09
 */
@implementation CCSkin

@synthesize buttonAlpha;
@dynamic tileset;

-(id)init
{
    if (self = [super init]) {
        buttonAlpha = 0.85;
    }
    return self;
}


+(CCSkin *)instance
{
	static CCSkin *instance = nil;
	@synchronized(self) {
		if (!instance) {
			instance = [CCSkin new];
        }
	}
	return instance;
}

@end
