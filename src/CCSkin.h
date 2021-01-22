//  Copyright 2009 StadiaJack. All rights reserved.

#define BACKGROUND_IMAGE @"background-ww.png"
//#define BACKGROUND_IMAGE @"background-tileworld.png"

/*!
   Author: StadiaJack
   Date: 10/22/09
 */
@interface CCSkin : NSObject {
    float buttonAlpha;
}

@property(nonatomic, assign) float buttonAlpha;
@property(nonatomic, readonly) NSString *tileset;

+(CCSkin *)instance;

@end
