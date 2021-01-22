//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCMainMenuView.h"
#import "CCMenuButton.h"
#import "CCLayoutManager.h"
#import "CCLevelPack.h"
#import "CCController.h"
#import "CCCommon.h"

enum {
    TAG_MENU_PAGE = 2000,
    TAG_RESUME_BUTTON = 2001,
    TAG_RESTART_BUTTON = 2002,
    TAG_LEVELPACK_INFO = 2003,
    TAG_PLAYER_INFO = 2004,
    TAG_CONTROLS = 2005,
    TAG_GOTO_BUTTON = 2006,
    TAG_LEVELSET_BUTTON = 2007,
    TAG_EDIT_PLAYER_BUTTON = 2008,
    TAG_SETTINGS_BUTTON = 2009,
    TAG_SEPARATOR1 = 2010,
    TAG_SEPARATOR2 = 2011,
    TAG_SEPARATOR3 = 2012,
    TAG_HELP_BUTTON = 2013
//    TAG_RATE_BUTTON = 2014
};

#define BUTTON_HEIGHT 36

/*!
   Author: StadiaJack
   Date: 11/12/09
 */
@implementation CCMainMenuView

-(void)layout:(UIInterfaceOrientation)orientation
{
    
    UIView *resumeButton = [self viewWithTag:TAG_RESUME_BUTTON];
    UIView *restartButton = [self viewWithTag:TAG_RESTART_BUTTON];
    UIView *separator1 = [self viewWithTag:TAG_SEPARATOR1];
    UIView *separator2 = [self viewWithTag:TAG_SEPARATOR2];
    UIView *separator3 = [self viewWithTag:TAG_SEPARATOR3];
    UIView *levelPackInfo = [self viewWithTag:TAG_LEVEL_VIEW];
    UIView *playerInfo = [self viewWithTag:TAG_PLAYER_INFO];
    UIView *controlsButton = [self viewWithTag:TAG_CONTROLS];
    UIView *settingsButton = [self viewWithTag:TAG_SETTINGS_BUTTON];
    UIView *gotoButton = [self viewWithTag:TAG_GOTO_BUTTON];
    UIView *changeLevelSetButton = [self viewWithTag:TAG_LEVELSET_BUTTON];
    UIView *playerEditButton = [self viewWithTag:TAG_EDIT_PLAYER_BUTTON];
    UIView *helpButton = [self viewWithTag:TAG_HELP_BUTTON];
//    UIView *rateButton = [self viewWithTag:TAG_RATE_BUTTON];
    
    int x;
    int y;
    int w = self.bounds.size.width;

    [resumeButton setNeedsDisplay];
    [restartButton setNeedsDisplay];
    [levelPackInfo setNeedsDisplay];
    [playerInfo setNeedsDisplay];
    [controlsButton setNeedsDisplay];
    [settingsButton setNeedsDisplay];
    [gotoButton setNeedsDisplay];
    [changeLevelSetButton setNeedsDisplay];
    [playerEditButton setNeedsDisplay];
    [helpButton setNeedsDisplay];
//    [rateButton setNeedsDisplay];
    
    int space = ipad() ? 80 : BUTTON_HEIGHT + 2;
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        x = 0;
        y = 2;
        resumeButton.frame = CGRectMake(x, y, w, BUTTON_HEIGHT);
        
        y += space;
        restartButton.frame = CGRectMake(x, y, w, BUTTON_HEIGHT);
        
        y += 4;
        y += space;
        position(separator1, x, y);
        
        y += 10;
        levelPackInfo.frame = CGRectMake(x, y, w, levelPackInfo.bounds.size.height);
        
        y += 105;
        y += space;
        position(separator2, x, y);
        
        y += 10;
        playerInfo.frame = CGRectMake(x, y, w, 70);
        
        y += 28;
        y += space;
        position(separator3, x, y);
        
        y += 7;
//        settingsButton.frame = CGRectMake(x, y, w, BUTTON_HEIGHT);
        settingsButton.frame = CGRectMake(x, y, w/2-5, BUTTON_HEIGHT);
        helpButton.frame = CGRectMake(x+w/2+5, y, w/2-5, BUTTON_HEIGHT);
        
        y += space;
//        if (YES) {
//            controlsButton.frame = CGRectMake(x, y, w/2-5, BUTTON_HEIGHT);
//            rateButton.frame = CGRectMake(x+w/2+5, y, w/2-5, BUTTON_HEIGHT);
//            rateButton.hidden = NO;
//        } else {
            controlsButton.frame = CGRectMake(x, y, w, BUTTON_HEIGHT);
//            rateButton.hidden = YES;
//        }
    } else {
        x = 0;
        y = 0;
        w = w/2-5;
        resumeButton.frame = CGRectMake(x, y, w, BUTTON_HEIGHT);
        restartButton.frame = CGRectMake(x+w+10, y, w, BUTTON_HEIGHT);
        
        y += space;
        position(separator1, x, y);
        
        y += 2;
        levelPackInfo.frame = CGRectMake(x, y, w, levelPackInfo.bounds.size.height);
        playerInfo.frame = CGRectMake(x+w+10, y, w, 90);

        y += 103;
//        if (YES) {
//            rateButton.frame = CGRectMake(x+w+10, y, w, BUTTON_HEIGHT);
//            rateButton.hidden = NO;
//        } else {
//            rateButton.hidden = YES;
//        }
        
        y += space;
        y += 2;
        position(separator2, x, y);
        position(separator3, x, y);
        
        y += 10;
//        w = self.bounds.size.width/2-5;
//        settingsButton.frame = CGRectMake(x, y, w, BUTTON_HEIGHT);
//        controlsButton.frame = CGRectMake(x+w+11, y, w, BUTTON_HEIGHT);
        w = self.bounds.size.width/3-5;
        settingsButton.frame = CGRectMake(x, y, w, BUTTON_HEIGHT);
        helpButton.frame = CGRectMake(x+w+8, y, w, BUTTON_HEIGHT);
        
        controlsButton.frame = CGRectMake(x+w*2+16, y, w, BUTTON_HEIGHT);
    }
}

-(id)initWithFrame:(CGRect)frame menu:(CCMenuView *)_menu
{
    self = [super initWithFrame:frame menu:_menu];
    if (self) {
        int w = frame.size.width;

        if (menu.controller.currentPlayer.currentLevelPack.currentLevelNum > 0) {
            CCMenuButton *resumeButton = [[CCMenuButton alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            resumeButton.title = @"Resume";
            resumeButton.clickTarget = menu.controller;
            resumeButton.clickSelector = @selector(resume);
            resumeButton.tag = TAG_RESUME_BUTTON;
            [self addSubview:resumeButton];
            [resumeButton release];
            
            CCMenuButton *restartButton = [[CCMenuButton alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
            restartButton.title = @"Restart Level";
            restartButton.clickTarget = menu.controller;
            restartButton.clickSelector = @selector(restartLevel);
            restartButton.tag = TAG_RESTART_BUTTON;
            [self addSubview:restartButton];
            [restartButton release];
        }
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 1)];
        separator.backgroundColor = [UIColor blackColor];
        separator.tag = TAG_SEPARATOR1;
        separator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:separator];
        [separator release];
        
        CCLevelPack *levelPack = menu.controller.currentPlayer.currentLevelPack;
        int x = 0;
        int y = 0;
        UIView *levelPackInfo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 90)];
        levelPackInfo.tag = TAG_LEVEL_VIEW;
        levelPackInfo.backgroundColor = [UIColor clearColor];
        [self addSubview:levelPackInfo];
        [levelPackInfo release];
        int w1 = levelPackInfo.bounds.size.width;
        
        UILabel *levelPackIntro = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 80, 20)];
        levelPackIntro.backgroundColor = [UIColor clearColor];
        levelPackIntro.text = @"Level set:";
        [levelPackInfo addSubview:levelPackIntro];
        [levelPackIntro release];
        
//        y += 20;
        UILabel *levelPackTitle = [[UILabel alloc] initWithFrame:CGRectMake(x+80, y, w1-x-80, 20)];
        levelPackTitle.backgroundColor = [UIColor clearColor];
        levelPackTitle.font = [UIFont boldSystemFontOfSize:16];
        levelPackTitle.adjustsFontSizeToFitWidth = YES;
        levelPackTitle.minimumFontSize = 10;
        levelPackTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        levelPackTitle.text = [levelPack.asset.name stringByDeletingPathExtension];
        [levelPackInfo addSubview:levelPackTitle];
        [levelPackTitle release];
        
        y += 20;
        UILabel *completionLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+15, y, w1-15, 20)];
        completionLabel.backgroundColor = [UIColor clearColor];
        completionLabel.font = [UIFont systemFontOfSize:14];
        completionLabel.text = [NSString stringWithFormat:@"%d%% completed - %d of %d", 
                                levelPack.levelsCompleted * 100 / MAX(levelPack.numLevels,1), levelPack.levelsCompleted, levelPack.numLevels];
        [levelPackInfo addSubview:completionLabel];
        [completionLabel release];
        
        y += 20;
        NSNumberFormatter *format = [NSNumberFormatter new];
//        [format setGroupingSeparator:@","];
//        [format setGroupingSize:3];
        [format setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString *score;
        @try {
            score = [format stringFromNumber:[NSNumber numberWithInt:levelPack.totalScore]];
        } @catch (NSException *e) {
            score = [NSString stringWithFormat:@"%d", levelPack.totalScore];
        }
        [format release];
        UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+15, y, w1-15, 20)];
        scoreLabel.backgroundColor = [UIColor clearColor];
        scoreLabel.font = [UIFont systemFontOfSize:14];
        scoreLabel.text = [NSString stringWithFormat:@"current score: %@", score]; 
        [levelPackInfo addSubview:scoreLabel];
        [scoreLabel release];
        
        y += 25;
        CCMenuButton *chooseLevelButton = [[CCMenuButton alloc] initWithFrame:CGRectMake(x, y, w1-x*2, BUTTON_HEIGHT)];
        chooseLevelButton.title = @"Goto Level";
        chooseLevelButton.clickTarget = menu;
        chooseLevelButton.clickSelector = @selector(showChooseLevel);
        chooseLevelButton.tag = TAG_GOTO_BUTTON;
        [levelPackInfo addSubview:chooseLevelButton];
        [chooseLevelButton release];
        
        y += ipad() ? 50 : BUTTON_HEIGHT + 2;
        CCMenuButton *changeLevelSetButton = [[CCMenuButton alloc] initWithFrame:CGRectMake(x, y, w1-x*2, BUTTON_HEIGHT)];
        changeLevelSetButton.title = @"Change Level Set";
        changeLevelSetButton.clickTarget = menu;
        changeLevelSetButton.clickSelector = @selector(showChooseLevelSet);
        changeLevelSetButton.tag = TAG_LEVELSET_BUTTON;
        [levelPackInfo addSubview:changeLevelSetButton];
        [changeLevelSetButton release];
        levelPackInfo.frame = CGRectMake(0, 0, w, y+BUTTON_HEIGHT+2);
        
        
        separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 1)];
        separator.backgroundColor = [UIColor blackColor];
        separator.tag = TAG_SEPARATOR2;
        separator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:separator];
        [separator release];
        
        UIView *playerInfo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 70)];
        playerInfo.tag = TAG_PLAYER_INFO;
        [self addSubview:playerInfo];
        [playerInfo release];
        x = 0;
        y = 0;
        w1 = playerInfo.bounds.size.width;
        
        UILabel *playerIntro = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 60, 20)];
        playerIntro.backgroundColor = [UIColor clearColor];
        playerIntro.text = @"Player:";
        [playerInfo addSubview:playerIntro];
        [playerIntro release];
        
//        y += 20;
        UILabel *playerName = [[UILabel alloc] initWithFrame:CGRectMake(x+60, y, w1-x-60, 20)];
        playerName.backgroundColor = [UIColor clearColor];
        playerName.font = [UIFont boldSystemFontOfSize:16];
        playerName.text = menu.controller.currentPlayer.name;
        [playerInfo addSubview:playerName];
        [playerName release];
        
        y += 25;
        CCMenuButton *playerEditButton = [[CCMenuButton alloc] initWithFrame:CGRectMake(x, y, w1-x*2, BUTTON_HEIGHT)];
        playerEditButton.title = @"Change/Edit Player";
        playerEditButton.clickTarget = menu;
        playerEditButton.clickSelector = @selector(showChangeEditPlayer);
        playerEditButton.tag = TAG_EDIT_PLAYER_BUTTON;
        [playerInfo addSubview:playerEditButton];
        [playerEditButton release];
        
        
        
        separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 1)];
        separator.backgroundColor = [UIColor blackColor];
        separator.tag = TAG_SEPARATOR3;
        separator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:separator];
        [separator release];
        
        CCMenuButton *settingsButton = [[CCMenuButton alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        settingsButton.title = @"Settings";
        settingsButton.clickTarget = menu;
        settingsButton.clickSelector = @selector(showAppearance);
        settingsButton.tag = TAG_SETTINGS_BUTTON;
        [self addSubview:settingsButton];
        [settingsButton release];
        
        CCMenuButton *helpButton = [[CCMenuButton alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        helpButton.title = @"Instructions";
        helpButton.clickTarget = menu;
        helpButton.clickSelector = @selector(showHelp);
        helpButton.tag = TAG_HELP_BUTTON;
        [self addSubview:helpButton];
        [helpButton release];
        
        CCMenuButton *controlsButton = [[CCMenuButton alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
#ifdef MAP_GENERATOR
        controlsButton.title = @"Generate Map";
#else
        controlsButton.title = @"Controls";
#endif
        controlsButton.clickTarget = menu;
        controlsButton.clickSelector = @selector(showSettings);
        controlsButton.tag = TAG_CONTROLS;
        [self addSubview:controlsButton];
        [controlsButton release];
        
//        CCMenuButton *rateButton = [[CCMenuButton alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
//        rateButton.title = @"Rate";
//        rateButton.clickTarget = menu;
//        rateButton.clickSelector = @selector(showRate);
//        rateButton.tag = TAG_RATE_BUTTON;
//        [self addSubview:rateButton];
//        [rateButton release];

        [self layout:[[UIApplication sharedApplication] statusBarOrientation]];
    }
    return self;
}

@end
