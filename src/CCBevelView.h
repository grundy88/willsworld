//  Copyright 2009 StadiaJack. All rights reserved.

#import "KRGBColor.h"

typedef enum {
    CCBevelSkipTop = 1,
    CCBevelSkipRight = 2,
    CCBevelSkipBottom = 4,
    CCBevelSkipLeft = 8
} CCBevelFlags;

/*!
   Author: StadiaJack
   Date: 10/19/09
 */
@interface CCBevelView : UIView {
    int bevelWidth;
    BOOL raised;
    CCBevelFlags skipFlags;
    KRGBColor fillColor;
}

@property (nonatomic, assign) int bevelWidth;
@property (nonatomic, assign) BOOL raised;
@property (nonatomic, assign) CCBevelFlags skipFlags;
@property (nonatomic, assign) KRGBColor fillColor;

@end
