//  Copyright 2010 StadiaJack. All rights reserved.

#import "CCBaseMenuView.h"

/*!
   Author: StadiaJack
   Date: 3/14/10
 */
@interface CCAssetTableCell : UITableViewCell {
    UILabel *nameLabel;
    UIView *mainView;
    UIView *renameView;
    UITextField *renameField;
    UIButton *renameButton;
    UIButton *cancelButton;
}

@property(nonatomic, readonly) UIView *mainView;
@property(nonatomic, readonly) UIView *renameView;
@property(nonatomic, readonly) UILabel *nameLabel;
@property(nonatomic, readonly) UITextField *renameField;
@property(nonatomic, readonly) UIButton *renameButton;
@property(nonatomic, readonly) UIButton *cancelButton;

-(void)setup:(id)input;
-(void)setName:(NSString *)name;
-(void)flip;

@end

@interface CCAssetListView : CCBaseMenuView<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    NSMutableArray *data;
    BOOL renaming;

    NSString *_assetType;
}

-(id)initWithFrame:(CGRect)frame 
              menu:(CCMenuView *)_menu
         assetType:(NSString *)assetType
downloadButtonText:(NSString *)downloadButtonText
      backSelector:(SEL)backSelector
  downloadSelector:(SEL)downloadSelector;

-(NSMutableArray *)listData;

@end
