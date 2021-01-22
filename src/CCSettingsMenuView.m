//  Copyright 2010 StadiaJack. All rights reserved.

#import "CCSettingsMenuView.h"
#import "CCMenuButton.h"
#import "CCPersistence.h"
#import "CCCommon.h"
#import "CCMenuView.h"
#import "CCController.h"
#import "CCSounds.h"

/*!
   Author: StadiaJack
   Date: 1/11/10
 */
@implementation CCSettingsMenuView

-(UILabel *)labelOnView:(UIView *)v 
                   text:(NSString *)text
                      x:(float)x
                      y:(float)y
                      w:(float)w
                      h:(float)h
{
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
    l.backgroundColor = [UIColor clearColor];
    l.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    l.text = text;
    l.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [v addSubview:l];
    [l release];
    return l;
}

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
        
        container = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, self.bounds.size.width, self.bounds.size.height-40)];
        container.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:container];
        [container release];
        
        int w = 80;
        int indent = 10;
        int x = 0;
        int y = 5;
        UILabel *tilesetLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, self.bounds.size.width-w-10, 20)];
        tilesetLabel.backgroundColor = [UIColor clearColor];
        tilesetLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        tilesetLabel.text = @"Tile set:";
        tilesetLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [container addSubview:tilesetLabel];
        [tilesetLabel release];
        
        CCMenuButton *changeTilesetButton = [[CCMenuButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-w, y-4, w, 30)];
        changeTilesetButton.title = @"Change";
        changeTilesetButton.clickTarget = menu;
        changeTilesetButton.clickSelector = @selector(showChooseTileset);
        changeTilesetButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [container addSubview:changeTilesetButton];
        [changeTilesetButton release];

        y += 30;
        UILabel *tilesetFilename = [[UILabel alloc] initWithFrame:CGRectMake(indent, y, self.bounds.size.width-indent, 20)];
        tilesetFilename.backgroundColor = [UIColor clearColor];
        tilesetFilename.text = [CCPersistence assetOfType:ASSET_TYPE_TILESET 
                                                  assetId:menu.controller.currentPlayer.settings.currentTilesetAssetId].name;
        tilesetFilename.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [container addSubview:tilesetFilename];
        [tilesetFilename release];
        
        
        y += 40;
        UILabel *backgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, self.bounds.size.width-w-10, 20)];
        backgroundLabel.backgroundColor = [UIColor clearColor];
        backgroundLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        backgroundLabel.text = @"Background:";
        backgroundLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [container addSubview:backgroundLabel];
        [backgroundLabel release];
        
        CCMenuButton *changeBackgroundButton = [[CCMenuButton alloc] initWithFrame:CGRectMake(self.bounds.size.width-w, y-4, w, 30)];
        changeBackgroundButton.title = @"Change";
        changeBackgroundButton.clickTarget = menu;
        changeBackgroundButton.clickSelector = @selector(showChooseBackground);
        changeBackgroundButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [container addSubview:changeBackgroundButton];
        [changeBackgroundButton release];

        y += 30;
        UILabel *backgroundFilename = [[UILabel alloc] initWithFrame:CGRectMake(indent, y, self.bounds.size.width-indent, 20)];
        backgroundFilename.backgroundColor = [UIColor clearColor];
        backgroundFilename.text = [CCPersistence assetOfType:ASSET_TYPE_BACKGROUND
                                                  assetId:menu.controller.currentPlayer.settings.currentBackgroundAssetId].name;
        backgroundFilename.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [container addSubview:backgroundFilename];
        [backgroundFilename release];
        
        
        y += 40;
        UILabel *treasureLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, self.bounds.size.width-w-10, 20)];
        treasureLabel.backgroundColor = [UIColor clearColor];
        treasureLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        treasureLabel.text = @"Treasure Name:";
        treasureLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [container addSubview:treasureLabel];
        [treasureLabel release];
        
        UITextField *treasureName = [[UITextField alloc] initWithFrame:CGRectMake(self.bounds.size.width-w, y-4, w, 30)];
        treasureName.text = menu.controller.currentPlayer.settings.treasureName;
        treasureName.delegate = self;
        treasureName.borderStyle = UITextBorderStyleBezel;
        treasureName.backgroundColor = [UIColor whiteColor];
        treasureName.autocorrectionType = UITextAutocorrectionTypeNo;
        treasureName.autocapitalizationType = UITextAutocapitalizationTypeNone;
        treasureName.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        treasureName.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [container addSubview:treasureName];
        [treasureName release];
        
        y += 40;
        w = self.bounds.size.width;
        UILabel *soundsLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, 20)];
        soundsLabel.backgroundColor = [UIColor clearColor];
        soundsLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        soundsLabel.text = @"Sound Level:";
        soundsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [container addSubview:soundsLabel];
        [soundsLabel release];
        
        y += 20;
        UISegmentedControl *soundSwitch = [[UISegmentedControl alloc] initWithItems:
                                           [NSArray arrayWithObjects:
                                            @"0",
                                            @"1",
                                            @"2",
                                            @"3",
                                            nil]];
        soundSwitch.frame = CGRectMake(x, y, self.bounds.size.width, 30);
        soundSwitch.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        soundSwitch.selectedSegmentIndex = menu.controller.currentPlayer.settings.gameSoundLevel;
        [soundSwitch addTarget:self
                        action:@selector(soundOptionChanged:)
              forControlEvents:UIControlEventValueChanged];
        [container addSubview:soundSwitch];
        [soundSwitch release];

        y += 30;
        x += 20;
        w -= 20;
        UILabel *l = [self labelOnView:container text:@"0: no sounds" x:x y:y w:w h:20];
        l.font = [UIFont systemFontOfSize:[UIFont labelFontSize]-3];
        y += 20;
        l = [self labelOnView:container text:@"1: only sounds made by you" x:x y:y w:w h:20];
        l.font = [UIFont systemFontOfSize:[UIFont labelFontSize]-3];
        y += 20;
        l = [self labelOnView:container text:@"2: onscreen sounds only" x:x y:y w:w h:20];
        l.font = [UIFont systemFontOfSize:[UIFont labelFontSize]-3];
        y += 20;
        l = [self labelOnView:container text:@"3: all sounds" x:x y:y w:w h:20];
        l.font = [UIFont systemFontOfSize:[UIFont labelFontSize]-3];
        y += 20;
        
        container.contentSize = CGSizeMake(self.bounds.size.width, y);
        
//        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//        [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    scrollOffset = container.contentOffset.y;
    container.contentOffset = CGPointMake(0, textField.frame.origin.y);
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField.text.length > 0 && ![textField.text isEqualToString:menu.controller.currentPlayer.settings.treasureName]) {
        menu.controller.currentPlayer.settings.treasureName = textField.text;
        [CCPersistence savePlayerSettings:menu.controller.currentPlayer];
        [menu.controller.mainView setTreasureName:textField.text];
    }
    container.contentOffset = CGPointMake(0, scrollOffset);
    return YES;
}

-(void)soundOptionChanged:(UISegmentedControl *)sender
{
    menu.controller.currentPlayer.settings.gameSoundLevel = sender.selectedSegmentIndex;
    [CCPersistence savePlayerSettings:menu.controller.currentPlayer];
    [[CCSounds instance] playClickUp];
}

@end
