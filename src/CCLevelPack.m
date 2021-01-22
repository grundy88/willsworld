//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCLevelPack.h"
#import "CCDataReader.h"
#import "CCLevelInfo.h"
#import "CCPersistedAsset.h"

/*!
   Author: StadiaJack
   Date: 10/21/09
 */
@implementation CCLevelPack

@synthesize asset;
@synthesize levelInfos;
@synthesize numLevels;
@synthesize currentLevelNum;
@synthesize completed;

@synthesize levelsCompleted;
@synthesize totalScore;

-(id)initWithAsset:(CCPersistedAsset *)_asset loadLevels:(BOOL)load
{
    if (self = [super init]) {
        self.asset = _asset;
        if (load) {
            levelInfos = [CCDataReader loadLevelListForAsset:asset];
            numLevels = levelInfos.count;
        } else {
            levelInfos = nil;
            numLevels = [CCDataReader getNumLevelsInAsset:asset];
        }
    }
    return self;
}

-(void)calculateProgress
{
    levelsCompleted = 0;
    totalScore = 0;
    for (CCLevelInfo *levelInfo in levelInfos) {
        totalScore += levelInfo.highScore;
        if (levelInfo.highScore > 0) levelsCompleted++;
    }
}

-(void)dealloc
{
    [asset release];
    [levelInfos release];
    [super dealloc];
}

@end
