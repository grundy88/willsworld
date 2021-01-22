//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCEntity.h"
#import "CCCommon.h"

/*!
 monster     move        fire    water
 -------------------------------------
 bug         left        bounce  die
 fireball    r, l, b     pass    die
 pink ball   b           die     die
 tank        b           die     die
 glider      l, r, b     die     pass
 teeth       follows     die     die
 walker      random      bounce  die
 blob        random      die     die
 paramecium  right       die     die
 
 Author: StadiaJack
   Date: 10/7/09
 */
@interface CCMonster : CCCreature

+(CCMonster *)newMonster:(ushort)code level:(CCLevel *)_level x:(ushort)_x y:(ushort)_y;

-(void)doMove;
-(BOOL)checkDead;

@end

@interface CCBug : CCMonster
@end

@interface CCFireball : CCMonster
@end

@interface CCBall : CCMonster
@end

@interface CCTank : CCMonster
@end

@interface CCGlider : CCMonster
@end

@interface CCTeeth : CCMonster
@end

@interface CCWalker : CCMonster
@end

@interface CCBlob : CCMonster
@end

@interface CCParamecium : CCMonster
@end

