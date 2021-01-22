//  Copyright 2009 StadiaJack. All rights reserved.

/*!
   Author: StadiaJack
   Date: 10/22/09
 */
@interface CCPlayerLevelPackProgress : NSObject<NSCoding> {
    int currentLevelNum;
    BOOL completed;
    NSMutableArray *bestTimes;
    NSMutableArray *highScores;
    NSMutableArray *unsuccessfulAttemptCounters;
}

@property (nonatomic, assign) int currentLevelNum;
@property (nonatomic, assign) BOOL completed;
@property (nonatomic, readonly) NSMutableArray *bestTimes;
@property (nonatomic, readonly) NSMutableArray *highScores;
@property (nonatomic, readonly) NSMutableArray *unsuccessfulAttemptCounters;

@end
