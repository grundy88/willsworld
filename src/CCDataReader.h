
#import "CCLevel.h"
#import "CCPersistedAsset.h"

@interface CCDataReader : NSObject {
}

+(int)getNumLevelsInAsset:(CCPersistedAsset *)asset;
+(NSArray *)loadLevelListFromData:(NSData *)data error:(NSError **)error;
+(NSArray *)loadLevelListForAsset:(CCPersistedAsset *)asset;
+(CCLevel *)newLevel:(int)levelNum fromAsset:(CCPersistedAsset *)asset;

+(void)report;

@end

