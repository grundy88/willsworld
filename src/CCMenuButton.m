//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCMenuButton.h"
#import "CCSounds.h"
#import "CCController.h"
#import <QuartzCore/QuartzCore.h>

/*!
   Author: StadiaJack
   Date: 10/21/09
 */
@implementation CCMenuButton

@dynamic title;
@synthesize clickTarget;
@synthesize clickSelector;
@synthesize clickContext;

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        background = [[UIView alloc] initWithFrame:CGRectMake(1, 1, self.bounds.size.width-2, self.bounds.size.height-2)];
        background = [[UIView alloc] initWithFrame:self.bounds];
        background.layer.cornerRadius = 10;
        background.layer.masksToBounds = YES;
        background.backgroundColor = [UIColor greenColor];
        background.alpha = 0.2;
        background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:background];
        [background release];
        
        UIView *border = [[UIView alloc] initWithFrame:self.bounds];
        border.layer.cornerRadius = 10;
        border.layer.masksToBounds = YES;
        border.layer.borderWidth = 2;
        border.backgroundColor = [UIColor clearColor];
        border.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:border];
        [border release];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 0, 5)];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.lineBreakMode = UILineBreakModeWordWrap;
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:titleLabel];
        [titleLabel release];
        
        clickTarget = nil;
        clickContext = nil;
        
//        releaseSound = nil;
        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(didRotate:)
//                                                     name:UIDeviceOrientationDidChangeNotification
//                                                   object:nil];
    }
    return self;
}

//-(void)didRotate:(NSNotification *)notification
//{
//    [self setNeedsDisplay];
//}

//-(void)drawRect:(CGRect)rect
//{
//    [title drawInRect:CGRectMake(0, 5, self.bounds.size.width, self.bounds.size.height-5)
//             withFont:[UIFont boldSystemFontOfSize:18] 
//        lineBreakMode:UILineBreakModeWordWrap 
//            alignment:UITextAlignmentCenter];
//
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextSetLineWidth(context, 2);
//    strokeRoundedRect(context, CGRectMake(1, 1, self.bounds.size.width-2, self.bounds.size.height-2), 10, 10, CORNER_ALL);
//}

-(void)setTitle:(NSString *)_title
{
    titleLabel.text = _title;
//    [title release];
//    title = [_title copy];
//    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    background.alpha = 0.5;
    if ([CCController instance].currentPlayer.settings.gameSoundLevel > CCGameSoundsNone) {
        [CCSounds sound:ccsClickDown];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    background.alpha = 0.2;
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 1 && touch.phase == UITouchPhaseEnded) {
        [clickTarget performSelector:clickSelector withObject:clickContext];
    }
    if ([CCController instance].currentPlayer.settings.gameSoundLevel > CCGameSoundsNone) {
        [CCSounds sound:ccsClickUp];
    }
}

//-(void)dealloc
//{
//    [[NSNotificationCenter defaultCenter]removeObserver:self
//                                                   name:UIDeviceOrientationDidChangeNotification
//                                                 object:nil];
//    
//    [super dealloc];
//}

@end
