//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCLevelPack.h"
#import "CCPlayerSettings.h"

/*!
   Author: StadiaJack
   Date: 10/21/09
 */
@interface CCPlayer : NSObject {
    NSString *name;
    CCLevelPack *currentLevelPack;
    CCPlayerSettings *settings;
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) CCLevelPack *currentLevelPack;
@property (nonatomic, retain) CCPlayerSettings *settings;

@end
