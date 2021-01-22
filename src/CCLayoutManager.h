//  Copyright 2009 StadiaJack. All rights reserved.

#define BEVEL 3
#define LEVEL_INSET 4

enum {
    TAG_INFO_VIEW = 1000,
    TAG_LEVEL_VIEW = 1001,
    TAG_KEYS_VIEW = 1002,
    TAG_BOOTS_VIEW = 1003,
    TAG_MENUBUTTON_VIEW = 1004,
    TAG_DPAD = 1005,
    TAG_BUTTON_IMAGE = 1006,
    TAG_SWIPE_VIEW = 1010
};

typedef enum {
    CCLayoutTwoHandsRight = 10,
    CCLayoutTwoHandsLeft = 11,
    CCLayoutOneHand = 12,
    CCLayoutOneHandRight = 13,
    CCLayoutOneHandLeft = 14,
    CCLayoutDPadRight = 15,
    CCLayoutDPadLeft = 16,
    CCLayoutTouchLevel = 17,
    CCLayoutSwipe = 18,
    CCLayoutLandscapeButtons = 19
} CCLayoutType;


@class CCMainView;
@class CCPlayer;

/*!
   Author: StadiaJack
   Date: 11/4/09
 */
@interface CCLayoutManager : NSObject

-(void)layoutView:(CCMainView *)mainView orientation:(UIInterfaceOrientation)orientation player:(CCPlayer *)player;

+(CCLayoutManager *)instance;

@end
