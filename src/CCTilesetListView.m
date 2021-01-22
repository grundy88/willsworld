//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCTilesetListView.h"
#import "CCPersistence.h"
#import "CCPersistedAsset.h"
#import "CCController.h"
#import "CCTiles.h"

/*!
   Author: StadiaJack
   Date: 11/23/09
 */
@implementation CCTilesetListView

-(id)initWithFrame:(CGRect)frame menu:(CCMenuView *)_menu
{
    return [super initWithFrame:frame 
                           menu:_menu
                      assetType:ASSET_TYPE_TILESET
             downloadButtonText:@"Download new tileset"
                   backSelector:@selector(showAppearance)
               downloadSelector:@selector(showTilesetDownload)];
}

-(void)didSelectAsset:(CCPersistedAsset *)asset
{
    menu.controller.currentPlayer.settings.currentTilesetAssetId = asset.assetId;
    [CCPersistence savePlayerSettings:menu.controller.currentPlayer];
    [[CCTiles instance] loadTileset:asset];
    [menu.controller.mainView tilesetChanged];
    [menu.controller resume];
}

-(void)didDeleteAsset:(CCPersistedAsset *)asset
{
    // reset if deleted the current asset
    if (menu.controller.currentPlayer.settings.currentTilesetAssetId == asset.assetId) {
        menu.controller.currentPlayer.settings.currentTilesetAssetId = -1;
        [CCPersistence savePlayerSettings:menu.controller.currentPlayer];
        CCPersistedAsset *newTileset = [CCPersistence assetOfType:ASSET_TYPE_TILESET assetId:-1];
        [[CCTiles instance] loadTileset:newTileset];
        [menu.controller.mainView tilesetChanged];
    }
}

@end
