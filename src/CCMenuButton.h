//  Copyright 2009 StadiaJack. All rights reserved.

/*!
   Author: StadiaJack
   Date: 10/21/09
 */
@interface CCMenuButton : UIView {
    UIView *background;

    UILabel *titleLabel;

    id clickTarget;
    SEL clickSelector;
    id clickContext;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) id clickTarget;
@property (nonatomic, assign) SEL clickSelector;
@property (nonatomic, assign) id clickContext;

@end
