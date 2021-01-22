//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCPlayer.h"
#import "CCPersistedAsset.h"

#define PLAYER_LIST_KEY @"CCPlayers"

#define BUILTIN_LEVEL_PACK_1 @"Will's World.dat"
#define BUILTIN_LEVEL_PACK_2 @"Will's World Advanced.dat"
#define BUILTIN_LEVEL_PACK_3 @"iCCLP2.dat"
#define BUILTIN_LEVEL_PACK_4 @"CCLP1.dat"
#define BUILTIN_LEVEL_PACK_5 @"test.dat"
#define BUILTIN_LEVEL_PACK_6 @"CCLP3.dat"

#define BUILTIN_TILESET_1 @"Will's World"
#define BUILTIN_TILESET_2 @"Tile World"
//#define BUILTIN_TILESET_3 @"CC Original"
//#define BUILTIN_TILESET_4 @"CC Enhanced"
//#define BUILTIN_TILESET_5 @"CC Natural"
//#define BUILTIN_TILESET_6 @"CC Island"

#define BUILTIN_BACKGROUND_1 @"Will's World background"
#define BUILTIN_BACKGROUND_2 @"Tile World background"
#define BUILTIN_BACKGROUND_3 @"Enhanced background"
//#define BUILTIN_BACKGROUND_4 @"CC Original background"

#define KEY_LEVELPACK_DOWNLOAD @"keyLPD"
#define KEY_TILESET_DOWNLOAD @"keyTSD"
#define KEY_BACKGROUND_DOWNLOAD @"keyBGD"

//#define SUBDIR_LEVELPACK @"levelpacks"
//#define SUBDIR_TILESET @"tilesets"
//#define SUBDIR_BACKGROUND @"backgrounds"

#define ASSET_TYPE_LEVELPACK @"Levelpack"
#define ASSET_TYPE_TILESET @"Tileset"
#define ASSET_TYPE_BACKGROUND @"Background"

/*!
   Author: StadiaJack
   Date: 10/22/09
 */
@interface CCPersistence : NSObject

+(CCPlayer *)loadCurrentPlayer;
+(void)savePlayer:(CCPlayer *)player;
+(void)savePlayerSettings:(CCPlayer *)player;
+(void)removePlayerProgress:(CCPlayer *)player asset:(CCPersistedAsset *)asset;

+(CCLevelPack *)loadLevelPack:(CCPersistedAsset *)asset 
                    forPlayer:(CCPlayer *)player 
                   loadLevels:(BOOL)loadLevels;

+(NSArray *)loadPlayerNames;
+(void)setCurrentPlayer:(NSString *)playerName;
+(void)renamePlayerName:(NSString *)oldName to:(NSString *)newName;
+(NSString *)deletePlayerNamed:(NSString *)playerName;
+(void)addPlayerNamed:(NSString *)playerName;


+(NSString *)persistenceDir:(NSString *)assetType;

+(NSArray *)includedAssetsOfType:(NSString *)assetType;
+(NSArray *)downloadedAssetsOfType:(NSString *)assetType;
+(NSError *)saveDownloadedAssetOfType:(NSString *)assetType fromUrl:(NSString *)url data:(NSData *)data;
+(BOOL)deleteDownloadedAssetOfType:(NSString *)assetType assetId:(int)assetId;
+(BOOL)renameDownloadedAssetOfType:(NSString *)assetType assetId:(int)assetId to:(NSString *)newName;
+(void)saveAssetList:(NSArray *)assets ofType:(NSString *)assetType;
+(CCPersistedAsset *)assetOfType:(NSString *)assetType assetId:(int)assetId;
+(NSData *)getAssetData:(CCPersistedAsset *)asset ofType:(NSString *)assetType;
+(UIImage *)getImageAssetOfType:(NSString *)assetType assetId:(int)assetId fallback:(NSString *)fallback;

@end

/*
 user defaults:
   key = person
   value = map
     key = assetId
     value = CCPlayerLevelPackProgress
 
   key = "CCSETTINGS-" + person
   value = CCPlayerSettings
 
   key = "CCPLAYERS"
   value = array of known player names
 
*/