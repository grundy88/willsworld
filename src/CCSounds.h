
typedef enum {
    ccsClickDown        = 0,
    ccsClickUp          = 1,
    ccsLevelComplete    = 2,
    ccsTimeOver         = 3,
    ccsTeleport         = 4,
    ccsSplash           = 5,
    ccsOof              = 6,
    ccsFire             = 7,
    ccsBomb             = 8,
    ccsCoin             = 9,
    ccsKey              = 10,
    ccsFootwear         = 11,
    ccsThief            = 12,
    ccsDied             = 13,
    ccsGate             = 14,
    ccsDoor             = 15,
    ccsPopup            = 16,
    ccsPop              = 17
} CCSoundId;

/*!
   Author: StadiaJack
   Date: 8/31/08
 */
@interface CCSounds : NSObject {
    BOOL initialized;
}

+(CCSounds *)instance;

+(void)sound:(CCSoundId)soundId;

-(void)playClickDown;
-(void)playClickUp;

@end
