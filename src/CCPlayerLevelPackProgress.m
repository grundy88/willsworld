//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCPlayerLevelPackProgress.h"

#define CODE_LEVEL_NUM @"lppl"
#define CODE_COMPLETED @"lppc"
#define CODE_BEST_TIMES @"lppt"
#define CODE_HIGH_SCORES @"lpps"
#define CODE_UNSUCCESSFUL_ATTEMPT_COUNTERS @"lppu"

/*!
   Author: StadiaJack
   Date: 10/22/09
 */
@implementation CCPlayerLevelPackProgress

@synthesize currentLevelNum;
@synthesize completed;
@synthesize bestTimes;
@synthesize highScores;
@synthesize unsuccessfulAttemptCounters;

-(id)init
{
    if (self = [super init]) {
        currentLevelNum = 1;
        completed = NO;
        bestTimes = [NSMutableArray new];
        highScores = [NSMutableArray new];
        unsuccessfulAttemptCounters = [NSMutableArray new];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        currentLevelNum = [coder decodeIntForKey:CODE_LEVEL_NUM];
        completed = [coder decodeBoolForKey:CODE_COMPLETED];
        bestTimes = [[coder decodeObjectForKey:CODE_BEST_TIMES] retain];
        highScores = [[coder decodeObjectForKey:CODE_HIGH_SCORES] retain];
        unsuccessfulAttemptCounters = [[coder decodeObjectForKey:CODE_UNSUCCESSFUL_ATTEMPT_COUNTERS] retain];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt:currentLevelNum forKey:CODE_LEVEL_NUM];
    [coder encodeBool:completed forKey:CODE_COMPLETED];
    [coder encodeObject:bestTimes forKey:CODE_BEST_TIMES];
    [coder encodeObject:highScores forKey:CODE_HIGH_SCORES];
    [coder encodeObject:unsuccessfulAttemptCounters forKey:CODE_UNSUCCESSFUL_ATTEMPT_COUNTERS];
}

-(void)dealloc
{
    [bestTimes release];
    [highScores release];
    [unsuccessfulAttemptCounters release];
    [super dealloc];
}

@end
