
#import "CCDataReader.h"
#import "CCTiles.h"
#import "CCEntity.h"
#import "CCMonster.h"
#import "CCBlock.h"
#import "CCObjectNames.h"
#import "CCCoord.h"
#import "CCLevelInfo.h"
#import "CCPersistence.h"
#import <CommonCrypto/CommonDigest.h>

#define PRINTLEVEL NO
//#define REPORT

@implementation CCDataReader

#ifdef REPORT
#import "CCObjectNames.h"
int *topReport = NULL;
int *bottomReport = NULL;
#endif

static unsigned long getUnsignedNumberFromBytes(byte *bytes, int numBytes)
{
    // should check if array has < numBytes
    unsigned long ret = 0;
    for (int i = 0; i < numBytes; i++) {
        ret += bytes[i] << (8*i);
    }
    return ret;
}

static unsigned short getUnsignedShortFromBytes(byte *bytes)
{
    return getUnsignedNumberFromBytes(bytes, 2);
}

static unsigned int getUnsignedIntFromBytes(byte *bytes)
{
    return getUnsignedNumberFromBytes(bytes, 4);
}

static unsigned short getUnsignedShort(NSData *data, byte *buf, int start)
{
    [data getBytes:buf range:NSMakeRange(start, 2)];
    return getUnsignedShortFromBytes(buf);
}

static unsigned short getUShort(NSData *data, byte *buf, uint *start)
{
    [data getBytes:buf range:NSMakeRange(*start, 2)];
    (*start) += 2;
    return getUnsignedShortFromBytes(buf);
}

static byte getByte(NSData *data, byte *buf, uint *start)
{
    [data getBytes:buf range:NSMakeRange(*start, 1)];
    (*start) += 1;
    return buf[0];
}

static NSString *getString(NSData *data, byte *buf, uint *start)
{
    byte length = getByte(data, buf, start);
    [data getBytes:buf range:NSMakeRange(*start, length)];
    (*start) += length;
    return [[[NSString alloc] initWithBytes:buf length:length-1 encoding:NSASCIIStringEncoding] autorelease];
}

static NSString *getPasswordString(NSData *data, byte *buf, uint *start)
{
    byte length = getByte(data, buf, start);
    [data getBytes:buf range:NSMakeRange(*start, length)];
    (*start) += length;
    for (int i = 0; i < length-1; i++) {
        buf[i] ^= 0x99;
    }
    return [[[NSString alloc] initWithBytes:buf length:length-1 encoding:NSASCIIStringEncoding] autorelease];
}

static unsigned long getNumber(NSData *data, byte *buf, int start, int numBytes)
{
    [data getBytes:buf range:NSMakeRange(start, numBytes)];
    return getUnsignedNumberFromBytes(buf, numBytes);
}

static void processObject(CCLevel *level, byte objectCode, ushort *index, ushort *x, ushort *y, BOOL top)
{
    if (PRINTLEVEL) printf("%.2x ", objectCode);
#ifdef REPORT
    int *report = top ? topReport : bottomReport;
    report[objectCode]++;
#endif

    if (objectCode >= 0x6C && objectCode <= 0x6F) {
        // CHIP
        if (top) {
            if (level.chip) {
                NSLog(@"WARNING: multiple Chips, ignoring %d,%d", objectCode, level.chip.x, level.chip.y);
                short prevChipIndex = layerIndex(level.chip.x, level.chip.y);
                level.topLayer[prevChipIndex] = CHIP_S;
//                level.movableLayer[prevChipIndex] = nil;
//                [level.chip release];
                level.chip = nil;
            }
            CCChip *chip = [[CCChip alloc] initInLevel:level x:*x y:*y];
            level.chip = chip;
            [chip release];
//            level.movableLayer[*index] = level.chip;
            level.topLayer[*index] = FLOOR;
            level.chip.objectCode = CHIP_S;
        } else {
            NSLog(@"WARNING: Chip on bottom layer at %d,%d", *x, *y);
            level.bottomLayer[*index] = CHIP_S;
        }
        
    } else if (objectCode == BLOCK) {
        if (top) {
            CCBlock *block = [[CCBlock alloc] initInLevel:level x:*x y:*y];
            level.movableLayer[*index] = block;
            level.topLayer[*index] = FLOOR;
            [level.blocks addObject:block];
            [block release];
        } else {
            NSLog(@"WARNING: block on bottom layer at %d,%d", *x, *y);
            level.bottomLayer[*index] = BLOCK;
        }
        
    } else if (objectCode == TRAP) {
        if (top) {
            CCTrap *trap = [[CCTrap alloc] initInLevel:level x:*x y:*y];
            level.traps[*index] = trap;
            level.topLayer[*index] = TRAP;
        } else {
            NSLog(@"WARNING: trap on bottom layer at %d,%d", *x, *y);
            level.bottomLayer[*index] = TRAP;
        }
        
    } else {
        byte *layer = top ? level.topLayer : level.bottomLayer;
        layer[*index] = objectCode;
    }

    if (!top && [level.movableLayer[*index] isKindOfClass:[CCBlock class]]) {
        // anything under a block (except another block) gets promoted to the top
        if (objectCode != BLOCK) {
            level.topLayer[*index] = objectCode;
        }
        level.bottomLayer[*index] = FLOOR;
    }

    if (objectCode == TRAP) {
        CCTrap *trap = [[CCTrap alloc] initInLevel:level x:*x y:*y];
        level.traps[*index] = trap;
    }
    
    (*index)++;

    (*x)++;
    if (*x >= LEVEL_SIZE) {
        *x = 0;
        (*y)++;
        if (PRINTLEVEL) printf("\n");
    }
}

static void loadLayer(NSData *data, byte *buf, uint *offset, CCLevel *level, BOOL top)
{
    ushort layerByteCount = getUShort(data, buf, offset);
    uint layerEnd = *offset + layerByteCount;
    ushort x = 0;
    ushort y = 0;
    ushort index = 0;
    
    while (*offset < layerEnd) {
        // get object code
        short objectCode = getByte(data, buf, offset);
        
        if (objectCode >= 0x00 && objectCode <= 0x6F) {
            if (level) processObject(level, objectCode, &index, &x, &y, top);
            
        } else if (objectCode == 0xFF) {
            byte objectCount = getByte(data, buf, offset);
            objectCode = getByte(data, buf, offset);
            for (int i = 0; i < objectCount; i++) {
                if (level) processObject(level, objectCode, &index, &x, &y, top);
            }
            
        } else {
            NSLog(@"ERROR: ignoring unknown object code %x on %s layer at %d,%d", objectCode, top?"top":"bottom", x, y);
            if (level) processObject(level, FLOOR, &index, &x, &y, top);
        }
    }
    
    if (x != 0 || y != 32) {
        NSLog(@"ERROR: did not get %d object for %s layer (x=%d y=%d)", LEVEL_SIZE*LEVEL_SIZE, top?"top":"bottom", x, y);
    }
}

+(NSString *)getMD5:(NSData *)data
{
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5([data bytes], [data length], digest);
    NSString *md5 = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                     digest[0], digest[1], 
                     digest[2], digest[3],
                     digest[4], digest[5],
                     digest[6], digest[7],
                     digest[8], digest[9],
                     digest[10], digest[11],
                     digest[12], digest[13],
                     digest[14], digest[15]];
    return md5;
}

+(CCLevel *)newLevelFromData:(NSData *)data atOffset:(uint *)offset
{
    byte *buf = malloc(sizeof(byte) * 0xFF);
    CCLevel *level = [CCLevel new];
    
    // level byte count
    ushort numBytes = getUShort(data, buf, offset);
    uint levelEnd = (*offset) + numBytes;
    
    // level info
    level.number = getUShort(data, buf, offset);
    level.timeLimit = getUShort(data, buf, offset);
    level.chipCount = getUShort(data, buf, offset);
    
#ifdef DEBUG
    NSLog(@" Level %d", level.number);
    NSLog(@" time limit: %d", level.timeLimit);
    NSLog(@" chip count: %d", level.chipCount);
#endif
    
    // read map detail - top layer
    if (PRINTLEVEL) printf("-- TOP --\n");
    ushort fieldNum = getUShort(data, buf, offset);
    if (fieldNum != 1) {
        NSLog(@"WARNING: unexpected first field num %d", fieldNum);
    }
    uint topLayerOffset = *offset;
    loadLayer(data, buf, offset, level, YES);
    
    // bottom layer
    if (PRINTLEVEL) printf("-- BOTTOM --\n");
    loadLayer(data, buf, offset, level, NO);
    
    numBytes = getUShort(data, buf, offset);
    if (levelEnd != (*offset) + numBytes) {
        NSLog(@"WARNING: end of level check (%d, %d)", levelEnd, ((*offset)+numBytes));
    }
    
    // process rest of fields
    while ((*offset) < levelEnd) {
        byte fieldNum = getByte(data, buf, offset);
        if (fieldNum == 3) {
            // level title
            level.title = getString(data, buf, offset);
#ifdef DEBUG
            NSLog(@" title: '%@'", level.title);
#endif
            
        } else if (fieldNum == 7) {
            // hint
            level.hint = getString(data, buf, offset);
#ifdef DEBUG
            NSLog(@" hint: '%@'", level.hint);
#endif
            
        } else if (fieldNum == 6) {
            // password
            level.password = getPasswordString(data, buf, offset);
#ifdef DEBUG
            NSLog(@" password: '%@'", level.password);
#endif
            
        } else if (fieldNum == 4) {
            // trap controls
            byte trapBytes = getByte(data, buf, offset);
            if (trapBytes % 0x0A != 0) {
                NSLog(@"ERROR: trap bytes not divisible by 0x0A (%d)", trapBytes);
            }
            byte trapCount = trapBytes/0x0A;
//            printf(" %d trap buttons:\n", trapCount);
            for (int i = 0; i < trapCount; i++) {
                ushort buttonx = getUShort(data, buf, offset);
                ushort buttony = getUShort(data, buf, offset);
                ushort trapx = getUShort(data, buf, offset);
                ushort trapy = getUShort(data, buf, offset);
                getUShort(data, buf, offset);
                ushort buttonIndex = layerIndex(buttonx, buttony);
                if (level.topLayer[buttonIndex] == BROWN_BUTTON || level.bottomLayer[buttonIndex] == BROWN_BUTTON) {
                    if (level.topLayer[layerIndex(trapx, trapy)] == TRAP || level.bottomLayer[layerIndex(trapx, trapy)] == TRAP) {
                        CCPoint trapPoint = CCPointMake(trapx, trapy);
                        level.buttons[buttonIndex] = [[CCCoord alloc] initWithPoint:trapPoint];
                        if (level.topLayer[buttonIndex] != BROWN_BUTTON && level.bottomLayer[buttonIndex] == BROWN_BUTTON) {
                            NSLog(@"autoreleasing trap at %d,%d - button on bottom", trapx, trapy);
                            [level releaseTrapAtPoint:trapPoint];
                        }
                        if (level.movableLayer[buttonIndex]) {
                            NSLog(@"autoreleasing trap at %d,%d - button initially pressed", trapx, trapy);
                            [level releaseTrapAtPoint:trapPoint];
                        }
                    } else {
                        NSLog(@"WARNING: button at %d,%d does not trigger a trap on the map at %d,%d", buttonx, buttony, trapx, trapy);
                    }
                } else {
                    NSLog(@"WARNING: button at %d,%d does not correspond to a trap button", buttonx, buttony);
                }
//                printf("  - button at %d,%d controls trap at %d,%d\n", buttonx, buttony, trapx, trapy);
            }
            
        } else if (fieldNum == 5) {
            // clone machine controls
            byte cloneBytes = getByte(data, buf, offset);
            if (cloneBytes % 0x08 != 0) {
                NSLog(@"ERROR: clone bytes not divisible by 0x08 (%d)", cloneBytes);
            }
            byte cloneCount = cloneBytes/0x08;
//            printf(" %d clone buttons:\n", cloneCount);
            for (int i = 0; i < cloneCount; i++) {
                ushort buttonx = getUShort(data, buf, offset);
                ushort buttony = getUShort(data, buf, offset);
                ushort machinex = getUShort(data, buf, offset);
                ushort machiney = getUShort(data, buf, offset);
                ushort buttonIndex = layerIndex(buttonx, buttony);
                if (level.topLayer[buttonIndex] == RED_BUTTON || level.bottomLayer[buttonIndex] == RED_BUTTON) {
                    byte t = level.topLayer[layerIndex(machinex, machiney)];
                    byte b = level.bottomLayer[layerIndex(machinex, machiney)];
                    if (b == CLONE_MACHINE ||
                        t == CLONE_BLOCK_N ||
                        t == CLONE_BLOCK_W ||
                        t == CLONE_BLOCK_S ||
                        t == CLONE_BLOCK_E)
                    {
                        level.buttons[buttonIndex] = [[CCCoord alloc] initWithPoint:CCPointMake(machinex, machiney)];
                    } else {
                        NSLog(@"WARNING: button at %d,%d does not trigger a machine on the map at %d,%d", buttonx, buttony, machinex, machiney);
                    }
                } else {
                    NSLog(@"WARNING: button at %d,%d does not correspond to a clone button on the map", buttonx, buttony);
                }
//                printf("  - button at %d,%d controls clone machine at %d,%d\n", buttonx, buttony, machinex, machiney);
            }
            
        } else if (fieldNum == 10) {
            // monsters
            byte monsterBytes = getByte(data, buf, offset);
            if (monsterBytes % 2 != 0) {
                NSLog(@"ERROR: monster bytes not divisible by 2 (%d)", monsterBytes);
            }
            byte monsterCount = monsterBytes/2;
//            printf(" %d monsters:\n", monsterCount);
            for (int i = 0; i < monsterCount; i++) {
                byte monsterx = getByte(data, buf, offset);
                byte monstery = getByte(data, buf, offset);
                short index = layerIndex(monsterx, monstery);
                byte monsterCode = level.topLayer[index];
                if (monsterCode >= 0x40 && monsterCode <= 0x63) {
                    if (level.bottomLayer[index] != CLONE_MACHINE) {
                        // anything under a monster (except a clone machine) gets promoted to the top
                        level.topLayer[index] = level.bottomLayer[index];
                        level.bottomLayer[index] = FLOOR;
                        CCMonster *monster = [CCMonster newMonster:monsterCode level:level x:monsterx y:monstery];
                        monster.trapped = (level.topLayer[index] == TRAP);
                        level.movableLayer[index] = monster;
//                        level.topLayer[index] = FLOOR;
                        [level.monsters addObject:monster];
                        [monster release];
                    }
//                    printf("  - %s at %d,%d\n", [objectNames[monsterCode] UTF8String], monsterx, monstery);
//                }
//                
//                CCEntity *entity = level.movableLayer[layerIndex(monsterx, monstery)];
//                if ([entity isKindOfClass:[CCMonster class]]) {
//                    CCMonster *monster = (CCMonster *)entity;
//                    short index = layerIndex(monsterx, monstery);
//                    if (level.bottomLayer[index] != CLONE_MACHINE && level.topLayer[index] != TRAP) {
//                        monster.trapped = NO;
//                    }
                } else {
                    NSLog(@"WARNING: no monster at %d,%d", monsterx, monstery);
                }
            }
            
        } else {
            NSLog(@"WARNING: ignoring unknown field num (%d)", fieldNum);
        }
    }

    // anything under Chip gets insta-promoted
    short index = layerIndex(level.chip.x, level.chip.y);
    level.topLayer[index] = level.bottomLayer[index];
    level.bottomLayer[index] = FLOOR;
    
    // Bogus!!!
    // if level name @"PERFECT MATCH" and num = 121 and pass = @"BPYS"
    // and top layer md5 = @"ab1f12918eb7002c165324e6ee7503db"
    if ([level.title isEqualToString:@"PERFECT MATCH"] &&
        (level.number == 121) &&
        [level.password isEqualToString:@"BPYS"])
    {
        ushort topLayerLength = getUnsignedShort(data, buf, topLayerOffset);
        topLayerOffset += 2;
        NSData *layerData = [data subdataWithRange:NSMakeRange(topLayerOffset, topLayerLength)];
        NSString *md5 = [CCDataReader getMD5:layerData];
        if ([md5 isEqualToString:@"ab1f12918eb7002c165324e6ee7503db"]) {
            short fixIndex = layerIndex(3, 19);
            if (level.topLayer[fixIndex] == FORCE_N) {
                level.topLayer[fixIndex] = FLOOR;
                NSLog(@"Original CC level 121 detected and fixed!!!!!!!!!!!!");
            }
        } else if ([md5 isEqualToString:@"ab1f12918eb7002c165324e6ee7503db"]) {
            short fixIndex = layerIndex(30, 6);
            if (level.topLayer[fixIndex] == WALL) {
                level.topLayer[fixIndex] = FLOOR;
                NSLog(@"Original CC level 70 detected and modified!!!!!!!!!!!!");
            }
        }
    }
    // if level name @"NIGHTMARE" and num = 70 and pass = @"GCCG"
    // and top layer md5 = @"07fa27bee899ec3d4537baee19b58bb1"
    else if ([level.title isEqualToString:@"NIGHTMARE"] &&
        (level.number == 70) &&
        [level.password isEqualToString:@"GCCG"])
    {
        ushort topLayerLength = getUnsignedShort(data, buf, topLayerOffset);
        topLayerOffset += 2;
        NSData *layerData = [data subdataWithRange:NSMakeRange(topLayerOffset, topLayerLength)];
        NSString *md5 = [CCDataReader getMD5:layerData];
//        NSLog(@"MD5: %@", md5);
        if ([md5 isEqualToString:@"07fa27bee899ec3d4537baee19b58bb1"]) {
            short fixIndex = layerIndex(30, 6);
            if (level.topLayer[fixIndex] == WALL) {
                level.topLayer[fixIndex] = FLOOR;
                NSLog(@"Original CC level 70 detected and modified!!!!!!!!!!!!");
            }
        }
    }
    
    NSString *title = [level.title stringByReplacingOccurrencesOfString:@"Chip" withString:@"Will"];
    level.title = title;

    if ((*offset) != levelEnd) {
        NSLog(@"ERROR: wrong offset (%d should be %d)", (*offset), levelEnd);
    }
    
#ifdef DEBUG
    NSLog(@"Done!!");
#endif
    
    free(buf);
    
    return level;
}

+(int)getNumLevelsInAsset:(CCPersistedAsset *)asset
{
    NSData *data = [CCPersistence getAssetData:asset ofType:ASSET_TYPE_LEVELPACK];
    byte *buf = malloc(sizeof(byte) * 4);
    unsigned short num = getUnsignedShort(data, buf, 0x04);
    free(buf);
    return num;
}

+(NSArray *)loadLevelListFromData:(NSData *)data error:(NSError **)error
{
    NSMutableArray *levelInfos = [NSMutableArray new];
    byte *buf = malloc(sizeof(byte) * 0xFF);
    uint offset = 0x04;

    @try {
        unsigned short numLevels = getUShort(data, buf, &offset);
    
        while (offset < data.length) {
            
            CCLevelInfo *levelInfo = [CCLevelInfo new];
            
            ushort numBytes = getUShort(data, buf, &offset);
            uint levelEnd = offset + numBytes;
            
            // level info
            getUShort(data, buf, &offset);
            getUShort(data, buf, &offset);
            getUShort(data, buf, &offset);
            
            // read map detail - top layer
            ushort fieldNum = getUShort(data, buf, &offset);
            if (fieldNum != 1) {
                *error = [NSError errorWithDomain:@"CC" 
                                             code:10
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"invalid data file", NSLocalizedDescriptionKey, nil]];
                NSLog(@"CORRUPT - unexpected first field num %d", fieldNum);
            }
            
            // skip layer data
            ushort layerByteCount = getUShort(data, buf, &offset);
            offset += layerByteCount;
            layerByteCount = getUShort(data, buf, &offset);
            offset += layerByteCount;
            
            numBytes = getUShort(data, buf, &offset);
            if (levelEnd != offset + numBytes) {
                *error = [NSError errorWithDomain:@"CC" 
                                             code:11
                                         userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"invalid data file", NSLocalizedDescriptionKey, nil]];
                NSLog(@"CORRUPT - end of level check (%d, %d)", levelEnd, (offset+numBytes));
            }
            
            // process rest of fields
            while (offset < levelEnd) {
                byte fieldNum = getByte(data, buf, &offset);
                if (fieldNum == 3) {
                    // level title
                    levelInfo.title = getString(data, buf, &offset);
//                    offset = levelEnd;

                } else if (fieldNum == 7) {
                    getString(data, buf, &offset);
                    
                } else if (fieldNum == 6) {
                    // password
                    levelInfo.password = getPasswordString(data, buf, &offset);
                    
                } else if (fieldNum == 4) {
                    // trap controls
                    byte trapBytes = getByte(data, buf, &offset);
                    offset += trapBytes;
                    
                } else if (fieldNum == 5) {
                    // clone machine controls
                    byte cloneBytes = getByte(data, buf, &offset);
                    offset += cloneBytes;
                    
                } else if (fieldNum == 10) {
                    // monsters
                    byte monsterBytes = getByte(data, buf, &offset);
                    offset += monsterBytes;

                }
            }
            
            //NSLog(@" - %@", levelInfo.title);
            
            NSString *title = [levelInfo.title stringByReplacingOccurrencesOfString:@"Chip" withString:@"Will"];
            levelInfo.title = title;

            [levelInfos addObject:levelInfo];
            [levelInfo release];
        }

        if (numLevels != levelInfos.count) {
            *error = [NSError errorWithDomain:@"CC" 
                                         code:12
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"invalid data file", NSLocalizedDescriptionKey, nil]];
            NSLog(@"CORRUPT - expected %d levels but read %d", numLevels, levelInfos.count);
        }
    } @catch (NSException *exc) {
        *error = [NSError errorWithDomain:@"CC" 
                                    code:13
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[exc reason], NSLocalizedDescriptionKey, nil]];
    }    
    free(buf);
    
    if (error != NULL && *error != nil) {
        [levelInfos removeAllObjects];
    }
    
    return levelInfos;
}

+(NSArray *)loadLevelListForAsset:(CCPersistedAsset *)asset;
{
    
    NSData *data = [CCPersistence getAssetData:asset ofType:ASSET_TYPE_LEVELPACK];
    NSError *error = nil;
    NSArray *levelList = nil;
    @try {
        levelList = [CCDataReader loadLevelListFromData:data error:&error];
    } @catch (id e) {
        // fall back to first included pack upon any error
        CCPersistedAsset *a = [CCPersistence assetOfType:ASSET_TYPE_LEVELPACK assetId:-1];
        data = [CCPersistence getAssetData:a ofType:ASSET_TYPE_LEVELPACK];
        levelList = [CCDataReader loadLevelListFromData:data error:NULL];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Corrupt levelpack file" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    return levelList;
}

+(CCLevel *)newLevel:(int)levelNum fromAsset:(CCPersistedAsset *)asset
{
#ifdef REPORT
    if (topReport == NULL) {
        topReport = malloc(sizeof(int)*0xFF);
        bottomReport = malloc(sizeof(int)*0xFF);
        for (int i = 0; i < 0xFF; i++) {
            topReport[i] = 0;
            bottomReport[i] = 0;
        }
    }
#endif
    
    NSData *data = [CCPersistence getAssetData:asset ofType:ASSET_TYPE_LEVELPACK];
    byte *buf = malloc(sizeof(byte) * 0xFF);
    
    // first move to level data
    uint offset = 0x06;
    for (int i = 0; i < levelNum-1; i++) {
        unsigned short next = getUShort(data, buf, &offset);
        offset += next;
    }
 
    free(buf);
    
    return [CCDataReader newLevelFromData:data atOffset:&offset];
}

+(void)report
{
#ifdef REPORT
    printf("-- TOP --\n");
    for (int i = 0; i < 0xFF; i++) {
        if (topReport[i] > 0) {
            printf(" %0.2x (%s) - %d\n", i, [objectNames[i] UTF8String], topReport[i]);
        }
    }
    printf("-- BOTTOM --\n");
    for (int i = 0; i < 0xFF; i++) {
        if (bottomReport[i] > 0) {
            printf(" %0.2x (%s) - %d\n", i, [objectNames[i] UTF8String], bottomReport[i]);
        }
    }
#endif
}

@end
