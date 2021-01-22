//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCMonster.h"
#import "CCLevel.h"
#import "CCTiles.h"
#import "CCSounds.h"

/*!
   Author: StadiaJack
   Date: 10/7/09
 */
@implementation CCMonster

+(CCMonster *)newMonster:(ushort)_code level:(CCLevel *)_level x:(ushort)_x y:(ushort)_y
{
    // determine monster type and dir
    CCMonster *monster = nil;
    NSString *monsterClassName = [[CCTiles instance] monsterClassName:_code];
    if (monsterClassName) {
        monster = [[NSClassFromString(monsterClassName) alloc] initInLevel:_level x:_x y:_y code:_code];
        monster.dir = creatureDirFromCode(_code);
    }
    return monster;
}

-(void)doMove
{
}

-(BOOL)move
{
    if (forceDir != NONE &&
        level.bottomLayer[layerIndex(x, y)] == CLONE_MACHINE && 
        [self blocked:forceDir])
    {
        // if the way off a cloner became blocked since I was cloned
        // then it's as if I never came into existence...
        [level.deadMonsters addObject:self];
    } else if ([super move] && !sliding) {
        [self doMove];
    }
    return NO;
}

-(BOOL)blocked:(CCDirection)d
{
    if ([super blocked:d]) return YES;
    
    short index = layerIndexForPoint(translate(x, y, d));
    byte o = level.topLayer[index];
    if (o == THIEF ||
        o == INVISIBLE_WALL_APPEAR ||
        o == PASS_ONCE ||
        o == GRAVEL ||
        o == EXIT ||
        o == COMPUTER_CHIP ||
        o == DIRT ||
        o == BLUE_BLOCK_FLOOR ||
        o == BLUE_BLOCK_WALL ||
        o == SOCKET ||
        o == BLUE_DOOR ||
        o == RED_DOOR ||
        o == GREEN_DOOR ||
        o == YELLOW_DOOR ||
        o == ICE_SKATES ||
        o == SUCTION_BOOTS ||
        o == FIRE_BOOTS ||
        o == FLIPPERS ||
        isMonster(o))
    {
        return YES;
    }

//    return level.movableLayer[index] != nil && level.movableLayer[index] != level.chip;
    return level.movableLayer[index] != nil;
}

-(void)doBottomLayerCheck:(short)index
{
    // default erase non-floor lower layer
    if (level.bottomLayer[index] != FLOOR) {
        level.bottomLayer[index] = FLOOR;
    }        
}

-(void)moveInDirection:(CCDirection)_dir
{
    if (!level.died && x == level.chip.x && y == level.chip.y && _dir == dirOpposite(level.chip.dir)) {
        level.died = MESSAGE_KILLED;
#ifdef KILLED_DEBUG
        level.died = @"5 - monster move chip coord check";
#endif
    }
    [super moveInDirection:_dir];
}

-(BOOL)checkBomb
{
    short index = layerIndex(x, y);
    byte o = level.topLayer[index];
    if (o == BOMB) {
        level.topLayer[index] = FLOOR;
        [self sound:ccsBomb];
        return YES;
    }
    return NO;
}

/*!
 Subclasses should override if necessary
 */
-(BOOL)checkDead
{
    byte o = level.topLayer[layerIndex(x, y)];
    if (o == WATER) {
        [self sound:ccsSplash];
        return YES;
    } else if (o == FIRE) {
        [self sound:ccsFire];
        return YES;
    }
    return NO;
}

//-(BOOL)postMove
//{
//    if (![super postMove] && moving) {
//        if (x == level.chip.x && y == level.chip.y) {
//            level.died = MESSAGE_KILLED;
//#ifdef KILLED_DEBUG
//            level.died = @"6 - monster midmove chip coord check";
//#endif
//            // sound
//        }
//    }
//    return NO;
//}

-(void)doPostMove:(short)index objectCode:(byte)c
{
    [super doPostMove:index objectCode:c];
    
    if ([self checkBomb] || [self checkDead]) {
        level.movableLayer[index] = nil;
        [level.deadMonsters addObject:self];
    } else if (!level.died && x == level.chip.x && y == level.chip.y) {
        // check for chip
        level.died = MESSAGE_KILLED;
#ifdef KILLED_DEBUG
        level.died = @"1 - monster postmove chip coord check";
#endif
    } else if ((c == CHIP_N) ||
               (c == CHIP_W) ||
               (c == CHIP_S) ||
               (c == CHIP_E) ||
               (c == CHIP_SWIMMING_N) ||
               (c == CHIP_SWIMMING_W) ||
               (c == CHIP_SWIMMING_S) ||
               (c == CHIP_SWIMMING_E))
    {
        // check for ununsed chip
        level.died = MESSAGE_KILLED;
#ifdef KILLED_DEBUG
        level.died = @"10 - monster postmove unused chip coord check";
#endif
    }
}



@end

@implementation CCBug : CCMonster

-(void)doMove
{
    CCDirection d = dirLeft(dir);
    for (int i = 0; i < 4; i++) {
        
        if (![self blocked:d]) {
            [self moveInDirection:d];
            break;
        }
        
        d = dirRight(d);
    }
}

-(BOOL)blocked:(CCDirection)d
{
    if ([super blocked:d]) return YES;
    
    short index = layerIndexForPoint(translate(x, y, d));
    byte o = level.topLayer[index];
    return (o == FIRE);
}

@end

@implementation CCFireball

-(void)doMove
{
    CCDirection d = dir;
    if ([self blocked:d]) {
        d = dirRight(dir);
        if ([self blocked:d]) {
            d = dirLeft(dir);
            if ([self blocked:d]) {
                d = dirOpposite(dir);
                if ([self blocked:d]) {
                    d = NONE;
                }
            }
        }
    }
    
    if (d != NONE) {
        [self moveInDirection:d];
    }        
}

-(BOOL)checkDead
{
    byte o = level.topLayer[layerIndex(x, y)];
    if (o == WATER) {
        [self sound:ccsSplash];
        return YES;
    }
    return NO;
}

-(BOOL)concussionRule
{
    return YES;
}

@end

@implementation CCBall

-(void)doMove
{
    CCDirection d = dir;
    for (int i = 0; i < 2; i++) {
        if (![self blocked:d]) {
            [self moveInDirection:d];
            break;
        }
        
        d = dirOpposite(d);
    }
}

-(BOOL)concussionRule
{
    return YES;
}

@end

@implementation CCTank

-(void)doMove
{
    if (![self blocked:dir]) {
        [self moveInDirection:dir];
    }
}

@end

@implementation CCGlider

-(void)doMove
{
    CCDirection d = dir;
    if ([self blocked:d]) {
        d = dirLeft(dir);
        if ([self blocked:d]) {
            d = dirRight(dir);
            if ([self blocked:d]) {
                d = dirOpposite(dir);
                if ([self blocked:d]) {
                    d = NONE;
                }
            }
        }
    }

    if (d != NONE) {
        [self moveInDirection:d];
    }        
}

-(BOOL)checkDead
{
    byte o = level.topLayer[layerIndex(x, y)];
    if (o == FIRE) {
        [self sound:ccsFire];
        return YES;
    }
    return NO;
}

-(BOOL)concussionRule
{
    return YES;
}

@end

@implementation CCTeeth

-(void)doMove
{
    if (!level.monsterWait) {
        short deltax = x-level.chip.x;
        short deltay = y-level.chip.y;
        CCDirection d = NONE;
        if (abs(deltax) == 0 && abs(deltay) == 0) {
        } else if (abs(deltax) <= abs(deltay)) {
            d = deltay > 0 ? NORTH : SOUTH;
            if ([self blocked:d] && deltax != 0) {
                d = deltax > 0 ? WEST : EAST;
            }
        } else {
            d = deltax > 0 ? WEST : EAST;
            if ([self blocked:d] && deltay != 0) {
                d = deltay > 0 ? NORTH : SOUTH;
            }
        }
        if (d != NONE) {
            if (![self blocked:d]) {
                [self moveInDirection:d];
            } else {
                if (abs(deltax) < abs(deltay)) {
                    d = deltay > 0 ? NORTH : SOUTH;
                } else {
                    d = deltax > 0 ? WEST : EAST;
                }
                dir = d;
                objectCode = [self currentObjectCode];
            }
        }
    }
}

@end

@implementation CCWalker

-(void)doMove
{
    CCDirection d = dir;
    if ([self blocked:d]) d = randomDirection();
    if (![self blocked:d]) [self moveInDirection:d];
}

-(BOOL)blocked:(CCDirection)d
{
    if ([super blocked:d]) return YES;
    
    short index = layerIndexForPoint(translate(x, y, d));
    byte o = level.topLayer[index];
    return (o == FIRE);
}

-(BOOL)concussionRule
{
    return YES;
}

@end

@implementation CCBlob

-(void)doMove
{
    if (!level.monsterWait) {
        CCDirection d = randomDirection();
        if (![self blocked:d]) {
            [self moveInDirection:d];
        }
    }
}

@end

@implementation CCParamecium

-(void)doMove
{
    CCDirection d = dirRight(dir);
    for (int i = 0; i < 4; i++) {
        if (![self blocked:d]) {
            [self moveInDirection:d];
            break;
        }
        
        d = dirLeft(d);
    }
}

@end
