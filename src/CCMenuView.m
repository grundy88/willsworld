//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCMenuView.h"
#import "CCMenuButton.h"
#import "CCController.h"
#import "CCLevelInfoTableViewController.h"
#import "CCExtensions.h"
#import "CCLevelPack.h"
#import "CCLayoutManager.h"
#import "CCBaseMenuView.h"
#import "CCMainMenuView.h"
#import "CCGotoLevelMenuView.h"
#import "CCControlsMenuView.h"
#import "CCPlayerMenuView.h"
#import "CCSettingsMenuView.h"
#import "CCPersistence.h"
#import "CCAssetListView.h"
#import "CCAssetDownloadView.h"
#import "CCLevelPackListView.h"
#import "CCTilesetListView.h"
#import "CCBackgroundListView.h"
#import "CCHelpMenuView.h"
#import <QuartzCore/QuartzCore.h>

//#define MENU_SCREEN_INSET 35
#define TAG_OUTLINE 102
#define TAG_MENU_PAGE 2000

/*!
   Author: StadiaJack
   Date: 10/21/09
 */
@implementation CCMenuView

@synthesize controller;

-(void)showPage:(UIView *)page
{
    UIView *currentPage = [menuContainer viewWithTag:TAG_MENU_PAGE];
    
    page.tag = TAG_MENU_PAGE;
    page.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [menuContainer addSubview:page];
    [currentPage removeFromSuperview];
    [page release];
    
//    [menuContainer replaceSubview:currentPage 
//                      withSubview:page 
//                       transition:kCATransitionPush
//                        direction:kCATransitionFromRight
//                         duration:0.2 
//                         delegate:nil];
}

-(void)showMainPage
{
    UIView *pageView = [[CCMainMenuView alloc] initWithFrame:menuContainer.bounds menu:self];
    [self showPage:pageView];
}

-(void)showChooseLevel
{
    UIView *pageView = [[CCGotoLevelMenuView alloc] initWithFrame:menuContainer.bounds menu:self];
    [self showPage:pageView];
}

-(void)showSettings
{
#ifdef MAP_GENERATOR
    [controller generateMapImage];
#else
    UIView *pageView = [[CCControlsMenuView alloc] initWithFrame:menuContainer.bounds menu:self];
    [self showPage:pageView];
#endif
}


-(void)showChooseLevelSet
{
    UIView *pageView = [[CCLevelPackListView alloc] initWithFrame:menuContainer.bounds menu:self];
    [self showPage:pageView];
}

-(void)showLevelPackDownload
{
    CCAssetDownloadView *pageView = [[CCAssetDownloadView alloc] initWithFrame:menuContainer.bounds 
                                                                menu:self
                                                    previousEntryKey:KEY_LEVELPACK_DOWNLOAD
                                                        instructions:@"Enter a URL of a levelset (.dat or .ccl) file:"
                                                           assetType:ASSET_TYPE_LEVELPACK
                                                        backSelector:@selector(showChooseLevelSet)
                                                      verifySelector:@selector(verifyLevelPack:)];
    [self showPage:pageView];
}

-(void)showChangeEditPlayer
{
    UIView *pageView = [[CCPlayerMenuView alloc] initWithFrame:menuContainer.bounds menu:self];
    [self showPage:pageView];
}

-(void)showAppearance
{
    UIView *pageView = [[CCSettingsMenuView alloc] initWithFrame:menuContainer.bounds menu:self];
    [self showPage:pageView];
}

-(void)showChooseTileset
{
    UIView *pageView = [[CCTilesetListView alloc] initWithFrame:menuContainer.bounds menu:self];
    [self showPage:pageView];
}

-(void)showTilesetDownload
{
    CCAssetDownloadView *pageView = [[CCAssetDownloadView alloc] initWithFrame:menuContainer.bounds 
                                                                menu:self
                                                    previousEntryKey:KEY_TILESET_DOWNLOAD
                                                        instructions:@"Enter a URL of a tileset image file:"
                                                           assetType:ASSET_TYPE_TILESET
                                                        backSelector:@selector(showChooseTileset)
                                                      verifySelector:@selector(verifyTileset:)];
    [self showPage:pageView];
}

-(void)showChooseBackground
{
    UIView *pageView = [[CCBackgroundListView alloc] initWithFrame:menuContainer.bounds menu:self];
    [self showPage:pageView];
}

-(void)showBackgroundDownload
{
    CCAssetDownloadView *pageView = [[CCAssetDownloadView alloc] initWithFrame:menuContainer.bounds 
                                                                menu:self
                                                    previousEntryKey:KEY_BACKGROUND_DOWNLOAD
                                                        instructions:@"Enter a URL of a background image file:"
                                                           assetType:@"Background"
                                                        backSelector:@selector(showChooseBackground)
                                                      verifySelector:@selector(verifyBackground:)];
    [self showPage:pageView];
}

-(void)showHelp
{
    UIView *pageView = [[CCHelpMenuView alloc] initWithFrame:menuContainer.bounds menu:self];
    [self showPage:pageView];
}

-(id)initWithFrame:(CGRect)frame controller:(CCController *)_controller
{
    self = [super initWithFrame:frame];
    if (self) {
        controller = _controller;
        
        UIView *overlay = [[UIView alloc] initWithFrame:frame];
        overlay.userInteractionEnabled = NO;
        overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlay.backgroundColor = [UIColor blackColor];
        overlay.alpha = 0.6;
        [self addSubview:overlay];
        [overlay release];
        
        CGRect f;
        if (!ipad()) {
            int menuScreenInset = 35;
            f = CGRectMake(menuScreenInset, menuScreenInset, frame.size.width-(menuScreenInset*2), frame.size.height-(menuScreenInset*2));
        } else {
            int menuScreenInset = 200;
            f = CGRectMake(menuScreenInset, menuScreenInset, frame.size.width-(menuScreenInset*2), frame.size.height-(menuScreenInset*2));
//            int w = 400;
//            int h = 600;
//            f = CGRectMake(horizMiddle(self)-w/2, vertMiddle(self)-h/2, w, h);
        }
        UIView *menuOutline = [[UIView alloc] initWithFrame:f];
        menuOutline.layer.cornerRadius = 10;
        menuOutline.layer.masksToBounds = YES;
        menuOutline.layer.borderWidth = 3;
        menuOutline.backgroundColor = [UIColor colorWithRed:0.8 green:1 blue:0.8 alpha:1];
        menuOutline.tag = TAG_OUTLINE;
        [self addSubview:menuOutline];
        [menuOutline release];
        menuOutline.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        f = CGRectInset(f, 10, 10);
        menuContainer = [[UIView alloc] initWithFrame:f];
        [self addSubview:menuContainer];
        [menuContainer release];
        menuContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

-(void)doLayout:(UIInterfaceOrientation)orientation
{
    [[self viewWithTag:TAG_OUTLINE] setNeedsDisplay];
    CCBaseMenuView *currentPage = (CCBaseMenuView *)[menuContainer viewWithTag:TAG_MENU_PAGE];
    [currentPage layout:orientation];
}

-(void)show
{
    self.hidden = NO;
    [self showMainPage];
}

@end
