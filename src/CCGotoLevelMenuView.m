//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCGotoLevelMenuView.h"
#import "CCController.h"
#import "CCMenuButton.h"
#import "CCLevelPack.h"

/*!
   Author: StadiaJack
   Date: 11/12/09
 */
@implementation CCGotoLevelMenuView

-(id)initWithFrame:(CGRect)frame menu:(CCMenuView *)_menu
{
    if (self = [super initWithFrame:frame menu:_menu]) {
        CCMenuButton *backButton = [[CCMenuButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        backButton.title = @"<< Back";
        backButton.clickTarget = menu;
        backButton.clickSelector = @selector(showMainPage);
        backButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:backButton];
        [backButton release];
        
        UILabel *levelPackTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 32, self.bounds.size.width, 20)];
        levelPackTitle.backgroundColor = [UIColor clearColor];
        levelPackTitle.font = [UIFont italicSystemFontOfSize:18];
        levelPackTitle.textAlignment = UITextAlignmentCenter;
        levelPackTitle.text = [menu.controller.currentPlayer.currentLevelPack.asset.name stringByDeletingPathExtension];
        levelPackTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:levelPackTitle];
        [levelPackTitle release];
        
        levelChoose = [CCLevelInfoTableViewController new];
        levelChoose.player = menu.controller.currentPlayer;
        levelChoose.delegate = self;
        levelChoose.view.frame = CGRectMake(0, 60, self.bounds.size.width, self.bounds.size.height-60);
        levelChoose.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [levelChoose viewDidAppear:NO];
        [self addSubview:levelChoose.view];
        
        if (menu.controller.currentPlayer.currentLevelPack.currentLevelNum > 0) {
            [levelChoose performSelector:@selector(scrollTo:) withObject:[NSNumber numberWithInt:menu.controller.currentPlayer.currentLevelPack.currentLevelNum] afterDelay:0.1];
        }
    }
    return self;
}

-(void)choseLevel:(UIViewController *)c
{
    [menu.controller startLevel:YES savePlayer:YES];
}

-(void)dealloc
{
    [levelChoose release];
    [super dealloc];
}

@end
