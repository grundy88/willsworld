//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCCommon.h"

/*!
   Author: StadiaJack
   Date: 10/15/09
 */
@interface CCCoord : NSObject {
    CCPoint point;
}

@property (nonatomic, assign) CCPoint point;
@property (nonatomic, assign) byte x;
@property (nonatomic, assign) byte y;

-(id)initWithPoint:(CCPoint)_point;

@end
