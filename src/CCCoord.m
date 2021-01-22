//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCCoord.h"


/*!
   Author: StadiaJack
   Date: 10/15/09
 */
@implementation CCCoord

@synthesize point;
@dynamic x;
@dynamic y;

-(id)initWithPoint:(CCPoint)_point
{
    if (self = [super init]) {
        point = _point;
    }
    return self;
}

-(byte)x
{
    return point.x;
}

-(void)setX:(byte)_x
{
    point.x = _x;
}

-(byte)y
{
    return point.y;
}

-(void)setY:(byte)_y
{
    point.y = _y;
}

@end
