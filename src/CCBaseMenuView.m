//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCBaseMenuView.h"


/*!
   Author: StadiaJack
   Date: 11/12/09
 */
@implementation CCBaseMenuView

-(id)initWithFrame:(CGRect)frame menu:(CCMenuView *)_menu
{
    self = [super initWithFrame:frame];
    if (self) {
        menu = _menu;
    }
    return self;
}

-(void)layout:(UIInterfaceOrientation)orientation{}

@end
