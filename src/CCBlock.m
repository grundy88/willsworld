//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCBlock.h"
#import "CCTiles.h"
#import "CCLevel.h"
#import "CCSounds.h"

/*!
   Author: StadiaJack
   Date: 10/9/09
 */
@implementation CCBlock

-(id)initInLevel:(CCLevel *)_level x:(ushort)_x y:(ushort)_y
{
    if (self = [super initInLevel:_level x:_x y:_y]) {
        objectCode = BLOCK;
    }
    return self;
}

-(BOOL)blocked:(CCDirection)d
{
    if ([super blocked:d]) return YES;
    
    short index = layerIndexForPoint(translate(x, y, d));
    byte o = level.topLayer[index];
    if (o == THIEF ||
        o == INVISIBLE_WALL_APPEAR ||
        o == PASS_ONCE ||
        o == COMPUTER_CHIP ||
        o == DIRT ||
        o == BLUE_BLOCK_FLOOR ||
        o == BLUE_BLOCK_WALL ||
        o == SOCKET ||
        o == BLUE_DOOR ||
        o == RED_DOOR ||
        o == GREEN_DOOR ||
        o == YELLOW_DOOR ||
        isMonster(o)) 
    {
        return YES;
    }
    
//    return level.movableLayer[index] != nil && level.movableLayer[index] != level.chip;
    return level.movableLayer[index] != nil;
}

-(BOOL)move
{
    if (forceDir != NONE &&
        level.bottomLayer[layerIndex(x, y)] == CLONE_MACHINE && 
        [self blocked:forceDir])
    {
        // if the way off a cloner became blocked since I was cloned
        // then it's as if I never came into existence...
        [level.deadBlocks addObject:self];
        return NO;
    }

//    // blocks slide off traps when released
//    // not doing this, it's a lynx thing
//    if (trapped && releasedFromTrap) {
//        trapped = NO;
//        if (![self blocked:dir]) {
//            [self moveInDirection:dir];
//        }
//        return NO;
//    }
    
    return [super move];
}

-(void)doBottomLayerCheck:(short)index
{
    if (level.topLayer[index] == FLOOR) {
        level.topLayer[index] = level.bottomLayer[index];
        level.bottomLayer[index] = FLOOR;
    }
}

-(BOOL)postMove
{
    if (![super postMove] && moving) {
        if (!level.died && x == level.chip.x && y == level.chip.y) {
            level.died = MESSAGE_CRUSHED;
//            level.died = @"7 - block midmove chip coord check";
            // sound
        }
    }

//    // a block that moves onto an inactive trap keeps moving
//    // not doing this, it's a lynx thing and in general anything
//    // that moves onto an inactive trap force slides in that dir
//    CCTrap *trap = level.traps[layerIndex(x, y)];
//    if (trap && !trap.active) {
//        if (![self blocked:dir]) {
//            forceDir = dir;
////            [self moveInDirection:dir];
//        }
//    }
    
    return NO;
}

-(void)doPostMove:(short)index objectCode:(byte)c
{
    [super doPostMove:index objectCode:c];

    if (c == WATER) {
        level.topLayer[index] = DIRT;
        level.movableLayer[index] = nil;
        [level.deadBlocks addObject:self];
        [self sound:ccsSplash];
        return;
    }
    
    if (c == BOMB) {
        level.topLayer[index] = FLOOR;
        level.movableLayer[index] = nil;
        [level.deadBlocks addObject:self];
        [self sound:ccsBomb];
        return;
    }

    if (!level.died && x == level.chip.x && y == level.chip.y) {
        level.died = MESSAGE_CRUSHED;
        level.chip.objectCode = 0;
    }
    if (!level.died &&
        (c == CHIP_N ||
         c == CHIP_W ||
         c == CHIP_S ||
         c == CHIP_E ||
         c == CHIP_SWIMMING_N ||
         c == CHIP_SWIMMING_W ||
         c == CHIP_SWIMMING_S ||
         c == CHIP_SWIMMING_E))
    {
        level.died = MESSAGE_CRUSHED;
    }

    CCPoint lastPoint = translate(x, y, dirOpposite(dir));
    short lastIndex = layerIndexForPoint(lastPoint);
    byte p = level.topLayer[lastIndex];
    if (p == TELEPORT && c == TRAP) {
        // case when block teleports onto a trap,
        // should slide off when released
        sliding = YES;
    }
}

@end
