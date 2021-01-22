//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCChip.h"
#import "CCLevel.h"
#import "CCTiles.h"
#import "CCCommon.h"
#import "CCBlock.h"
#import "CCMonster.h"
#import "CCMainView.h"
#import "CCSounds.h"
#import "CCController.h"

/*!
   Author: StadiaJack
   Date: 10/7/09
 */
@implementation CCChip

@synthesize mainView;
@synthesize playOof;

-(id)initInLevel:(CCLevel *)_level x:(ushort)_x y:(ushort)_y
{
    if (self = [super initInLevel:_level x:_x y:_y]) {
        objectCode = CHIP_S;
        baseCode = CHIP_N;
        onMovableLayer = NO;
        didOverride = NO;
        playOof = YES;
    }
    return self;
}

-(void)start
{
    [super start];
    byte c = level.topLayer[layerIndex(x, y)];
    level.showHint = (c == HINT);
}

-(void)sound:(CCSoundId)soundId
{
    if (soundId == ccsOof) {
        if (!playOof) {
            return;
        }
        playOof = NO;
    }
    CCGameSoundLevel soundLevel = [CCController instance].currentPlayer.settings.gameSoundLevel;
    if (soundLevel >= CCGameSoundsPlayerOnly) {
        [CCSounds sound:soundId];
    }
}

-(BOOL)teleBounce
{
    return YES;
}

-(BOOL)blocked:(CCDirection)d
{
    // edge of map always blocks
    CCPoint p = translate(x, y, d);
    if (p.x < 0 || p.x >= LEVEL_SIZE || p.y < 0 || p.y >= LEVEL_SIZE) {
        [self sound:ccsOof];
        return YES;
    }

    short index = layerIndexForPoint(p);
    byte o = level.movableLayer[index].objectCode;
//    [NSThread sleepForTimeInterval:2];
    if (o == BLOCK) {
        CCBlock *block = (CCBlock *)level.movableLayer[index];
        if (block.moving) {
            [self sound:ccsOof];
            return YES;
//        } else if (block.sliding && block.dir == dirOpposite(d)) {
        } else if (!level.died && block.sliding && [block nextSlideDir] == dirOpposite(d)) {
            level.died = MESSAGE_CRUSHED;
            return NO;
//        } else if (!block.trapped && ![block blocked:dir] && (!block.sliding || block.dir != dirOpposite(dir))) {
        } else if ((!block.trapped || block.releasedFromTrap) && ![block blocked:d]) {
            // need thin wall checks to prevent flick from thin wall tile
            ushort index = layerIndex(x, y);
            byte c = level.topLayer[index];
            if (d == NORTH && c == THIN_WALL_N) return YES;
            if (d == WEST && c == THIN_WALL_W) return YES;
            if (d == SOUTH && c == THIN_WALL_S) return YES;
            if (d == EAST && c == THIN_WALL_E) return YES;
            if (d == SOUTH && c == THIN_WALL_SE) return YES;
            if (d == EAST && c == THIN_WALL_SE) return YES;
            
            block.slideDir = NONE;
            block.forceDir = NONE;
            block.trapped = NO;
            [block moveInDirection:d];
            // don't return NO from here, chip blocked checks still need to happen
            // for the flick to work
        } else {
            o = level.topLayer[index];
            if ((block.dir == NORTH && o == ICE_SE && ![block blocked:EAST]) ||
                (block.dir == NORTH && o == ICE_SW && ![block blocked:WEST]) ||
                (block.dir == SOUTH && o == ICE_NE && ![block blocked:EAST]) ||
                (block.dir == SOUTH && o == ICE_NW && ![block blocked:WEST]) ||
                (block.dir == WEST && o == ICE_NE && ![block blocked:NORTH]) ||
                (block.dir == WEST && o == ICE_SE && ![block blocked:SOUTH]) ||
                (block.dir == EAST && o == ICE_NW && ![block blocked:NORTH]) ||
                (block.dir == EAST && o == ICE_SW && ![block blocked:SOUTH]))
            {
                // special case - if the block is on ice and about to turn
                // and the turn is clear, then the block shouldn't bounce
                // chip or get rammed
                // this is to avoid cross-checking
            } else {
                // otherwise if the block is blocked, then make sure it's no 
                // longer sliding
                
                // this is "the ram" - yep this one line is it
                block.sliding = NO;
                
                [self sound:ccsOof];
                return YES;
            }
        }
    }
    
    if ([super blocked:d]) {
        [self sound:ccsOof];
        return YES;
    }
    
    switch (level.topLayer[index]) {
        case INVISIBLE_WALL_APPEAR:
            level.topLayer[index] = WALL;
            [self sound:ccsOof];
            return YES;
            break;
        case RED_DOOR:
            if (level.numRedKeys == 0) {
                [self sound:ccsOof];
                return YES;
            }
            level.numRedKeys--;
            level.topLayer[index] = FLOOR;
            [self sound:ccsDoor];
            break;
        case BLUE_DOOR:
            if (level.numBlueKeys == 0) {
                [self sound:ccsOof];
                return YES;
            }
            level.numBlueKeys--;
            level.topLayer[index] = FLOOR;
            [self sound:ccsDoor];
            break;
        case YELLOW_DOOR:
            if (level.numYellowKeys == 0) {
                [self sound:ccsOof];
                return YES;
            }
            level.numYellowKeys--;
            level.topLayer[index] = FLOOR;
            [self sound:ccsDoor];
            break;
        case GREEN_DOOR:
            if (!level.greenKey) {
                [self sound:ccsOof];
                return YES;
            }
            level.topLayer[index] = FLOOR;
            [self sound:ccsDoor];
            break;
        case SOCKET:
            if (level.chipCount > 0) {
                [self sound:ccsOof];
                return YES;
            }
            level.topLayer[index] = FLOOR;
            [self sound:ccsGate];
            break;
        case BLUE_BLOCK_WALL:
            level.topLayer[index] = WALL;
            [self sound:ccsOof];
            return YES;
            break;
        case CHIP_N:
        case CHIP_W:
        case CHIP_S:
        case CHIP_E:
        case CHIP_SWIMMING_N:
        case CHIP_SWIMMING_W:
        case CHIP_SWIMMING_S:
        case CHIP_SWIMMING_E:
            [self sound:ccsOof];
            return YES;
            break;
        case COMPUTER_CHIP:
            level.topLayer[index] = FLOOR;
            level.drawOverride[index] = COMPUTER_CHIP;
            if (level.chipCount > 0) level.chipCount--;
            [self sound:ccsCoin];
            break;
        case DIRT:
            level.topLayer[index] = FLOOR;
            level.drawOverride[index] = DIRT;
            break;
        case FIRE_BOOTS:
            level.fireBoots = YES;
            level.topLayer[index] = FLOOR;
            level.drawOverride[index] = FIRE_BOOTS;
            [self sound:ccsFootwear];
            break;
        case ICE_SKATES:
            level.iceSkates = YES;
            level.topLayer[index] = FLOOR;
            level.drawOverride[index] = ICE_SKATES;
            [self sound:ccsFootwear];
            break;
        case FLIPPERS:
            level.flippers = YES;
            level.topLayer[index] = FLOOR;
            level.drawOverride[index] = FLIPPERS;
            [self sound:ccsFootwear];
            break;
        case SUCTION_BOOTS:
            level.suctionBoots = YES;
            level.topLayer[index] = FLOOR;
            level.drawOverride[index] = SUCTION_BOOTS;
            [self sound:ccsFootwear];
            break;
    }

    
    return NO;
}

-(BOOL)slidesOn:(byte)code
{
    if (!level.iceSkates &&
        (code == ICE ||
        code == ICE_NE ||
        code == ICE_NW ||
        code == ICE_SE ||
        code == ICE_SW))
    {
        return YES;
    }
    if (!level.suctionBoots &&
        (code == FORCE_N ||
        code == FORCE_W ||
        code == FORCE_S ||
        code == FORCE_E ||
        code == FORCE_RANDOM))
    {
        return YES;
    }
    return NO;
}

-(BOOL)slideOverride:(byte)code
{
    CCDirection d = [mainView getControlDir:YES];
    BOOL ret = NO;
    if (level.movePhase == 0 && d != NONE && !didOverride) {
        CCDirection floorDir = [[CCTiles instance] dirFromFloor:code];
        if (floorDir != NONE) {
//            CCDirection lastFloorDir = [[CCTiles instance] dirFromFloor:lastCode];
//            // override if control dir is perpendicular to force dir
//            // and current dir is equal to force dir or "special override"
//            // special = coming off perpendicular sliding (boosting?)
//            BOOL specialOverride = (lastCode == ICE 
//                                    || lastCode == ICE_NE 
//                                    || lastCode == ICE_SE
//                                    || lastCode == ICE_NW
//                                    || lastCode == ICE_SW
//                                    || lastCode == FORCE_RANDOM
//                                    || lastCode == NONE);
//            if (!specialOverride) {
//                specialOverride = dirIsPerpendicular(lastFloorDir, floorDir) ||
//                                lastFloorDir == dirOpposite(floorDir);
//            }
//
//            ret = dirIsPerpendicular(d, floorDir) && 
//                    ((lastFloorDir != NONE) || (dir == NONE)) &&
//                    ((dir == floorDir) || specialOverride);
            // override if control dir is perpendicular to force dir
            // and last move was a slide (or the first move of the level)
            ret = dirIsPerpendicular(d, floorDir) && (didSlide || dir == NONE);
        } else if (code == FORCE_RANDOM)  {
            ret = YES;
        }

        if (!ret) {
            // no override, throw away control dir
            [mainView getControlDir:NO];
        }
    }
    didOverride = ret;
    return ret;
    
//    NSLog(@"------- slideoverride %s dir: %d controldir: %d code: %02x", didOverride?"yes":"no", dir, d, code);
//    if (!didOverride && level.movePhase == 0 && d != NONE) {
//        BOOL ret = NO;
//        if (code == FORCE_N && dirIsPerpendicular(d, NORTH)) ret = YES;
//        if (code == FORCE_W && dirIsPerpendicular(d, WEST)) ret = YES;
//        if (code == FORCE_S && dirIsPerpendicular(d, SOUTH)) ret = YES;
//        if (code == FORCE_E && dirIsPerpendicular(d, EAST)) ret = YES;
//        if (code == FORCE_RANDOM) ret = YES;
//        if (ret) {
//            didOverride = YES;
//            return YES;
//        }
//    }
//    didOverride = NO;
//    return NO;
}

-(BOOL)move
{
    if (trapped) {
        CCDirection d = [mainView getControlDir];
        if (d != NONE) {
//        if (mainView.buttonDir || mainView.buttonQueue.count > 0) {
//            CCDirection d;
//            if (mainView.buttonDir) {
//                d = mainView.buttonDir;
//            } else {
//                d = [[mainView.buttonQueue objectAtIndex:0] intValue];
//            }
//            [mainView removeButtonDir:d];
////            if (mainView.buttonQueue.count > 0) [mainView.buttonQueue removeObjectAtIndex:0];
            
            dir = d;
            objectCode = [self currentObjectCode];
            lastMove = [NSDate timeIntervalSinceReferenceDate];
        }
    }
    
    // the next two lines will pop control moves
    // even during sliding, so they won't buffer up
    if (!moving) {
        if ([super move]) {
            // if buttonStack has 2
            //  and [0] move is toward a block
            //  and [1] move is not blocked
            //  then slap the block
            // else regular getControlDir move
            if (mainView.buttonStack[1] != NONE && mainView.buttonStack[2] == NONE) {
                CCDirection slapDir = mainView.buttonStack[0];
                CCDirection moveDir = mainView.buttonStack[1];
                if (slapDir == dir) {
                    slapDir = mainView.buttonStack[1];
                    moveDir = mainView.buttonStack[0];
                }
                CCMovable *movable = level.movableLayer[layerIndexForPoint(translate(x, y, slapDir))];
                if (movable.objectCode == BLOCK) {
                    if (![self blocked:moveDir]) {
                        dir = moveDir;
                        [mainView removeButtonDir:slapDir];
                        [mainView removeDirFromQueue:slapDir];
                        [self moveInDirection:dir];
                        movable.forceDir = slapDir;
                        lastMove = [NSDate timeIntervalSinceReferenceDate];
                        return NO;
                    }
                }
            }
            
            CCDirection d = [mainView getControlDir];
//#ifdef BUTTON_DEBUG
//        printf("**** chip move\n");
//#endif
            // this will buffer up control moves even during sliding
            //CCDirection d = [mainView getControlDir];
            if (d != NONE) {
                
                dir = d;
                objectCode = [self currentObjectCode];

                if (![self blocked:dir]) {
                    [self moveInDirection:dir];
                }

                lastMove = [NSDate timeIntervalSinceReferenceDate];
            }
        }
    }
    return NO;
}

-(void)moveInDirection:(CCDirection)_dir
{
//    short index = layerIndexForPoint(translate(x, y, _dir));
//    if ([level.movableLayer[index] isKindOfClass:[CCMonster class]]) {
//        level.died = MESSAGE_KILLED;
//#ifdef KILLED_DEBUG
//        level.died = @"8 - chip moveInDirection movable layer check";
//#endif
//        // sound
//    }
    short index = layerIndex(x, y);
    lastCode = level.topLayer[index];
//    didOverride = NO;
    if (!level.died && [level.movableLayer[index] isKindOfClass:[CCMonster class]]) {
        CCMovable *monster = level.movableLayer[index];
        if (monster.x == x && monster.y == y && monster.dir == dirOpposite(dir)) {
            level.died = MESSAGE_KILLED;
#ifdef KILLED_DEBUG
            level.died = @"8 - chip moveInDirection movable layer check";
#endif
        }
    }
    
    lastMove = [NSDate timeIntervalSinceReferenceDate];
    
    didSlide = sliding;
    [super moveInDirection:_dir];
}

-(void)doPostMove:(short)index objectCode:(byte)c
{
#if BUTTON_DEBUG == 1
    printf("**** chip post move\n");
#endif
    [super doPostMove:index objectCode:c];
    
    switch (c) {
        case WATER:
            if (!level.flippers) {
                level.topLayer[index] = DROWNING_CHIP;
                level.died = MESSAGE_DROWNED;
                level.chip.objectCode = 0;
                [self sound:ccsSplash];
            }
            // sound
            break;
        case FIRE:
            if (!level.fireBoots) {
                level.topLayer[index] = BURNED_CHIP;
                level.died = MESSAGE_BURNED;
                level.chip.objectCode = 0;
                [self sound:ccsFire];
            }
            // sound
            break;
        case EXIT:
            level.topLayer[index] = CHIP_IN_EXIT;
            level.exited = YES;
            level.chip.objectCode = 0;
            // sound
            break;
        case PASS_ONCE:
            level.topLayer[index] = WALL;
            [self sound:ccsPopup];
            break;
        case THIEF:
            if (level.fireBoots || level.iceSkates || level.flippers || level.suctionBoots) {
                [self sound:ccsThief];
            }
            level.fireBoots = NO;
            level.iceSkates = NO;
            level.flippers = NO;
            level.suctionBoots = NO;
            break;
//        case COMPUTER_CHIP:
//            level.topLayer[index] = FLOOR;
//            if (level.chipCount > 0) level.chipCount--;
//            [self sound:ccsCoin];
//            break;
//        case DIRT:
//            level.topLayer[index] = FLOOR;
//            break;
        case RED_KEY:
            level.numRedKeys++;
            level.topLayer[index] = FLOOR;
            [self sound:ccsKey];
            break;
        case BLUE_KEY:
            level.numBlueKeys++;
            level.topLayer[index] = FLOOR;
            [self sound:ccsKey];
            break;
        case YELLOW_KEY:
            level.numYellowKeys++;
            level.topLayer[index] = FLOOR;
            [self sound:ccsKey];
            break;
        case GREEN_KEY:
            level.greenKey = YES;
            level.topLayer[index] = FLOOR;
            [self sound:ccsKey];
            break;
//        case FIRE_BOOTS:
//            level.fireBoots = YES;
//            level.topLayer[index] = FLOOR;
//            [self sound:ccsFootwear];
//            break;
//        case ICE_SKATES:
//            level.iceSkates = YES;
//            level.topLayer[index] = FLOOR;
//            [self sound:ccsFootwear];
//            break;
//        case FLIPPERS:
//            level.flippers = YES;
//            level.topLayer[index] = FLOOR;
//            [self sound:ccsFootwear];
//            break;
//        case SUCTION_BOOTS:
//            level.suctionBoots = YES;
//            level.topLayer[index] = FLOOR;
//            [self sound:ccsFootwear];
//            break;
        case BOMB:
            level.died = MESSAGE_EXPLODED;
            [self sound:ccsBomb];
            break;
        case BLUE_BLOCK_FLOOR:
            level.topLayer[index] = FLOOR;
            break;
    }

//    for (CCMonster *monster in level.monsters) {
//        if (monster.x == x && monster.y == y) {
//            level.died = MESSAGE_KILLED;
//#ifdef KILLED_DEBUG
//            level.died = @"3 - chip postmove monster check";
//#endif
//            // sound
//            return;
//        }
//    }
    
//    for (CCBlock *block in level.blocks) {
//        if (block.x == x && block.y == y) {
//            level.died = MESSAGE_CRUSHED;
////            level.died = @"3.5 - chip postmove block check";
//            // sound
//            return;
//        }
//    }
    
    if (!level.died && c != WATER && [level.movableLayer[index] isKindOfClass:[CCMonster class]]) {
        level.died = MESSAGE_KILLED;
#ifdef KILLED_DEBUG
        level.died = @"9 - chip postmove monster check";
#endif
        return;
    }
    
    if (!level.died && isMonster(c)) {
        level.died = MESSAGE_KILLED;
#ifdef KILLED_DEBUG
        level.died = @"4 - chip postmove objectcode check";
#endif
        return;
    }        

    level.showHint = (c == HINT);

    // if buttonStack has 2
    //  and [0] move is toward a block
    //  and [1] move is not blocked
    //  then slap the block
//    if (mainView.buttonStack[1] != NONE && mainView.buttonStack[2] == NONE) {
//        CCMovable *movable = level.movableLayer[layerIndexForPoint(translate(x, y, mainView.buttonStack[1]))];
////        NSLog(@"!!!!!!!!!! 111 %s %s", dirName(mainView.buttonStack[0]), dirName(mainView.buttonStack[1]));
//        if (movable.objectCode == BLOCK) {
//        }
//    }
    
//    [level report];
}

/*
 for tiles hidden under floor (including items logically on the floor - blocks, keys, shoes):
 - stepping on the floor causes the floor to disappear, exposing the hidden tile
 - the now exposed tile has no immediate effect (on the current turn), with the following exceptions:
   - exit - ends level
   - trap with no button - traps chip
  - anything under a block, it works immediately 
 - the exception is a clone machine - it does not get exposed, acts like an invisible wall
 - if a monster steps on this tile, the hidden tile is removed
 - monster on the bottom layer never moves, but can still kill once exposed
 - toggle wall on the bottom layer never toggles
 - teleport on the bottom layer never works
 - buttons on the bottom layer do work
 - promoted blocks should get added to the block list
*/
-(void)doBottomLayerCheck:(short)index
{
    if (level.topLayer[index] == WATER && level.flippers) {
        level.bottomLayer[index] = FLOOR;
    } else if (level.topLayer[index] == FLOOR) {
        [self sound:ccsPop];
        level.topLayer[index] = level.bottomLayer[index];
        level.bottomLayer[index] = FLOOR;
        if (level.topLayer[index] == EXIT) {
            level.topLayer[index] = CHIP_IN_EXIT;
            level.exited = YES;
            level.chip.objectCode = 0;
        }
    }
}

-(void)checkDirReset
{
    if (dir != SOUTH && [NSDate timeIntervalSinceReferenceDate] - lastMove > 1) {
        dir = SOUTH;
        objectCode = [self currentObjectCode];
    }
}

@end
