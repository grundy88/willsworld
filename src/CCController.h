//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCMainView.h"
#import "CCPlayer.h"
#import "CCMenuView.h"

/*!
   Author: StadiaJack
   Date: 10/21/09
 */
@interface CCController : UIViewController {
    CCMainView *mainView;
    
    CCPlayer *currentPlayer;
    
//    CCMainMenuView *mainMenuView;
}

@property (nonatomic, readonly) CCMainView *mainView;
@property (nonatomic, readonly) CCPlayer *currentPlayer;

+(CCController *)instance;

-(void)loadCurrentPlayer;

-(void)startLevel:(BOOL)firstTime savePlayer:(BOOL)savePlayer;
-(void)levelStarted;
//-(void)restartLevel;
//-(void)jumpedToLevel;
-(void)resume;

-(void)died:(BOOL)nextLevel;
-(void)saveTime:(int)timeLeft levelBonus:(int)levelBonus;
-(void)levelCompleted;

-(BOOL)isMenuUp;
-(void)showMenu;
-(BOOL)hideMenu;

-(void)backgroundChanged;

#ifdef MAP_GENERATOR
-(void)generateMapImage;
#endif

@end
