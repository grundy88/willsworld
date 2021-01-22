//  Copyright 2009 StadiaJack. All rights reserved.

@class CCController;

/*!
   Author: StadiaJack
   Date: 10/21/09
 */
@interface CCMenuView : UIView {
    CCController *controller;
    UIView *menuContainer;
}

@property (nonatomic, readonly) CCController *controller;

-(id)initWithFrame:(CGRect)frame controller:(CCController *)_controller;
-(void)doLayout:(UIInterfaceOrientation)orientation;
-(void)show;
-(void)showMainPage;

@end
