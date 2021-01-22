//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCPlayerSettings.h"
#import "CCPersistence.h"

#define CODE_CURRENT_LEVEL_PACK @"p"
#define CODE_PORTRAIT_LAYOUT @"pl"
#define CODE_LANDSCAPE_LAYOUT @"ll"
#define CODE_ORIENTATION_LOCK @"ol"
#define CODE_NOPASSWORDS @"np"
#define CODE_NODEATHPENALTY @"ndp"
#define CODE_CURRENT_TILESET @"ts"
#define CODE_CURRENT_BACKGROUND @"bg"
#define CODE_TREASURE_NAME @"tn"
#define CODE_CHARACTER_NAME @"cn"
#define CODE_GAME_SOUNDS @"gs"
#define CODE_MENU_SOUNDS @"ms"

/*!
   Author: StadiaJack
   Date: 11/6/09
 */
@implementation CCPlayerSettings

@synthesize portraitLayout;
@synthesize landscapeLayout;
@synthesize noPasswords;
@synthesize noDeathPenalty;
@synthesize lockedOrientation;
@synthesize currentLevelpackAssetId;
@synthesize currentTilesetAssetId;
@synthesize currentBackgroundAssetId;
@synthesize treasureName;
//@synthesize characterName;
@synthesize gameSoundLevel;
@synthesize menuSounds;

-(id)init
{
    if ((self = [super init])) {
        portraitLayout = CCLayoutTwoHandsRight;
        landscapeLayout = CCLayoutLandscapeButtons;
        lockedOrientation = -1;
        noPasswords = NO;
        noDeathPenalty = NO;
        self.currentLevelpackAssetId = -1;
        self.currentTilesetAssetId = -1;
        self.currentBackgroundAssetId = -1;
        self.treasureName = @"COINS";
//        self.characterName = @"Will";
        gameSoundLevel = CCGameSoundsAll;
        menuSounds = YES;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super init])) {
        portraitLayout = [coder decodeIntForKey:CODE_PORTRAIT_LAYOUT];
        landscapeLayout = [coder decodeIntForKey:CODE_LANDSCAPE_LAYOUT];
        lockedOrientation = [coder decodeIntForKey:CODE_ORIENTATION_LOCK];
        noPasswords = [coder decodeBoolForKey:CODE_NOPASSWORDS];
        noDeathPenalty = [coder decodeBoolForKey:CODE_NODEATHPENALTY];
        currentLevelpackAssetId = [coder decodeIntForKey:CODE_CURRENT_LEVEL_PACK];
        currentTilesetAssetId = [coder decodeIntForKey:CODE_CURRENT_TILESET];
        currentBackgroundAssetId = [coder decodeIntForKey:CODE_CURRENT_BACKGROUND];
        self.treasureName = [coder decodeObjectForKey:CODE_TREASURE_NAME];
//        self.characterName = [coder decodeObjectForKey:CODE_CHARACTER_NAME];
        gameSoundLevel = [coder decodeIntForKey:CODE_GAME_SOUNDS];
        menuSounds = [coder decodeBoolForKey:CODE_MENU_SOUNDS];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt:portraitLayout forKey:CODE_PORTRAIT_LAYOUT];
    [coder encodeInt:landscapeLayout forKey:CODE_LANDSCAPE_LAYOUT];
    [coder encodeInt:lockedOrientation forKey:CODE_ORIENTATION_LOCK];
    [coder encodeBool:noPasswords forKey:CODE_NOPASSWORDS];
    [coder encodeBool:noDeathPenalty forKey:CODE_NODEATHPENALTY];
    [coder encodeInt:currentLevelpackAssetId forKey:CODE_CURRENT_LEVEL_PACK];
    [coder encodeInt:currentTilesetAssetId forKey:CODE_CURRENT_TILESET];
    [coder encodeInt:currentBackgroundAssetId forKey:CODE_CURRENT_BACKGROUND];
    [coder encodeObject:treasureName forKey:CODE_TREASURE_NAME];
//    [coder encodeObject:characterName forKey:CODE_CHARACTER_NAME];
    [coder encodeInt:gameSoundLevel forKey:CODE_GAME_SOUNDS];
    [coder encodeBool:menuSounds forKey:CODE_MENU_SOUNDS];
}

-(void)dealloc
{
    [treasureName release];
//    [characterName release];
    [super dealloc];
}

@end
