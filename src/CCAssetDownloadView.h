//  Copyright 2010 StadiaJack. All rights reserved.

#import "CCBaseMenuView.h"

/*!
   Author: StadiaJack
   Date: 3/3/10
 */
@interface CCAssetDownloadView : CCBaseMenuView<UITextFieldDelegate> {
    NSString *_previousEntryKey;
    NSString *_assetType;
    SEL _verifySelector;
}

-(id)initWithFrame:(CGRect)frame 
              menu:(CCMenuView *)_menu
  previousEntryKey:(NSString *)previousEntryKey
      instructions:(NSString *)instructions
         assetType:(NSString *)assetType
      backSelector:(SEL)backSelector
    verifySelector:(SEL)verifySelector;

@end
