//  Copyright 2009 StadiaJack. All rights reserved.

@class CCMenuView;

/*!
   Author: StadiaJack
   Date: 11/12/09
 */
@interface CCBaseMenuView : UIView {
    CCMenuView *menu;
}

-(id)initWithFrame:(CGRect)frame menu:(CCMenuView *)_menu;
-(void)layout:(UIInterfaceOrientation)orientation;

@end
