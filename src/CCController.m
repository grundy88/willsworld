//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCController.h"
#import "CCDataReader.h"
#import "CCPersistence.h"
#import "CCLevelInfo.h"
#import "CCLayoutManager.h"
#import "CCTiles.h"

#define TAG_MENU 123
#define TAG_BACKGROUND 81818

/*!
   Author: StadiaJack
   Date: 10/21/09
 */
@implementation CCController

@synthesize mainView;
@synthesize currentPlayer;

+(CCController *)instance
{
    static CCController *instance;
    if (!instance) {
        instance = [CCController new];
    }
    return instance;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (currentPlayer.settings.lockedOrientation == -1) ||
            (currentPlayer.settings.lockedOrientation == interfaceOrientation);
}

-(BOOL)isMenuUp
{
    return [self.view viewWithTag:TAG_MENU] != nil;
}

-(void)showMenu
{
    if (![self.view viewWithTag:TAG_MENU]) {
        CCMenuView *mainMenuView = [[CCMenuView alloc] initWithFrame:self.view.bounds controller:self];
        [self.view addSubview:mainMenuView];
        [mainMenuView release];
        mainMenuView.tag = TAG_MENU;
        mainMenuView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [mainView pause];
        [mainMenuView show];
    }
}

-(BOOL)hideMenu
{
    UIView *menu = [self.view viewWithTag:TAG_MENU];
    if (menu) {
        [menu removeFromSuperview];
        return YES;
    }
    return NO;
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration
//-(void)willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration
{
//    UIInterfaceOrientation orientation = self.interfaceOrientation;
//    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    [[CCLayoutManager instance] layoutView:mainView orientation:orientation player:currentPlayer];
//    if ([self hideMenu]) {
//        [self showMenu];
        CCMenuView *menu = (CCMenuView *)[self.view viewWithTag:TAG_MENU];
    [menu doLayout:orientation];
//        [[CCLayoutManager instance] layoutMainMenu:menu orientation:orientation];
//    }
}

-(void)loadView
{
    [super loadView];
    
    UIView *background = [[UIView alloc] initWithFrame:self.view.bounds];
    background.tag = TAG_BACKGROUND;
    background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:background];
    [background release];
    [self backgroundChanged];

    
    mainView = [[CCMainView alloc] initWithFrame:self.view.bounds controller:self];
    mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:mainView];
    [mainView release];
    
    [self startLevel:YES savePlayer:NO];
}

-(void)loadCurrentPlayer
{
    [currentPlayer release];
    currentPlayer = [[CCPersistence loadCurrentPlayer] retain];
    CCPersistedAsset *tilesetAsset = [CCPersistence assetOfType:ASSET_TYPE_TILESET 
                                                        assetId:currentPlayer.settings.currentTilesetAssetId];
    [[CCTiles instance] loadTileset:tilesetAsset];
//    if (currentPlayer.settings.lockedOrientation != -1) {
//        UIDevice *device = [UIDevice currentDevice];
//        IMP method = [device methodForSelector:@selector(setOrientation:)];
//        method(device, @selector(setOrientation:), currentPlayer.settings.lockedOrientation);
//    }
}

-(void)backgroundLoadCurrentPlayer:(id)delegate
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [self loadCurrentPlayer];
    [pool release];
    [delegate performSelectorOnMainThread:@selector(controllerLoadDone:) withObject:self waitUntilDone:NO];
}

-(void)startLevel:(BOOL)firstTime savePlayer:(BOOL)savePlayer
{
    [self hideMenu];

    BOOL doSavePlayer = savePlayer;
    // save if it's the first time ever
    if (currentPlayer.currentLevelPack.currentLevelNum-1 >= 0 && 
        currentPlayer.currentLevelPack.currentLevelNum-1 < currentPlayer.currentLevelPack.levelInfos.count)
    {
        CCLevelInfo *levelInfo = [currentPlayer.currentLevelPack.levelInfos objectAtIndex:currentPlayer.currentLevelPack.currentLevelNum-1];
        if (levelInfo.bestTime == -1) {
            levelInfo.bestTime = 0;
            doSavePlayer = YES;
        }
    }
//    if (levelInfo.highScore <= 0) {
//        levelInfo.unsuccessfulAttempts++;
//        doSavePlayer = YES;
//    }
    if (doSavePlayer) [CCPersistence savePlayer:currentPlayer];
    
    CCLevel *level = [CCDataReader newLevel:currentPlayer.currentLevelPack.currentLevelNum 
                                   fromAsset:currentPlayer.currentLevelPack.asset];
    
    // hint string replacements
    NSString *hint = [level.hint stringByReplacingOccurrencesOfString:@"computer chips" withString:[currentPlayer.settings.treasureName lowercaseString]];
    hint = [hint stringByReplacingOccurrencesOfString:@"chips" withString:[currentPlayer.settings.treasureName lowercaseString]];
    hint = [hint stringByReplacingOccurrencesOfString:@"Chips" withString:[currentPlayer.settings.treasureName capitalizedString]];
    hint = [hint stringByReplacingOccurrencesOfString:@"chips" withString:[currentPlayer.settings.treasureName lowercaseString] options:NSCaseInsensitiveSearch range:NSMakeRange(0, hint.length)];
    hint = [hint stringByReplacingOccurrencesOfString:@"Chip" withString:@"Will"];
    hint = [hint stringByReplacingOccurrencesOfString:@"chip socket" withString:@"gate"];
    hint = [hint stringByReplacingOccurrencesOfString:@"socket" withString:@"gate"];
    hint = [hint stringByReplacingOccurrencesOfString:@"spy" withString:@"quicksand"];
    hint = [hint stringByReplacingOccurrencesOfString:@"spies" withString:@"quicksand"];
    hint = [hint stringByReplacingOccurrencesOfString:@"thief" withString:@"quicksand"];
    hint = [hint stringByReplacingOccurrencesOfString:@"thiefs" withString:@"quicksand"];
    hint = [hint stringByReplacingOccurrencesOfString:@"thieves" withString:@"quicksand"];
    hint = [hint stringByReplacingOccurrencesOfString:@"Thief" withString:@"Quicksand"];
    hint = [hint stringByReplacingOccurrencesOfString:@"Thiefs" withString:@"Quicksand"];
    hint = [hint stringByReplacingOccurrencesOfString:@"Thieves" withString:@"Quicksand"];
    level.hint = hint;
    
    [mainView startLevel:level firstTime:firstTime];
    [level release];
}

-(void)levelStarted
{
    if (currentPlayer.currentLevelPack.currentLevelNum-1 >= 0 && 
        currentPlayer.currentLevelPack.currentLevelNum-1 < currentPlayer.currentLevelPack.levelInfos.count)
    {
        CCLevelInfo *levelInfo = [currentPlayer.currentLevelPack.levelInfos objectAtIndex:currentPlayer.currentLevelPack.currentLevelNum-1];
        if (levelInfo.highScore <= 0) {
            levelInfo.unsuccessfulAttempts++;
            [CCPersistence savePlayer:currentPlayer];
        }
    }
}

-(void)died:(BOOL)nextLevel
{
    if (nextLevel && currentPlayer.currentLevelPack.currentLevelNum < currentPlayer.currentLevelPack.numLevels) {
        currentPlayer.currentLevelPack.currentLevelNum++;
        [self startLevel:YES savePlayer:YES];
    } else {
        [self startLevel:NO savePlayer:NO];
    }
}


-(void)saveTime:(int)timeLeft levelBonus:(int)levelBonus
{
    int timeBonus = timeLeft * 10;
    int score = timeBonus + levelBonus;
    
    CCLevelInfo *levelInfo = [currentPlayer.currentLevelPack.levelInfos objectAtIndex:currentPlayer.currentLevelPack.currentLevelNum-1];

    NSString *bonus = nil;
    if (levelInfo.highScore == 0 && levelInfo.unsuccessfulAttempts == 1) {
        bonus = @"Nice!! Got it on the first try!";
    } else if (levelInfo.highScore > 0 && score > levelInfo.highScore) {
        bonus = @"All right! A new high score!!";
    } else if (levelInfo.bestTime > 0 && timeLeft > levelInfo.bestTime) {
        bonus = @"Done in record time!!";
    }

//    if (levelInfo.highScore <= 0) levelInfo.unsuccessfulAttempts++;
    if (timeLeft > levelInfo.bestTime) levelInfo.bestTime = timeLeft;
    if (score > levelInfo.highScore) levelInfo.highScore = score;
    [currentPlayer.currentLevelPack calculateProgress];
    if (currentPlayer.currentLevelPack.currentLevelNum < currentPlayer.currentLevelPack.numLevels) {
        currentPlayer.currentLevelPack.currentLevelNum++;
    } else {
        currentPlayer.currentLevelPack.currentLevelNum = 0;
    }
    [CCPersistence savePlayer:currentPlayer];
    
    NSNumberFormatter *format = [NSNumberFormatter new];
    [format setNumberStyle:NSNumberFormatterDecimalStyle];
    NSMutableString *message = [NSMutableString stringWithFormat:@"Time Bonus: %@\nLevel Bonus: %@\nLevel Score: %@\nTotal Score: %@",
                                [format stringFromNumber:[NSNumber numberWithInt:timeBonus]],
                                [format stringFromNumber:[NSNumber numberWithInt:levelBonus]],
                                [format stringFromNumber:[NSNumber numberWithInt:score]],
                                [format stringFromNumber:[NSNumber numberWithInt:currentPlayer.currentLevelPack.totalScore]]];
    [format release];
    
    if (bonus) {
        [message appendFormat:@"\n\n%@", bonus];
    }

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self levelCompleted];
}

-(void)levelCompleted
{
    if (!currentPlayer.currentLevelPack.completed &&
        currentPlayer.currentLevelPack.levelsCompleted == currentPlayer.currentLevelPack.numLevels)
    {
        currentPlayer.currentLevelPack.completed = YES;
        [CCPersistence savePlayer:currentPlayer];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"YOU DID IT!!!!" 
                                                        message:@"You completed all levels in this level pack! Now you can go back and try to improve your score, or try a different level pack!"
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    if (currentPlayer.currentLevelPack.currentLevelNum > 0) {
        [self startLevel:YES savePlayer:NO];
    } else {
//        currentPlayer.currentLevelPack.currentLevelNum = 1;
        [self showMenu];
    }
}

-(void)resume
{
    [self hideMenu];
    [mainView resume];
}

-(void)restartLevel
{
    [self startLevel:NO savePlayer:NO];
}

//-(void)restartLevel
//{
//    CCLevelInfo *levelInfo = [currentPlayer.currentLevelPack.levelInfos objectAtIndex:currentPlayer.currentLevelPack.currentLevelNum-1];
//    if (levelInfo.highScore <= 0) {
//        levelInfo.unsuccessfulAttempts++;
//        [CCPersistence savePlayer:currentPlayer];
//    }
//    [self hideMenu];
//    [self startLevel:NO];
//}
//
//-(void)jumpedToLevel
//{
//    [CCPersistence savePlayer:currentPlayer];
//    [self restartLevel];
//}

-(void)backgroundChanged
{
    UIImage *backgroundImage = [CCPersistence getImageAssetOfType:ASSET_TYPE_BACKGROUND
                                                          assetId:currentPlayer.settings.currentBackgroundAssetId
                                                         fallback:BUILTIN_BACKGROUND_1];
    [self.view viewWithTag:TAG_BACKGROUND].backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
//    [self.view viewWithTag:TAG_BACKGROUND].backgroundColor = 
//        [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
}

#ifdef MAP_GENERATOR
-(void)generateMapImage
{
    CCTiles *tiles = [CCTiles instance];
    NSString *downloadDir = [CCPersistence persistenceDir:@"mapimage"];

#ifndef MAP_GENERATOR_CURRENT_ONLY
    for (int levelNum = 1; levelNum <= currentPlayer.currentLevelPack.numLevels; levelNum++) {
#else
        int levelNum = currentPlayer.currentLevelPack.currentLevelNum;
#endif
        CCLevel *level = [CCDataReader newLevel:levelNum 
                                      fromAsset:currentPlayer.currentLevelPack.asset];
        UIGraphicsBeginImageContext(CGSizeMake(TILE_SIZE*LEVEL_SIZE, TILE_SIZE*LEVEL_SIZE));
        CGContextRef context = UIGraphicsGetCurrentContext();
        for (int px = 0, tx = 0; tx < LEVEL_SIZE; px += TILE_SIZE, tx++) {
            for (int py = 0, ty = 0; ty < LEVEL_SIZE; py += TILE_SIZE, ty++) {
                short index = layerIndex(tx, ty);
                CGRect r = CGRectMake(px, py, TILE_SIZE, TILE_SIZE);
                byte o = level.topLayer[index];
                if (isTransparent(o)) {
                    // top layer is transparent, draw bottom layer first
                    [tiles drawTile:level.bottomLayer[index] inRect:r context:context];
                }
                [tiles drawTile:o inRect:r context:context];
                
                // todo invisible and blue walls
                // invisible-appear: draw wall with floor in middle
                // invisible-noappear: draw floor with an X
                // blue-real: draw blue wall (no change)
                // blue-fake: draw blue wall with an X
                if (o == INVISIBLE_WALL_APPEAR) {
                    CGContextSaveGState(context);
                    [tiles drawTile:WALL inRect:r context:context];
                    int inset = 8;
                    CGRect clip = CGRectMake(px+inset, py+inset, TILE_SIZE-inset*2, TILE_SIZE-inset*2);
                    CGContextClipToRect(context, clip);
                    [tiles drawTile:FLOOR inRect:r context:context];
//                    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
//                    CGContextSetLineWidth(context, 2);
//                    CGContextStrokeRect(context, clip);
                    CGContextRestoreGState(context);
                } else if (o == INVISIBLE_WALL_NOAPPEAR) {
                    CGFloat s = 3.5;
                    CGContextSaveGState(context);
                    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
                    CGContextSetLineWidth(context, 2.5);
                    CGContextSetLineJoin(context, kCGLineJoinRound);
                    CGContextSetLineCap(context, kCGLineCapRound);
                    CGContextMoveToPoint(context, px+s, py+s);
                    CGContextAddLineToPoint(context, px+TILE_SIZE-s, py+s);
                    CGContextAddLineToPoint(context, px+TILE_SIZE-s, py+TILE_SIZE-s);
                    CGContextAddLineToPoint(context, px+s, py+TILE_SIZE-s);
                    CGContextAddLineToPoint(context, px+s, py+s);
                    CGContextAddLineToPoint(context, px+TILE_SIZE-s, py+TILE_SIZE-s);
                    CGContextMoveToPoint(context, px+TILE_SIZE-s, py+s);
                    CGContextAddLineToPoint(context, px+s, py+TILE_SIZE-s);
                    CGContextStrokePath(context);
                    CGContextRestoreGState(context);
                } else if (o == BLUE_BLOCK_FLOOR) {
                    CGContextSaveGState(context);
                    int inset = 8;
                    CGRect clip = CGRectMake(px+inset, py+inset, TILE_SIZE-inset*2, TILE_SIZE-inset*2);
                    CGContextClipToRect(context, clip);
                    [tiles drawTile:FLOOR inRect:r context:context];
//                    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
//                    CGContextSetLineWidth(context, 2);
//                    CGContextStrokeRect(context, clip);
                    CGContextRestoreGState(context);
                }
                
                // if top level is not transparent and bottom level is not floor,
                // draw part of bottom level
                
                // draw movable
                CCMovable *movable = level.movableLayer[index];
                if (movable) [tiles drawTile:movable.objectCode inRect:r context:context];
                
                // if movable is a block, draw part of bottom level
                if (movable.objectCode == BLOCK && level.topLayer[index] != FLOOR) {
                    CGContextSaveGState(context);
                    int inset = 6;
                    CGRect clip = CGRectMake(px+inset, py+inset, TILE_SIZE-inset*2, TILE_SIZE-inset*2);
                    CGContextClipToRect(context, clip);
                    [tiles drawTile:FLOOR inRect:r context:context];
                    [tiles drawTile:level.topLayer[index] inRect:r context:context];
                    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
                    CGContextSetLineWidth(context, 2);
                    CGContextStrokeRect(context, clip);
                    CGContextRestoreGState(context);
                }
            }
        }
        if (level.chip.objectCode > 0) {
            CGRect r = CGRectMake(level.chip.pixelx, level.chip.pixely, TILE_SIZE, TILE_SIZE);
            [tiles drawTile:level.chip.objectCode inRect:r context:context];
        }
        [level release];

        UIImage *levelImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        // scale it down
//        CGRect newRect = CGRectMake(0, 0, TILE_SIZE*LEVEL_SIZE/2, TILE_SIZE*LEVEL_SIZE/2);
//        CGImageRef imageRef = levelImage.CGImage;
//        CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
//        CGContextRef bitmap = CGBitmapContextCreate(NULL,
//                                                    newRect.size.width,
//                                                    newRect.size.height,
//                                                    CGImageGetBitsPerComponent(imageRef),
//                                                    0,
//                                                    CGImageGetColorSpace(imageRef),
//                                                    bitmapInfo);
//        CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);
//        CGContextDrawImage(bitmap, newRect, imageRef);
//        CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
//        levelImage = [UIImage imageWithCGImage:newImageRef];
//        CGContextRelease(bitmap);
//        CGImageRelease(newImageRef);
    
//        CGRect newRect = CGRectMake(0, 0, TILE_SIZE*LEVEL_SIZE/2, TILE_SIZE*LEVEL_SIZE/2);
//        UIGraphicsBeginImageContext(CGSizeMake(TILE_SIZE*LEVEL_SIZE/2, TILE_SIZE*LEVEL_SIZE/2));
//        CGContextRef context2 = UIGraphicsGetCurrentContext();
//        CGContextDrawImage(context2, newRect, levelImage.CGImage);
//        levelImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();

        // write to file
//        NSData *imageData = UIImagePNGRepresentation(levelImage);
        NSData *imageData = UIImageJPEGRepresentation(levelImage, 0.6);

        NSString *path = [NSString stringWithFormat:@"%@/%@-%03d.jpg", downloadDir, currentPlayer.currentLevelPack.asset.name, levelNum];
        NSLog(@"writing map image to %@", path);
        [imageData writeToFile:path options:NSAtomicWrite error:nil];
        
        UIGraphicsEndImageContext();
#ifndef MAP_GENERATOR_CURRENT_ONLY
    }
#endif
}
#endif

-(void)dealloc
{
    [currentPlayer release];
    [super dealloc];
}

@end
