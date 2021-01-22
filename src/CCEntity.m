//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCEntity.h"
#import "CCLevel.h"
#import "CCTiles.h"
#import "CCCoord.h"
#import "CCCommon.h"
#import "CCBlock.h"
#import "CCSounds.h"
#import "CCController.h"

static short FRAMES_PER_STEP = FRAME_RATE / STEP_RATE;

//#define MOVE_RATE ((float)TILE_SIZE / ((float)FRAME_RATE / (float)STEP_RATE))
//#define SLIDE_RATE (TILE_SIZE / (FRAME_RATE / (STEP_RATE * 2)))

/*!
   Author: StadiaJack
   Date: 10/7/09
 */
@implementation CCEntity

@synthesize x;
@synthesize y;

-(id)initInLevel:(CCLevel *)_level x:(ushort)_x y:(ushort)_y
{
    if (self = [super init]) {
        level = _level;
        x = _x;
        y = _y;
    }
    return self;
}

@end

@implementation CCControllable
@end

@implementation CCTrap

@synthesize active;

-(id)initInLevel:(CCLevel *)_level x:(ushort)_x y:(ushort)_y
{
    if (self = [super initInLevel:_level x:_x y:_y]) {
        active = YES;
    }
    return self;
}

@end

@implementation CCMovable

@synthesize objectCode;
@synthesize dir;
@synthesize moving;
@synthesize pixelx;
@synthesize pixely;
@synthesize releasedFromTrap;
@synthesize trapped;
@synthesize sliding;
@synthesize forceDir;
@dynamic teleBounce;
@synthesize slideDir;
@dynamic onScreen;

-(id)initInLevel:(CCLevel *)_level x:(ushort)_x y:(ushort)_y
{
    if ((self = [super initInLevel:_level x:_x y:_y])) {
        dir = NONE;
        forceDir = NONE;
        moving = NO;
        releasedFromTrap = NO;
        trapped = NO;
        onMovableLayer = YES;
        pixelx = x * TILE_SIZE;
        pixely = y * TILE_SIZE;
    }
    return self;
}

-(BOOL)teleBounce
{
    return NO;
}

-(void)start
{
    byte c = level.topLayer[layerIndex(x, y)];
    sliding = (c == FORCE_N ||
               c == FORCE_W ||
               c == FORCE_S ||
               c == FORCE_E ||
               c == FORCE_RANDOM);
}

-(BOOL)blocked:(CCDirection)d
{
    // thin wall checks
    ushort index = layerIndex(x, y);
    byte c = level.topLayer[index];
    if (d == NORTH && c == THIN_WALL_N) return YES;
    if (d == WEST && c == THIN_WALL_W) return YES;
    if (d == SOUTH && c == THIN_WALL_S) return YES;
    if (d == EAST && c == THIN_WALL_E) return YES;
    if (d == SOUTH && c == THIN_WALL_SE) return YES;
    if (d == EAST && c == THIN_WALL_SE) return YES;
    
    // allow entity to move over ice corner
    // comment to allow stepping over ice corners from within :(
    if (d == SOUTH && (c == ICE_NE || c == ICE_NW)) return YES;
    if (d == NORTH && (c == ICE_SE || c == ICE_SW)) return YES;
    if (d == WEST && (c == ICE_NE || c == ICE_SE)) return YES;
    if (d == EAST && (c == ICE_NW || c == ICE_SW)) return YES;
    
    // neighboring space checks
    CCPoint p = translate(x, y, d);
    if (p.x < 0 || p.x >= LEVEL_SIZE || p.y < 0 || p.y >= LEVEL_SIZE) return YES;
    
    index = layerIndex(p.x, p.y);
    byte o = level.topLayer[index];
    
    if (o == WALL || 
        o == INVISIBLE_WALL_NOAPPEAR ||
        o == CLONE_MACHINE ||
        o == SWITCH_BLOCK_CLOSED ||
        o == CLONE_BLOCK_N ||
        o == CLONE_BLOCK_W ||
        o == CLONE_BLOCK_S ||
        o == CLONE_BLOCK_E ||
        isUnused(o))
    {
        return YES;
    }
    
    if (level.bottomLayer[index] == CLONE_MACHINE) return YES;

    if (d == SOUTH && (o == ICE_SE || o == ICE_SW)) return YES;
    if (d == NORTH && (o == ICE_NE || o == ICE_NW)) return YES;
    if (d == WEST && (o == ICE_NW || o == ICE_SW)) return YES;
    if (d == EAST && (o == ICE_NE || o == ICE_SE)) return YES;

    if (d == NORTH && o == THIN_WALL_S) return YES;
    if (d == WEST && o == THIN_WALL_E) return YES;
    if (d == SOUTH && o == THIN_WALL_N) return YES;
    if (d == EAST && o == THIN_WALL_W) return YES;
    if (d == NORTH && o == THIN_WALL_SE) return YES;
    if (d == WEST && o == THIN_WALL_SE) return YES;

    if (o == SWITCH_BLOCK_CLOSED ||
        o == CLONE_BLOCK_N ||
        o == CLONE_BLOCK_W ||
        o == CLONE_BLOCK_S ||
        o == CLONE_BLOCK_E ||
        o == BLOCK)
    {
        return YES;
    }

    return NO;
}

-(void)animate
{
    if (moving) {
        animationFrame++;
        if (sliding) animationFrame++;
        int pixels = animationFrame * TILE_SIZE * STEP_RATE / FRAME_RATE;
        switch (dir) {
            case NORTH:
                pixely = (y+1)*TILE_SIZE - pixels;
                break;
            case SOUTH:
                pixely = (y-1)*TILE_SIZE + pixels;
                break;
            case EAST:
                pixelx = (x-1)*TILE_SIZE + pixels;
                break;
            case WEST:
                pixelx = (x+1)*TILE_SIZE - pixels;
                break;
        }
//        if (self == level.chip) NSLog(@"moved %d by %d to %d,%d", dir, pixels, pixelx, pixely);
    }
}

-(void)align
{
    pixelx = x*TILE_SIZE;
    pixely = y*TILE_SIZE;
}

-(byte)currentObjectCode
{
    return objectCode;
}

-(BOOL)slidesOn:(byte)code
{
    return code == ICE ||
        code == ICE_NE ||
        code == ICE_NW ||
        code == ICE_SE ||
        code == ICE_SW ||
        code == FORCE_N ||
        code == FORCE_W ||
        code == FORCE_S ||
        code == FORCE_E ||
        code == FORCE_RANDOM || 
        (code == TRAP && sliding);
}

-(BOOL)slideOverride:(byte)code
{
    return NO;
}

-(CCDirection)nextSlideDir
{
    // set and return next sliding dir
    byte o = level.topLayer[layerIndex(x, y)];
    slideDir = dir;
    if (o == ICE_SE) {
        slideDir = (dir == NORTH) ? EAST : SOUTH;
    } else if (o == ICE_SW) {
        slideDir = (dir == NORTH) ? WEST : SOUTH;
    } else if (o == ICE_NE) {
        slideDir = (dir == SOUTH) ? EAST : NORTH;
    } else if (o == ICE_NW) {
        slideDir = (dir == SOUTH) ? WEST : NORTH;
    } else if (o == FORCE_N) {
        slideDir = NORTH;
    } else if (o == FORCE_W) {
        slideDir = WEST;
    } else if (o == FORCE_S) {
        slideDir = SOUTH;
    } else if (o == FORCE_E) {
        slideDir = EAST;
    } else if (o == FORCE_RANDOM) {
        slideDir = randomDirection();
    }
    return slideDir;
}

-(BOOL)concussionRule
{
    return NO;
}

-(BOOL)move
{
    if (moving) return NO;
    if (trapped && releasedFromTrap) {
        // removing the concussion rule - now untrapped monsters will always go free
//        if (![self concussionRule] || ![self blocked:dir]) {
            trapped = NO;
//        }
    } else {
        short index = layerIndex(x, y);
        byte c = level.topLayer[index];
        if (c == TRAP) {
            trapped = level.traps[index].active;
        }
    }
    if (trapped) return NO;
    if (forceDir != NONE) {
        if (![self blocked:forceDir]) {
            [self moveInDirection:forceDir];
        }
        forceDir = NONE;
        slideDir = NONE;
        return NO;
    }
    if (sliding) {
        byte o = level.topLayer[layerIndex(x, y)];
        BOOL bounce = (o == ICE_SE ||
                       o == ICE_SW ||
                       o == ICE_NE ||
                       o == ICE_NW ||
                       o == ICE);
        if (slideDir == NONE) [self nextSlideDir];
    
//        BOOL m = YES;
//        if ([self blocked:slideDir]) {
//            if (bounce) {
//                slideDir = dirOpposite(dir);
//                if ([self blocked:slideDir]) {
//                    m = NO;
//                }
//            } else {
//                m = NO;
//            }
//        }
//        objectCode = [self currentObjectCode];
//        if (m && ![self slideOverride:o]) {
//            [self moveInDirection:slideDir];
//            slideDir = NONE;
//            return NO;
//        }
        
        if (![self slideOverride:o]) {
            BOOL m = YES;
            if ([self blocked:slideDir]) {
                if (bounce) {
                    slideDir = dirOpposite(dir);
                    if ([self blocked:slideDir]) {
                        m = NO;
                    }
                } else {
                    m = NO;
                }
            }
            objectCode = [self currentObjectCode];
            if (m) {
                [self moveInDirection:slideDir];
                slideDir = NONE;
                return NO;
            }
        }

        dir = slideDir;
        slideDir = NONE;
        return YES;
    }
    return YES;
}

-(void)moveInDirection:(CCDirection)_dir
{
    if (onMovableLayer && level.movableLayer[layerIndex(x, y)] == self) level.movableLayer[layerIndex(x, y)] = nil;
    // reactivate trap as entity moves off
    short index = layerIndex(x, y);
    byte p = level.topLayer[index];
    if (p == BROWN_BUTTON) {
        CCCoord *coord = level.buttons[index];
        if (coord) [level activateTrapAtPoint:coord.point];
    }
    releasedFromTrap = NO;
    CCPoint dest = translate(x, y, _dir);
    x = dest.x;
    y = dest.y;
    dir = _dir;
    objectCode = [self currentObjectCode];
    moving = YES;
    animationFrame = 0;
    // do slow down at slide end
    sliding = [self slidesOn:level.topLayer[layerIndex(x, y)]];
    // do not slow down at slide end
//    sliding = sliding || [self slidesOn:level.topLayer[layerIndex(x, y)]];
    if (onMovableLayer) level.movableLayer[layerIndex(x, y)] = self;
}

-(BOOL)postMove
{
    if (moving && animationFrame >= FRAMES_PER_STEP) {
        short index = layerIndex(x, y);
        byte c = level.topLayer[index];

        [self doPostMove:index objectCode:c];
        
        if (level.bottomLayer[index] != FLOOR && level.bottomLayer[index] != CLONE_MACHINE) {
            [self doBottomLayerCheck:index];
        }
        
        sliding = [self slidesOn:c];
        moving = NO;
        
        return YES;
    }
    return NO;
}

-(void)doPostMove:(short)index objectCode:(byte)c
{
//    if (c == TRAP) {
//        trapped = level.traps[index].active;
//    }
    
    if (c == TELEPORT) {
        [self sound:ccsTeleport];
        [self teleport];
    }
    
    if (c == GREEN_BUTTON) {
        [self sound:ccsClickUp];
        [level toggleWalls];
    }

    if (c == BLUE_BUTTON) {
        [self sound:ccsClickUp];
        [level toggleTanks];
    }
    
    if (c == RED_BUTTON) {
        [self sound:ccsClickUp];
        CCCoord *coord = level.buttons[index];
        if (coord) [level triggerCloneAtPoint:coord.point];
    }

    if (c == BROWN_BUTTON) {
        [self sound:ccsClickUp];
        CCCoord *coord = level.buttons[index];
        if (coord) [level releaseTrapAtPoint:coord.point];
    }
    
    CCPoint lastPoint = translate(x, y, dirOpposite(dir));
    short lastIndex = layerIndexForPoint(lastPoint);
    byte p = level.topLayer[lastIndex];
//    if (p == BROWN_BUTTON) {
//        CCCoord *coord = level.buttons[lastIndex];
//        if (coord) [level activateTrapAtPoint:coord.point];
//    } else if (p == BLOCK) {
    if (p == BLOCK) {
        // case when an entity starts on top of a block
        level.topLayer[lastIndex] = FLOOR;
        CCBlock *block = [[CCBlock alloc] initInLevel:level x:lastPoint.x y:lastPoint.y];
        level.movableLayer[layerIndex(block.x, block.y)] = block;
        [level.newBlocks addObject:block];
        [block release];
    }
}

-(void)teleport
{
    short index = layerIndex(x, y);
    if (onMovableLayer && level.movableLayer[index] == self) level.movableLayer[index] = nil;
    short i = index;
    BOOL done = FALSE;
    while (!done) {
        i--;
        if (i < 0) i = LEVEL_SIZE*LEVEL_SIZE-1;
        
        CCPoint p = pointForLayerIndex(i);
        x = p.x;
        y = p.y;
        if (i == index) {
            // no valid teleport found
            if (![self blocked:dir]) {
                forceDir = dir;
            } else if (self.teleBounce) {
                forceDir = dirOpposite(dir);
            }
            done = YES;
        } else if (level.topLayer[i] == TELEPORT) {
            if (!level.movableLayer[i] && ![self blocked:dir]) {
                forceDir = dir;
                done = YES;
            }
        }
    }
    if (onMovableLayer) level.movableLayer[i] = self;
    [self align];
}

-(void)doBottomLayerCheck:(short)index
{
}

-(BOOL)isOnscreen
{
    int xmin = MAX(level.chip.x-NUM_VIEW_TILES/2, 0);
    int ymin = MAX(level.chip.y-NUM_VIEW_TILES/2, 0);
    int xmax = MIN(level.chip.x+NUM_VIEW_TILES/2, LEVEL_SIZE-1);
    int ymax = MIN(level.chip.y+NUM_VIEW_TILES/2, LEVEL_SIZE-1);
    return ((x >= xmin) && (x <= xmax) && (y >= ymin) && (y <= ymax));
}

-(void)sound:(CCSoundId)soundId
{
    CCGameSoundLevel soundLevel = [CCController instance].currentPlayer.settings.gameSoundLevel;
    BOOL play = (soundLevel > CCGameSoundsPlayerOnly);
    if (play && soundLevel == CCGameSoundsOnscreen) {
        play = self.isOnscreen;
    }
    if (play) {
        [CCSounds sound:soundId];
    }
}

@end

@implementation CCCreature

@synthesize baseCode;

-(id)initInLevel:(CCLevel *)_level x:(ushort)_x y:(ushort)_y code:(byte)_code
{
    if (self = [super initInLevel:_level x:_x y:_y]) {
        objectCode = _code;
        baseCode = (((_code - 0x40) / 4) * 4) + 0x40;
    }
    return self;
}

-(byte)currentObjectCode
{
    byte code = baseCode;
    switch (dir) {
        case WEST:
            code += 1;
            break;
        case SOUTH:
            code += 2;
            break;
        case EAST:
            code += 3;
            break;
    }
    return code;
}

@end
