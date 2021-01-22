//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCBaseMenuView.h"

/*!
   Author: StadiaJack
   Date: 12/13/09
 */
@interface CCPlayerMenuView : CCBaseMenuView<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    NSMutableArray *players;
    BOOL renaming;
    BOOL adding;
}

@end
