//  Copyright 2009 StadiaJack. All rights reserved.

/*!
   Author: StadiaJack
   Date: 10/21/09
 */
@interface CCLevelInfo : NSObject {
    NSString *title;
    NSString *password;
    int bestTime;
    int highScore;
    int unsuccessfulAttempts;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) int bestTime;
@property (nonatomic, assign) int highScore;
@property (nonatomic, assign) int unsuccessfulAttempts;

@end
