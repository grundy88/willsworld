//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCPlayer.h"

/*!
   Author: StadiaJack
   Date: 10/21/09
 */
@interface CCLevelInfoTableViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate> {
    id delegate;
    CCPlayer *player;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) CCPlayer *player;

-(void)scrollTo:(NSNumber *)num;

@end
