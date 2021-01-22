//  Copyright 2009 StadiaJack. All rights reserved.

#import "NCheckbox.h"


/*!
   Author: StadiaJack
   Date: 4/25/09
 */
@implementation NCheckbox

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setImage:[UIImage imageNamed:@"check-off.png"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"check-on.png"] forState:UIControlStateSelected];
        [self addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)toggle
{
    self.selected = !self.selected;
}

@end
