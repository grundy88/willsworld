//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCPersistedAsset.h"

/*!
   Author: StadiaJack
   Date: 10/21/09
 */
@interface CCLevelPack : NSObject {
    CCPersistedAsset *asset;
    NSArray *levelInfos;
    int numLevels;
    int currentLevelNum;
    BOOL completed;
    
    int levelsCompleted;
    int totalScore;
}

@property (nonatomic, retain) CCPersistedAsset *asset;
@property (nonatomic, readonly) NSArray *levelInfos;
@property (nonatomic, readonly) int numLevels;
@property (nonatomic, assign) int currentLevelNum;
@property (nonatomic, assign) BOOL completed;

@property (nonatomic, assign) int levelsCompleted;
@property (nonatomic, assign) int totalScore;

-(id)initWithAsset:(CCPersistedAsset *)_asset loadLevels:(BOOL)load;

-(void)calculateProgress;

@end
