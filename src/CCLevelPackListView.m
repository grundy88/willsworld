//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCLevelPackListView.h"
#import "CCController.h"
#import "CCMenuButton.h"
#import "CCPersistence.h"

/*!
   Author: StadiaJack
   Date: 11/23/09
 */

@implementation CCLevelPackTableCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
{
    if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
        progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, self.frame.size.height-20, 100, 15)];
        progressLabel.backgroundColor = [UIColor clearColor];
        progressLabel.font = [UIFont systemFontOfSize:10];
        [mainView addSubview:progressLabel];
        [progressLabel release];
    }
    return self;
}

-(void)setup:(id)input
{
    CCLevelPack *levelPack = input;
    [self setName:[levelPack.asset.name stringByDeletingPathExtension]];
    progressLabel.text = [NSString stringWithFormat:@"%d of %d", levelPack.levelsCompleted, levelPack.numLevels];
}

@end



@implementation CCLevelPackListView

-(id)initWithFrame:(CGRect)frame menu:(CCMenuView *)_menu
{
    return [super initWithFrame:frame 
                           menu:_menu
                      assetType:ASSET_TYPE_LEVELPACK
             downloadButtonText:@"Download new levelpack"
                   backSelector:@selector(showMainPage)
               downloadSelector:@selector(showLevelPackDownload)];
}

-(CCAssetTableCell *)newTableCell:(NSString *)reuseIdentifier
{
    return [[CCLevelPackTableCell alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 45) reuseIdentifier:reuseIdentifier];
}

-(NSMutableArray *)listData
{
    NSArray *assetSections = [super listData];
    NSMutableArray *levelPacksSections = [NSMutableArray arrayWithCapacity:2];
    for (NSArray *assetSection in assetSections) {
        NSMutableArray *levelPacks = [NSMutableArray arrayWithCapacity:assetSection.count];
        [levelPacksSections addObject:levelPacks];
        for (CCPersistedAsset *levelPackAsset in assetSection) {
            CCLevelPack *levelPack = [CCPersistence loadLevelPack:levelPackAsset forPlayer:menu.controller.currentPlayer loadLevels:YES];
//            CCLevelPack *levelPack = [[CCLevelPack alloc] initWithAsset:levelPackAsset loadLevels:NO];
            [levelPacks addObject:levelPack];
//            [levelPack release];
        }
    }
    return levelPacksSections;
}

-(CCPersistedAsset *)assetForIndexPath:(NSIndexPath *)indexPath
{
    CCLevelPack *levelPack = [[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    return levelPack.asset;
}

-(void)didSelectAsset:(CCPersistedAsset *)asset
{
}

-(void)didDeleteAsset:(CCPersistedAsset *)asset
{
    [CCPersistence removePlayerProgress:menu.controller.currentPlayer asset:asset];
    if (menu.controller.currentPlayer.settings.currentLevelpackAssetId == asset.assetId) {
        menu.controller.currentPlayer.settings.currentLevelpackAssetId = -1;
        CCPersistedAsset *asset = [CCPersistence assetOfType:ASSET_TYPE_LEVELPACK assetId:-1];
        CCLevelPack *loadedLevelPack = [CCPersistence loadLevelPack:asset 
                                                          forPlayer:menu.controller.currentPlayer
                                                         loadLevels:YES];
        menu.controller.currentPlayer.currentLevelPack = loadedLevelPack;
        [CCPersistence savePlayerSettings:menu.controller.currentPlayer];
        [menu.controller startLevel:YES savePlayer:YES];
    }
}



//-(void)doRenameOfIndexPath:(NSIndexPath *)indexPath to:(NSString *)name
//{
//    CCLevelPack *levelPack = [[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    BOOL current = [menu.controller.currentPlayer.currentLevelPack.filename isEqualToString:levelPack.filename];
//    [CCPersistence renameLevelPack:levelPack to:name];
//    if (current) {
//        menu.controller.currentPlayer.currentLevelPack.filename = levelPack.filename;
//        menu.controller.currentPlayer.settings.currentLevelPackFile = levelPack.filename;
//        [CCPersistence savePlayerSettings:menu.controller.currentPlayer];
//    }
//}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCLevelPack *levelPack = [[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    CCLevelPack *loadedLevelPack = [CCPersistence loadLevelPack:levelPack.asset 
                                                      forPlayer:menu.controller.currentPlayer
                                                     loadLevels:YES];
    menu.controller.currentPlayer.currentLevelPack = loadedLevelPack;
    menu.controller.currentPlayer.settings.currentLevelpackAssetId = loadedLevelPack.asset.assetId;
    [CCPersistence savePlayerSettings:menu.controller.currentPlayer];
    [menu.controller startLevel:YES savePlayer:NO];
//    [menu.controller hideMenu];
}

//-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        CCLevelPack *levelPack = [[[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] retain];
//        [[data objectAtIndex:1] removeObjectAtIndex:indexPath.row];
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//        if ([CCPersistence deleteDownloadedLevelPack:levelPack.filename forPlayer:menu.controller.currentPlayer]) {
//            [menu.controller startLevel:YES];
//        }
//        [levelPack release];
//    }
//}

@end
