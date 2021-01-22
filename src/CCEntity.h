//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCCommon.h"
#import "CCSounds.h"

@class CCLevel;

/*!
   Author: StadiaJack
   Date: 10/7/09
 */
@interface CCEntity : NSObject {
    CCLevel *level;
    ushort x;
    ushort y;
}

@property (nonatomic, assign) ushort x;
@property (nonatomic, assign) ushort y;

-(id)initInLevel:(CCLevel *)_level x:(ushort)_x y:(ushort)_y;

@end

@interface CCControllable : CCEntity {
}
@end

@interface CCTrap : CCControllable {
    BOOL active;
}
@property (nonatomic, assign) BOOL active;
@end

@interface CCMovable : CCEntity {
    byte objectCode;
    BOOL onMovableLayer;
    CCDirection dir;
    BOOL moving;
    short animationFrame;
    int pixelx;
    int pixely;
    BOOL releasedFromTrap;
    BOOL trapped;
    BOOL sliding;
    CCDirection slideDir;
    CCDirection forceDir;
}
@property (nonatomic, assign) byte objectCode;
@property (nonatomic, assign) CCDirection dir;
@property (nonatomic, assign) BOOL moving;
@property (nonatomic, assign) int pixelx;
@property (nonatomic, assign) int pixely;
@property (nonatomic, assign) BOOL releasedFromTrap;
@property (nonatomic, assign) BOOL trapped;
@property (nonatomic, assign) BOOL sliding;
@property (nonatomic, assign) CCDirection slideDir;
@property (nonatomic, assign) CCDirection forceDir;
@property (nonatomic, readonly) BOOL teleBounce;
@property (nonatomic, readonly, getter=isOnscreen) BOOL onScreen;

-(BOOL)blocked:(CCDirection)dir;
-(void)animate;
-(void)align;
-(byte)currentObjectCode;
-(void)start;
-(BOOL)slidesOn:(byte)code;
-(BOOL)slideOverride:(byte)code;
-(CCDirection)nextSlideDir;
-(BOOL)move;
-(void)moveInDirection:(CCDirection)_dir;
-(BOOL)postMove;
-(void)doPostMove:(short)index objectCode:(byte)c;
-(void)teleport;
-(void)doBottomLayerCheck:(short)index;
-(void)sound:(CCSoundId)soundId;

@end

@interface CCCreature : CCMovable {
    byte baseCode;
}

@property (nonatomic, readonly) byte baseCode;

-(id)initInLevel:(CCLevel *)_level x:(ushort)_x y:(ushort)_y code:(byte)_code;

@end
