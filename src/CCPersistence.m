//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCPersistence.h"
#import "CCPlayerLevelPackProgress.h"
#import "CCLevelInfo.h"
#import "CCLevelPack.h"
#import "CCPlayer.h"
#import "CCPersistedAsset.h"
#import "CCExtensions.h"

#define CURRENT_PLAYER_NAME_KEY @"cpn"
#define PLAYER_NAME_PREFIX @"CCPlayer-"
#define PLAYER_SETTINGS_PREFIX @"CCSettings-"
#define TILESET_KEY @"tiles"
#define BACKGROUND_KEY @"background"
#define LAST_ASSET_ID_KEY @"lastAssetId"

#define LEVEL_NUM 1


/*!
   Author: StadiaJack
   Date: 10/22/09
 */
@implementation CCPersistence

static NSDictionary *includedAssets;

+(void)initialize
{
#ifdef DEBUG
    NSArray *includedLevelpacks = [NSArray arrayWithObjects:
                                   [CCPersistedAsset includedAssetNamed:BUILTIN_LEVEL_PACK_1 assetId:-1],
                                   [CCPersistedAsset includedAssetNamed:BUILTIN_LEVEL_PACK_2 assetId:-2],
                                   [CCPersistedAsset includedAssetNamed:BUILTIN_LEVEL_PACK_3 assetId:-3],
                                   [CCPersistedAsset includedAssetNamed:BUILTIN_LEVEL_PACK_4 assetId:-4],
                                   [CCPersistedAsset includedAssetNamed:BUILTIN_LEVEL_PACK_5 assetId:-5],
                                   [CCPersistedAsset includedAssetNamed:BUILTIN_LEVEL_PACK_6 assetId:-6],
                                   nil];
#else
    NSArray *includedLevelpacks = [NSArray arrayWithObjects:
                                   [CCPersistedAsset includedAssetNamed:BUILTIN_LEVEL_PACK_1 assetId:-1],
                                   [CCPersistedAsset includedAssetNamed:BUILTIN_LEVEL_PACK_2 assetId:-2],
                                   [CCPersistedAsset includedAssetNamed:BUILTIN_LEVEL_PACK_6 assetId:-6],
                                   [CCPersistedAsset includedAssetNamed:BUILTIN_LEVEL_PACK_3 assetId:-3],
                                   nil];
#endif
    NSArray *includedTilesets = [NSArray arrayWithObjects:
                                 [CCPersistedAsset includedAssetNamed:BUILTIN_TILESET_1 assetId:-1],
                                 [CCPersistedAsset includedAssetNamed:BUILTIN_TILESET_2 assetId:-2],
                                 // todo comment
//                                 [CCPersistedAsset includedAssetNamed:BUILTIN_TILESET_3 assetId:-3],
//                                 [CCPersistedAsset includedAssetNamed:BUILTIN_TILESET_4 assetId:-4],
//                                 [CCPersistedAsset includedAssetNamed:BUILTIN_TILESET_5 assetId:-5],
                                 nil];
    NSArray *includedBackgrounds = [NSArray arrayWithObjects:
                                    [CCPersistedAsset includedAssetNamed:BUILTIN_BACKGROUND_1 assetId:-1],
                                    [CCPersistedAsset includedAssetNamed:BUILTIN_BACKGROUND_2 assetId:-2],
                                    [CCPersistedAsset includedAssetNamed:BUILTIN_BACKGROUND_3 assetId:-3],
//                                    [CCPersistedAsset includedAssetNamed:BUILTIN_BACKGROUND_4 assetId:-4],
                                    nil];
            
    includedAssets = [[NSDictionary alloc] initWithObjectsAndKeys:
                      includedLevelpacks, ASSET_TYPE_LEVELPACK,
                      includedTilesets, ASSET_TYPE_TILESET,
                      includedBackgrounds, ASSET_TYPE_BACKGROUND,
                      nil];
}

// ------------------------------------------------------------------
#pragma mark -
#pragma mark directories

//+(NSData *)getFileData:(NSString *)filename subdir:(NSString *)subdir
//{
//    NSData *data = nil;
//    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
//        data = [NSData dataWithContentsOfFile:path];
//    } else {
//        path = [NSString stringWithFormat:@"%@/%@", subdir, filename];
//        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
//            data = [NSData dataWithContentsOfFile:path];
//        }
//    }
//    return data;
//}


+(NSString *)persistenceDir:(NSString *)assetType
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSMutableString *dir = [NSMutableString stringWithString:[paths objectAtIndex:0]];
    if (!dir) {
        NSLog(@"Documents directory '%@' not found - saving not possible", dir);
    } else {
        BOOL isDir;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDir];
        if (exists && !isDir) {
            NSLog(@"Documents directory '%@' exists but is a file - saving not possible", dir);
            dir = nil;
        } else {
            [dir appendFormat:@"/%@", assetType];
            exists = [[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDir];
            if (exists && !isDir) {
                NSLog(@"Peristence subdirectory '%@' exists but is a file - saving not possible", dir);
                dir = nil;
            } else if (!exists) {
                if (![[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:NULL]) {
                    NSLog(@"Persistence subdirectory '%@' does not exist and cannot create - saving not possible", dir);
                    dir = nil;
                }
            }
        }
    }
    return dir;
}

+(NSData *)getAssetData:(CCPersistedAsset *)asset ofType:(NSString *)assetType
{
    if (asset.assetId < 0) {
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:asset.name];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return [NSData dataWithContentsOfFile:path];
        }
    } else {
        NSString *assetDir = [CCPersistence persistenceDir:assetType];
        NSString *path = [NSString stringWithFormat:@"%@/%d", assetDir, asset.assetId];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return [NSData dataWithContentsOfFile:path];
        }
    }
    return nil;
}

// ------------------------------------------------------------------
#pragma mark -
#pragma mark player

static NSString *playerKey(NSString *name) {
    return [NSString stringWithFormat:@"%@%@", PLAYER_NAME_PREFIX, name];
}

static NSString *playerSettingsKey(NSString *name) {
    return [NSString stringWithFormat:@"%@%@", PLAYER_SETTINGS_PREFIX, name];
}

+(CCLevelPack *)loadLevelPack:(CCPersistedAsset *)asset 
                    forPlayer:(CCPlayer *)player 
                   loadLevels:(BOOL)loadLevels
{
    CCLevelPack *levelPack = [[CCLevelPack alloc] initWithAsset:asset loadLevels:loadLevels];
    levelPack.currentLevelNum = LEVEL_NUM;

    NSData *playerInfoData = [[NSUserDefaults standardUserDefaults] objectForKey:playerKey(player.name)];
    if (playerInfoData) {
        NSDictionary *playerInfo = [NSKeyedUnarchiver unarchiveObjectWithData:playerInfoData];
        CCPlayerLevelPackProgress *progress = [playerInfo objectForKey:[NSNumber numberWithInt:asset.assetId]];
        if (progress) {
            levelPack.currentLevelNum = progress.currentLevelNum;
            levelPack.completed = progress.completed;
            for (int i = 0; i < levelPack.numLevels && i < progress.bestTimes.count && i < progress.highScores.count; i++) {
                CCLevelInfo *levelInfo = [levelPack.levelInfos objectAtIndex:i];
                levelInfo.bestTime = [[progress.bestTimes objectAtIndex:i] intValue];
                levelInfo.highScore = [[progress.highScores objectAtIndex:i] intValue];
                levelInfo.unsuccessfulAttempts = [[progress.unsuccessfulAttemptCounters objectAtIndex:i] intValue];
            }
        }
    }        

    [levelPack calculateProgress];
    return [levelPack autorelease];
}

+(CCPlayer *)loadPlayerNamed:(NSString *)playerName
{
    CCPlayer *player = [CCPlayer new];
    player.name = playerName;
    
    NSData *settingsData = [[NSUserDefaults standardUserDefaults] objectForKey:playerSettingsKey(player.name)];
    if (settingsData) {
        player.settings = [NSKeyedUnarchiver unarchiveObjectWithData:settingsData];
    } else {
        player.settings = [CCPlayerSettings new];
    }
    
    CCPersistedAsset *asset = [CCPersistence assetOfType:ASSET_TYPE_LEVELPACK assetId:player.settings.currentLevelpackAssetId];
    if (!asset) {
        player.settings.currentLevelpackAssetId = -1;
        asset = [CCPersistence assetOfType:ASSET_TYPE_LEVELPACK assetId:-1];
    }
    CCLevelPack *levelPack = [CCPersistence loadLevelPack:asset forPlayer:player loadLevels:YES];
    player.currentLevelPack = levelPack;
    player.settings.currentLevelpackAssetId = asset.assetId;
    
    return [player autorelease];
}

+(CCPlayer *)loadCurrentPlayer
{
    NSString *currentPlayerName = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_PLAYER_NAME_KEY];
    if (!currentPlayerName) {
        currentPlayerName = @"Player 1";
        NSArray *playerNames = [NSArray arrayWithObject:currentPlayerName];
        [[NSUserDefaults standardUserDefaults] setObject:playerNames forKey:PLAYER_LIST_KEY];
        [[NSUserDefaults standardUserDefaults] setObject:currentPlayerName forKey:CURRENT_PLAYER_NAME_KEY];
    }

    return [self loadPlayerNamed:currentPlayerName];
}

+(void)savePlayer:(CCPlayer *)player
{
    NSMutableDictionary *playerInfo;
    NSData *playerInfoData = [[NSUserDefaults standardUserDefaults] objectForKey:playerKey(player.name)];
    if (playerInfoData) {
        playerInfo = [NSKeyedUnarchiver unarchiveObjectWithData:playerInfoData];
    } else {
        playerInfo = [NSMutableDictionary dictionary];
    }
    
    CCPlayerLevelPackProgress *progress = [[playerInfo objectForKey:[NSNumber numberWithInt:player.settings.currentLevelpackAssetId]] retain];
    if (!progress) {
        progress = [CCPlayerLevelPackProgress new];
        for (int i = 0; i < player.currentLevelPack.numLevels; i++) {
            [progress.bestTimes addObject:[NSNumber numberWithInt:-1]];
            [progress.highScores addObject:[NSNumber numberWithInt:0]];
            [progress.unsuccessfulAttemptCounters addObject:[NSNumber numberWithInt:0]];
        }
    }
    progress.currentLevelNum = MAX(player.currentLevelPack.currentLevelNum, 1);
    progress.completed = player.currentLevelPack.completed;
    
    for (int i = 0; i < player.currentLevelPack.numLevels && i < progress.bestTimes.count && i < progress.highScores.count; i++) {
        CCLevelInfo *levelInfo = [player.currentLevelPack.levelInfos objectAtIndex:i];
        [progress.bestTimes replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:levelInfo.bestTime]];
        [progress.highScores replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:levelInfo.highScore]];
        [progress.unsuccessfulAttemptCounters replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:levelInfo.unsuccessfulAttempts]];
    }
    
    [playerInfo setObject:progress forKey:[NSNumber numberWithInt:player.settings.currentLevelpackAssetId]];
    [progress release];

    playerInfoData = [NSKeyedArchiver archivedDataWithRootObject:playerInfo];
    [[NSUserDefaults standardUserDefaults] setObject:playerInfoData forKey:playerKey(player.name)];
//    [playerInfo release];
}

+(void)savePlayerSettings:(CCPlayer *)player
{
    NSData *settingsData = [NSKeyedArchiver archivedDataWithRootObject:player.settings];
    [[NSUserDefaults standardUserDefaults] setObject:settingsData forKey:playerSettingsKey(player.name)];
}

+(void)removePlayerProgress:(CCPlayer *)player asset:(CCPersistedAsset *)asset
{
    NSMutableDictionary *playerInfo;
    NSData *playerInfoData = [[NSUserDefaults standardUserDefaults] objectForKey:playerKey(player.name)];
    if (playerInfoData) {
        playerInfo = [NSKeyedUnarchiver unarchiveObjectWithData:playerInfoData];
        [playerInfo removeObjectForKey:[NSNumber numberWithInt:asset.assetId]];
        playerInfoData = [NSKeyedArchiver archivedDataWithRootObject:playerInfo];
        [[NSUserDefaults standardUserDefaults] setObject:playerInfoData forKey:playerKey(player.name)];
    }
}


// ------------------------------------------------------------------
#pragma mark -
#pragma mark level packs

//+(NSArray *)loadIncludedLevelPacks:(CCPlayer *)player
//{
//    NSArray *levelPackNames = [NSArray arrayWithObjects:
//                               BUILTIN_LEVEL_PACK_1,
//                               BUILTIN_LEVEL_PACK_2,
//                               BUILTIN_LEVEL_PACK_3,
////                               BUILTIN_LEVEL_PACK_4,
//                               nil];
//    
//    // load progress info for player
//    NSMutableArray *levelPacks = [NSMutableArray arrayWithCapacity:levelPackNames.count];
//    for (NSString *levelPackName in levelPackNames) {
//        CCLevelPack *levelPack = [[CCLevelPack alloc] initWithFilename:levelPackName];
//        [levelPacks addObject:levelPack];
//        [levelPack release];
//    }
//    
//    return levelPacks;
//}
//
//+(NSMutableArray *)loadDownloadedLevelPacks:(CCPlayer *)player
//{
//    NSString *downloadDir = [CCPersistence levelPackDir];
//    NSArray *levelPackNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:downloadDir error:NULL];
//
//    // load progress info for player
//    NSMutableArray *levelPacks = [NSMutableArray arrayWithCapacity:levelPackNames.count];
//    for (NSString *levelPackName in levelPackNames) {
//        CCLevelPack *levelPack = [[CCLevelPack alloc] initWithFilename:levelPackName];
//        [levelPacks addObject:levelPack];
//        [levelPack release];
//    }
//    
//    return levelPacks;
//}
//
//+(NSError *)saveDownloadedLevelPack:(NSString *)url data:(NSData *)data
//{
//    return [self saveDownloadedAsset:url data:data subdir:SUBDIR_LEVELPACK];
//}

//+(BOOL)deleteDownloadedLevelPack:(NSString *)filename forPlayer:(CCPlayer *)player
//{
//    // delete the file
//    NSString *downloadDir = [CCPersistence levelPackDir];
//    NSString *path = [NSString stringWithFormat:@"%@/%@", downloadDir, filename];
//    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
//
//    // remove progress
//    NSMutableDictionary *playerInfo = [[NSMutableDictionary alloc] initWithDictionary:
//                                       [[NSUserDefaults standardUserDefaults] objectForKey:playerKey(player.name)]];
//    [playerInfo removeObjectForKey:filename];
//    [[NSUserDefaults standardUserDefaults] setObject:playerInfo forKey:playerKey(player.name)];
//    [playerInfo release];
//    
//    // set current level pack to first if it was the one being deleted
//    if ([filename isEqualToString:player.settings.currentLevelPackFile]) {
//        [CCPersistence loadLevelPack:BUILTIN_LEVEL_PACK_1 forPlayer:player];
//        [CCPersistence savePlayerSettings:player];
//        return YES;
//    }
//    return NO;
//}

//+(BOOL)renameLevelPack:(CCLevelPack *)levelPack to:(NSString *)name
//{
//    NSString *levelPackFilename = levelPack.filename;
//    NSString *newName = [NSString stringWithFormat:@"%@/%@", 
//                         [[levelPackFilename stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByDeletingLastPathComponent],
//                         name];
//    NSString *downloadDir = [CCPersistence levelPackDir];
//    NSString *path = [NSString stringWithFormat:@"%@/%@", downloadDir, levelPackFilename];
//    NSString *newPath = [NSString stringWithFormat:@"%@/%@", downloadDir, [newName urlEncode]];
////    NSLog(@"renaming %@ to %@", path, newPath);
//    if ([[NSFileManager defaultManager] moveItemAtPath:path toPath:newPath error:NULL]) {
//        levelPack.filename = [newName urlEncode];
//        return YES;
//    }
//    return NO;
//}

// ------------------------------------------------------------------
#pragma mark -
#pragma mark players

+(NSArray *)loadPlayerNames
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:PLAYER_LIST_KEY];
}

+(void)setCurrentPlayer:(NSString *)playerName
{
    [[NSUserDefaults standardUserDefaults] setObject:playerName forKey:CURRENT_PLAYER_NAME_KEY];
}

+(void)renamePlayerName:(NSString *)oldName to:(NSString *)newName
{
    NSDictionary *playerInfo = [[NSUserDefaults standardUserDefaults] objectForKey:playerKey(oldName)];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:playerKey(oldName)];
    [[NSUserDefaults standardUserDefaults] setObject:playerInfo forKey:playerKey(newName)];
    
    NSData *settingsData = [[NSUserDefaults standardUserDefaults] objectForKey:playerSettingsKey(oldName)];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:playerSettingsKey(oldName)];
    [[NSUserDefaults standardUserDefaults] setObject:settingsData forKey:playerSettingsKey(newName)];

    NSString *currentPlayerName = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_PLAYER_NAME_KEY];
    if ([currentPlayerName isEqualToString:oldName]) {
        [CCPersistence setCurrentPlayer:newName];
    }
    
    NSMutableArray *playerNames = [NSMutableArray arrayWithArray:[CCPersistence loadPlayerNames]];
    int i = [playerNames indexOfObject:oldName];
    if (i != NSNotFound) {
        [playerNames replaceObjectAtIndex:i withObject:newName];
        [[NSUserDefaults standardUserDefaults] setObject:playerNames forKey:PLAYER_LIST_KEY];
    }
}

+(NSString *)deletePlayerNamed:(NSString *)playerName
{
    NSMutableArray *playerNames = [NSMutableArray arrayWithArray:[CCPersistence loadPlayerNames]];
    if (playerNames.count > 1) {

        [[NSUserDefaults standardUserDefaults] removeObjectForKey:playerKey(playerName)];

        [[NSUserDefaults standardUserDefaults] removeObjectForKey:playerSettingsKey(playerName)];
        
        [playerNames removeObject:playerName];
        [[NSUserDefaults standardUserDefaults] setObject:playerNames forKey:PLAYER_LIST_KEY];

        NSString *currentPlayerName = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_PLAYER_NAME_KEY];
        if ([currentPlayerName isEqualToString:playerName]) {
            NSString *newCurrentPlayer = [playerNames objectAtIndex:0];
            [CCPersistence setCurrentPlayer:newCurrentPlayer];
            return newCurrentPlayer;
        }
    }    
    return nil;
}

+(void)addPlayerNamed:(NSString *)playerName
{
    NSMutableArray *playerNames = [NSMutableArray arrayWithArray:[CCPersistence loadPlayerNames]];
    int i = [playerNames indexOfObject:playerName];
    if (i == NSNotFound) {
        [playerNames addObject:playerName];
        [[NSUserDefaults standardUserDefaults] setObject:playerNames forKey:PLAYER_LIST_KEY];
    }
}

// ------------------------------------------------------------------
#pragma mark -
#pragma mark tilesets
//
//+(NSArray *)includedTilesets
//{
//    return [NSArray arrayWithObjects:
//            BUILTIN_TILESET_1,
//            BUILTIN_TILESET_2,
//            BUILTIN_TILESET_3,
//            BUILTIN_TILESET_4,
//            BUILTIN_TILESET_5,
////            BUILTIN_TILESET_6,
//            nil];
//}
//
//+(NSArray *)downloadedTilesets
//{
//    NSString *downloadDir = [CCPersistence tilesetDir];
//    NSArray *tilesetFilenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:downloadDir error:NULL];
//    return (tilesetFilenames ? tilesetFilenames : [NSArray new]);
//}
//
//+(NSString *)currentTileset
//{
//    NSString *currentTileset = [[NSUserDefaults standardUserDefaults] objectForKey:TILESET_KEY];
//    if (!currentTileset) currentTileset = BUILTIN_TILESET_1;
//    return currentTileset;
//}
//
//+(void)saveCurrentTileset:(NSString *)tilesetFilename
//{
//    [[NSUserDefaults standardUserDefaults] setObject:tilesetFilename forKey:TILESET_KEY];
//}
//
//+(NSError *)saveDownloadedTileset:(NSString *)url data:(NSData *)data
//{
//    return nil;
//}

// ------------------------------------------------------------------
#pragma mark -
#pragma mark backgrounds
//
//+(NSArray *)includedBackgrounds
//{
//    return [NSArray arrayWithObjects:
//            BUILTIN_BACKGROUND_1,
//            BUILTIN_BACKGROUND_2,
//            BUILTIN_BACKGROUND_3,
////            BUILTIN_BACKGROUND_4,
//            nil];
//}
//
//+(NSArray *)downloadedBackgrounds
//{
//    NSString *downloadDir = [CCPersistence backgroundDir];
//    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:downloadDir error:NULL];
//}
//
//+(NSString *)currentBackground
//{
//    NSString *currentBackground = [[NSUserDefaults standardUserDefaults] objectForKey:BACKGROUND_KEY];
//    if (!currentBackground) currentBackground = BUILTIN_BACKGROUND_1;
//    return currentBackground;
//}
//
//+(void)saveCurrentBackground:(NSString *)backgroundFilename
//{
//    [[NSUserDefaults standardUserDefaults] setObject:backgroundFilename forKey:BACKGROUND_KEY];
//}
//
//+(NSError *)saveDownloadedBackground:(NSString *)url data:(NSData *)data
//{
//    return nil;
//}

// ------------------------------------------------------------------
#pragma mark -

+(NSArray *)includedAssetsOfType:(NSString *)assetType
{
    return [includedAssets objectForKey:assetType];
}

+(NSArray *)downloadedAssetsOfType:(NSString *)assetType
{
    NSArray *assets = nil;
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:assetType];
    if (data) assets = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    if (!assets) assets = [NSArray array];
    return assets;
}

+(void)saveAssetList:(NSArray *)assets ofType:(NSString *)assetType
{
    NSLog(@"saving asset list %d of type %@", assets.count, assetType);
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:assets] forKey:assetType];
}

+(NSError *)saveDownloadedAssetOfType:(NSString *)assetType fromUrl:(NSString *)url data:(NSData *)data
{
    NSError *error = nil;
    NSString *downloadDir = [CCPersistence persistenceDir:assetType];
    if (!downloadDir) {
        error = [NSError errorWithDomain:@"CC" 
                                    code:21
                                userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"can't save file", NSLocalizedDescriptionKey, nil]];
    } else {
        // load up previously saved assets
        NSArray *savedAssets = [self downloadedAssetsOfType:assetType];
        if (!savedAssets) savedAssets = [NSArray array];
        
        // search existing assets for given url
        CCPersistedAsset *asset = nil;
        int largestAssetId = 0;
        for (CCPersistedAsset *existingAsset in savedAssets) {
            if ([existingAsset.url isEqualToString:url]) {
                asset = existingAsset;
                break;
            }
            if (largestAssetId < existingAsset.assetId) {
                largestAssetId = existingAsset.assetId;
            }
        }
        
        if (!asset) {
            NSLog(@"New asset of type %@!!!", assetType);
            largestAssetId++;
            // if not found, create new asset with id one higher than current largest
            // and save asset list
            asset = [CCPersistedAsset new];
            asset.assetId = largestAssetId;
            NSString *s = [url stringByReplacingOccurrencesOfString:@"?" withString:@"/"];
            s = [s stringByReplacingOccurrencesOfString:@"&" withString:@"/"];
            s = [s stringByReplacingOccurrencesOfString:@"=" withString:@"/"];
            asset.name = [[s lastPathComponent] stringByDeletingPathExtension];
            asset.url = url;
            
            NSMutableArray *newAssetList = [NSMutableArray arrayWithArray:savedAssets];
            [newAssetList addObject:asset];
            [asset release];
            
            [self saveAssetList:newAssetList ofType:assetType];
        } else {
            NSLog(@"updating an existing asset of type %@", assetType);
        }

        // now write data to file
        NSString *path = [NSString stringWithFormat:@"%@/%d", downloadDir, asset.assetId];
        NSLog(@"writing asset (%d '%@' %@) to %@", asset.assetId, asset.name, asset.url, path);
        [data writeToFile:path options:NSAtomicWrite error:&error];
    }
    return error;
}

+(BOOL)deleteDownloadedAssetOfType:(NSString *)assetType assetId:(int)assetId
{
    NSArray *savedAssets = [self downloadedAssetsOfType:assetType];
    int indexToDelete = -1;
    for (int i = 0; i < savedAssets.count; i++) {
        CCPersistedAsset *existingAsset = [savedAssets objectAtIndex:i];
        if (existingAsset.assetId == assetId) {
            indexToDelete = i;
            break;
        }
    }
    
    if (indexToDelete >= 0) {
        CCPersistedAsset *asset = [savedAssets objectAtIndex:indexToDelete];

        // delete file
        NSString *downloadDir = [CCPersistence persistenceDir:assetType];
        NSString *path = [NSString stringWithFormat:@"%@/%d", downloadDir, asset.assetId];
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        NSLog(@"deleted %@", path);
        
        // remove from list
        NSMutableArray *newAssetList = [NSMutableArray arrayWithArray:savedAssets];
        [newAssetList removeObjectAtIndex:indexToDelete];
        [self saveAssetList:newAssetList ofType:assetType];
        
        return YES;
    }
    
    return NO;
}

+(BOOL)renameDownloadedAssetOfType:(NSString *)assetType assetId:(int)assetId to:(NSString *)newName
{
    NSArray *savedAssets = [self downloadedAssetsOfType:assetType];
    for (CCPersistedAsset *asset in savedAssets) {
        if (asset.assetId == assetId) {
            asset.name = newName;
            [self saveAssetList:savedAssets ofType:assetType];
            return YES;
        }
    }
    return NO;
}

+(CCPersistedAsset *)assetOfType:(NSString *)assetType assetId:(int)assetId
{
    if (assetId < 0) {
        NSArray *assets = [includedAssets objectForKey:assetType];
        for (CCPersistedAsset *asset in assets) {
            if (asset.assetId == assetId) {
                return asset;
            }
        }
    } else {
        NSArray *savedAssets = [self downloadedAssetsOfType:assetType];
        for (CCPersistedAsset *asset in savedAssets) {
            if (asset.assetId == assetId) {
                return asset;
            }
        }
    }
    return nil;
}

+(UIImage *)getImageAssetOfType:(NSString *)assetType assetId:(int)assetId fallback:(NSString *)fallback
{
    CCPersistedAsset *asset = [CCPersistence assetOfType:assetType assetId:assetId];
    UIImage *image = nil;
    if (asset.assetId < 0) {
        // it's an included asset
        
        // if on iPad try to find an HD version
        if (ipad()) {
            NSString *filename = [NSString stringWithFormat:@"%@ HD.png", asset.name];
            image = [UIImage imageNamed:filename];
        }
        if (!image) {
            NSString *filename = [NSString stringWithFormat:@"%@.png", asset.name];
            image = [UIImage imageNamed:filename];
        }
    } else {
        NSData *data = [CCPersistence getAssetData:asset ofType:ASSET_TYPE_TILESET];
        image = [UIImage imageWithData:data];
    }
    
    if (!image) {
        NSLog(@"Image %@ could not be loaded", asset.name);
        NSString *filename = [NSString stringWithFormat:@"%@.png", fallback];
        image = [UIImage imageNamed:filename];
    }
    return image;
}

@end
