//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCLayoutManager.h"
#import "CCCommon.h"

/*!
   Author: StadiaJack
   Date: 11/6/09
 */
@interface CCPlayerSettings : NSObject<NSCoding> {
    CCLayoutType portraitLayout;
    CCLayoutType landscapeLayout;
    UIInterfaceOrientation lockedOrientation;
    BOOL noPasswords;
    BOOL noDeathPenalty;
    int currentLevelpackAssetId;
    int currentTilesetAssetId;
    int currentBackgroundAssetId;
    NSString *treasureName;
//    NSString *characterName;
    CCGameSoundLevel gameSoundLevel;
    BOOL menuSounds;
}

@property(nonatomic, assign) CCLayoutType portraitLayout;
@property(nonatomic, assign) CCLayoutType landscapeLayout;
@property(nonatomic, assign) BOOL noPasswords;
@property(nonatomic, assign) BOOL noDeathPenalty;
@property(nonatomic, assign) UIInterfaceOrientation lockedOrientation;
@property(nonatomic, assign) int currentLevelpackAssetId;
@property(nonatomic, assign) int currentTilesetAssetId;
@property(nonatomic, assign) int currentBackgroundAssetId;
@property(nonatomic, copy) NSString *treasureName;
//@property(nonatomic, copy) NSString *characterName;
@property(nonatomic, assign) CCGameSoundLevel gameSoundLevel;
@property(nonatomic, assign) BOOL menuSounds;

@end
