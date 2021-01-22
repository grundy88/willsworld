//  Copyright 2010 StadiaJack. All rights reserved.

#import "CCBackgroundListView.h"
#import "CCPersistence.h"
#import "CCPersistedAsset.h"
#import "CCController.h"


/*!
   Author: StadiaJack
   Date: 4/3/10
 */
@implementation CCBackgroundListView

-(id)initWithFrame:(CGRect)frame menu:(CCMenuView *)_menu
{
    return [super initWithFrame:frame 
                           menu:_menu
                      assetType:ASSET_TYPE_BACKGROUND
             downloadButtonText:@"Download background"
                   backSelector:@selector(showAppearance)
               downloadSelector:@selector(showBackgroundDownload)];
}

-(void)didSelectAsset:(CCPersistedAsset *)asset
{
    menu.controller.currentPlayer.settings.currentBackgroundAssetId = asset.assetId;
    [CCPersistence savePlayerSettings:menu.controller.currentPlayer];
    [menu.controller backgroundChanged];
    [menu.controller resume];
}

-(void)didDeleteAsset:(CCPersistedAsset *)asset
{
    // reset if deleted the current asset
    if (menu.controller.currentPlayer.settings.currentBackgroundAssetId == asset.assetId) {
        menu.controller.currentPlayer.settings.currentBackgroundAssetId = -1;
        [CCPersistence savePlayerSettings:menu.controller.currentPlayer];
        [menu.controller backgroundChanged];
    }
}

@end
