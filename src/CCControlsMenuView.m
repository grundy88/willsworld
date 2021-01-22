//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCControlsMenuView.h"
#import "CCController.h"
#import "CCMenuButton.h"
#import "VPageControl.h"
#import "CCLayoutManager.h"
#import "CCPersistence.h"
#import "NClickableLabel.h"
#import "NCheckbox.h"

#define PREVIEW_W 120
#define PREVIEW_H 180

enum {
    TAG_SCROLL = 1000,
    TAG_PAGE_CONTROL = 1001,
    TAG_RIGHT_BUTTON = 1002,
    TAG_LEFT_BUTTON = 1003,
    TAG_ORIENTATION_CHECKBOX = 1004,
    TAG_TITLE = 1005,
    TAG_HELP = 1006
};

typedef struct {
    NSString *imageFilename;
    CCLayoutType layoutType;
} CCLayoutImage;

/*!
   Author: StadiaJack
   Date: 11/12/09
 */
@implementation CCControlsMenuView

-(void)scrollAnimated:(BOOL)animated
{
    VPageControl *pageControl = (VPageControl *)[self viewWithTag:TAG_PAGE_CONTROL];
    UIScrollView *layoutScroller = (UIScrollView *)[self viewWithTag:TAG_SCROLL];
    [layoutScroller setContentOffset:CGPointMake(width(layoutScroller)*pageControl.currentPage, 0) animated:animated];
    UIButton *leftArrow = (UIButton *)[self viewWithTag:TAG_LEFT_BUTTON];
    UIButton *rightArrow = (UIButton *)[self viewWithTag:TAG_RIGHT_BUTTON];
    leftArrow.enabled = pageControl.currentPage > 0;
    rightArrow.enabled = pageControl.currentPage < pageControl.numberOfPages-1;
    NSArray *layoutData = [currentLayouts objectAtIndex:pageControl.currentPage];

    UIInterfaceOrientation orientation;
    if (currentLayouts == portraitLayouts) {
        menu.controller.currentPlayer.settings.portraitLayout = [[layoutData objectAtIndex:1] intValue];
        orientation = UIInterfaceOrientationPortrait;
    } else {
        menu.controller.currentPlayer.settings.landscapeLayout = [[layoutData objectAtIndex:1] intValue];
        orientation = UIInterfaceOrientationLandscapeLeft;
    }
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
    }
    [[CCLayoutManager instance] layoutView:menu.controller.mainView orientation:orientation player:menu.controller.currentPlayer];
    if (animated) {
        [UIView commitAnimations];
    }
    
    ((UILabel *)[self viewWithTag:TAG_TITLE]).text = [layoutData objectAtIndex:2];
    ((UILabel *)[self viewWithTag:TAG_HELP]).text = [layoutData objectAtIndex:3];
}

-(void)scrollLeft
{
    VPageControl *pageControl = (VPageControl *)[self viewWithTag:TAG_PAGE_CONTROL];
    if (pageControl.currentPage > 0) {
        pageControl.currentPage--;
        [self scrollAnimated:YES];
    }
}

-(void)scrollRight
{
    VPageControl *pageControl = (VPageControl *)[self viewWithTag:TAG_PAGE_CONTROL];
    if (pageControl.currentPage < pageControl.numberOfPages-1) {
        pageControl.currentPage++;
        [self scrollAnimated:YES];
    }
}

-(void)pageControlChange
{
    [self scrollAnimated:YES];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        VPageControl *pageControl = (VPageControl *)[self viewWithTag:TAG_PAGE_CONTROL];
        int page = scrollView.contentOffset.x / scrollView.bounds.size.width;
        if (page != pageControl.currentPage) {
            pageControl.currentPage = page;
            [self scrollAnimated:YES];
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    VPageControl *pageControl = (VPageControl *)[self viewWithTag:TAG_PAGE_CONTROL];
    int page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    if (page != pageControl.currentPage) {
        pageControl.currentPage = page;
        [self scrollAnimated:YES];
    }
}

-(int)pageNumForLayout:(CCLayoutType)layoutType
{
    for (int i = 0; i < currentLayouts.count; i++) {
        if ([[[currentLayouts objectAtIndex:i] objectAtIndex:1] intValue] == layoutType) {
            return i;
        }
    }
    return 0;
}

-(void)layout:(UIInterfaceOrientation)orientation
{
    VPageControl *pageControl = (VPageControl *)[self viewWithTag:TAG_PAGE_CONTROL];
    UIScrollView *layoutScroller = (UIScrollView *)[self viewWithTag:TAG_SCROLL];
    UIButton *leftArrow = (UIButton *)[self viewWithTag:TAG_LEFT_BUTTON];
    UIButton *rightArrow = (UIButton *)[self viewWithTag:TAG_RIGHT_BUTTON];
    UIView *titleLabel = [self viewWithTag:TAG_TITLE];
    UIView *helpLabel = [self viewWithTag:TAG_HELP];
    
    for (UIView *v in [layoutScroller subviews]) {
        [v removeFromSuperview];
    }
    
    int previewWidth;
    int previewHeight;
    int helpWidth;
    int helpHeight;
    int previewY;
    int padding = 20;
    int currentLayout;
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        currentLayouts = portraitLayouts;
        currentLayout = menu.controller.currentPlayer.settings.portraitLayout;
        previewWidth = PREVIEW_W;
        previewHeight = PREVIEW_H;
        helpWidth = self.bounds.size.width-40;
        helpHeight = 50;
        previewY = 40;
    } else {
        currentLayouts = landscapeLayouts;
        currentLayout = menu.controller.currentPlayer.settings.landscapeLayout;
        previewWidth = PREVIEW_H;
        previewHeight = PREVIEW_W;
        helpWidth = self.bounds.size.width-100;
        helpHeight = 30;
        previewY = 5;
    }
    titleLabel.frame = CGRectMake(0, previewY, self.bounds.size.width, 20);
    previewY += 20;
    
    int numLayouts = currentLayouts.count;

    int w = previewWidth+padding*2;
    UIView *layoutOptions = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w*numLayouts, previewHeight)];
    for (int i = 0; i < numLayouts; i++) {
        UIImageView *layout = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[[currentLayouts objectAtIndex:i] objectAtIndex:0]]];
        layout.frame = CGRectMake(i*w+padding, 0, previewWidth, previewHeight);
        [layoutOptions addSubview:layout];
        [layout release];
    }
    
    layoutScroller.frame = CGRectMake((self.bounds.size.width-w)/2, previewY, w, layoutOptions.bounds.size.height);
    layoutScroller.contentSize = layoutOptions.bounds.size;
    [layoutScroller addSubview:layoutOptions];
    [layoutOptions release];
    
    pageControl.center = CGPointMake(self.bounds.size.width/2, layoutScroller.frame.origin.y+layoutScroller.frame.size.height+10);
    pageControl.numberOfPages = numLayouts;
    leftArrow.center = CGPointMake(left(layoutScroller)-width(leftArrow)/2, vertMiddle(layoutScroller));
    rightArrow.center = CGPointMake(right(layoutScroller)+width(leftArrow)/2, vertMiddle(layoutScroller));
    
    helpLabel.frame = CGRectMake((self.bounds.size.width-helpWidth)/2, previewY + previewHeight + 20, helpWidth, helpHeight);
    
    pageControl.currentPage = [self pageNumForLayout:currentLayout];
    
    [self scrollAnimated:NO];
}

-(id)initWithFrame:(CGRect)frame menu:(CCMenuView *)_menu
{
    if (self = [super initWithFrame:frame menu:_menu]) {
        if (!ipad()) {
            portraitLayouts = [[NSArray arrayWithObjects:
                                [NSArray arrayWithObjects:@"layout-portrait-twohandright.png", [NSNumber numberWithInt:CCLayoutTwoHandsRight], @"Two Hands - Right", @"", nil],
                                [NSArray arrayWithObjects:@"layout-portrait-twohandleft.png", [NSNumber numberWithInt:CCLayoutTwoHandsLeft], @"Two Hands - Left", @"", nil],
                                [NSArray arrayWithObjects:@"layout-portrait-onehand.png", [NSNumber numberWithInt:CCLayoutOneHand], @"One Hand", @"", nil],
                                [NSArray arrayWithObjects:@"layout-portrait-dpadright.png", [NSNumber numberWithInt:CCLayoutDPadRight], @"D-Pad Right", @"", nil],
                                [NSArray arrayWithObjects:@"layout-portrait-dpadleft.png", [NSNumber numberWithInt:CCLayoutDPadLeft], @"D-Pad Left", @"", nil],
                                [NSArray arrayWithObjects:@"layout-portrait-touch.png", [NSNumber numberWithInt:CCLayoutTouchLevel], @"Touch Screen", @"Touch anywhere on the screen in the direction you want to move", nil],
                                [NSArray arrayWithObjects:@"layout-portrait-swipe.png", [NSNumber numberWithInt:CCLayoutSwipe], @"Swipe Screen", @"Swipe anywhere on the screen in the direction you want to move (and hold to keep moving)", nil],
                                nil] retain];
        } else {
            portraitLayouts = [[NSArray arrayWithObjects:
                                [NSArray arrayWithObjects:@"layout-portrait-twohandright.png", [NSNumber numberWithInt:CCLayoutTwoHandsRight], @"Two Hands - Right", @"", nil],
                                [NSArray arrayWithObjects:@"layout-portrait-twohandleft.png", [NSNumber numberWithInt:CCLayoutTwoHandsLeft], @"Two Hands - Left", @"", nil],
                                [NSArray arrayWithObjects:@"layout-portrait-onehandright.png", [NSNumber numberWithInt:CCLayoutOneHandRight], @"One Hand - Right", @"", nil],
                                [NSArray arrayWithObjects:@"layout-portrait-onehandleft.png", [NSNumber numberWithInt:CCLayoutOneHandLeft], @"One Hand - Left", @"", nil],
                                [NSArray arrayWithObjects:@"layout-portrait-dpadright.png", [NSNumber numberWithInt:CCLayoutDPadRight], @"D-Pad Right", @"", nil],
                                [NSArray arrayWithObjects:@"layout-portrait-dpadleft.png", [NSNumber numberWithInt:CCLayoutDPadLeft], @"D-Pad Left", @"", nil],
                                [NSArray arrayWithObjects:@"layout-portrait-touch.png", [NSNumber numberWithInt:CCLayoutTouchLevel], @"Touch Screen", @"Touch anywhere on the screen in the direction you want to move", nil],
                                [NSArray arrayWithObjects:@"layout-portrait-swipe.png", [NSNumber numberWithInt:CCLayoutSwipe], @"Swipe Screen", @"Swipe anywhere on the screen in the direction you want to move (and hold to keep moving)", nil],
                                nil] retain];
        }
        landscapeLayouts = [[NSArray arrayWithObjects:
                            [NSArray arrayWithObjects:@"layout-landscape-buttons.png", [NSNumber numberWithInt:CCLayoutLandscapeButtons], @"Two Hands - Landscape", @"", nil],
                            [NSArray arrayWithObjects:@"layout-landscape-twohandright.png", [NSNumber numberWithInt:CCLayoutTwoHandsRight], @"Two Hands - Right", @"", nil],
                            [NSArray arrayWithObjects:@"layout-landscape-twohandleft.png", [NSNumber numberWithInt:CCLayoutTwoHandsLeft], @"Two Hands - Left", @"", nil],
                            [NSArray arrayWithObjects:@"layout-landscape-dpadright.png", [NSNumber numberWithInt:CCLayoutDPadRight], @"D-Pad Right", @"", nil],
                            [NSArray arrayWithObjects:@"layout-landscape-dpadleft.png", [NSNumber numberWithInt:CCLayoutDPadLeft], @"D-Pad Left", @"", nil],
                            [NSArray arrayWithObjects:@"layout-landscape-touch.png", [NSNumber numberWithInt:CCLayoutTouchLevel], @"Touch Screen", @"Touch anywhere on the screen in the direction you want to move", nil],
                            [NSArray arrayWithObjects:@"layout-landscape-swipe.png", [NSNumber numberWithInt:CCLayoutSwipe], @"Swipe Screen", @"Swipe anywhere on the screen in the direction you want to move (and hold to keep moving)", nil],
                            nil] retain];
        
        
        CCMenuButton *backButton = [[CCMenuButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        backButton.title = @"<< Back";
        backButton.clickTarget = self;
        backButton.clickSelector = @selector(saveAndExit);
        backButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:backButton];
        [backButton release];
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.tag = TAG_TITLE;
        titleLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:titleLabel];
        [titleLabel release];
        
        UILabel *helpLabel = [UILabel new]; 
        helpLabel.backgroundColor = [UIColor clearColor];
        helpLabel.textAlignment = UITextAlignmentCenter;
        helpLabel.tag = TAG_HELP;
        helpLabel.numberOfLines = 3;
        helpLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:helpLabel];
        [helpLabel release];
        
        UIScrollView *layoutScroller = [UIScrollView new];
        layoutScroller.pagingEnabled = YES;
        layoutScroller.showsHorizontalScrollIndicator = NO;
        layoutScroller.directionalLockEnabled = YES;
        layoutScroller.delegate = self;
        layoutScroller.tag = TAG_SCROLL;
        [self addSubview:layoutScroller];
        [layoutScroller release];
        
        VPageControl *pageControl = [VPageControl new];
        pageControl.activeColor = [UIColor blackColor];
        pageControl.inactiveColor = [UIColor lightGrayColor];
        pageControl.tag = TAG_PAGE_CONTROL;
        [pageControl addTarget:self action:@selector(pageControlChange) forControlEvents:UIControlEventValueChanged];
        [self addSubview:pageControl];
        [pageControl release];
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *leftArrow = [UIImage imageNamed:@"arrow_left.png"];
        [leftButton setImage:leftArrow forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(scrollLeft) forControlEvents:UIControlEventTouchUpInside];
        leftButton.showsTouchWhenHighlighted = YES;
        leftButton.tag = TAG_LEFT_BUTTON;
        leftButton.frame = CGRectMake(0, 0, leftArrow.size.width*3, leftArrow.size.height*3);
        [self addSubview:leftButton];
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *rightArrow = [UIImage imageNamed:@"arrow_right.png"];
        [rightButton setImage:rightArrow forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(scrollRight) forControlEvents:UIControlEventTouchUpInside];
        rightButton.showsTouchWhenHighlighted = YES;
        rightButton.tag = TAG_RIGHT_BUTTON;
        rightButton.frame = CGRectMake(0, 0, rightArrow.size.width*3, rightArrow.size.height*3);
        [self addSubview:rightButton];
        
        NClickableLabel *orientationLabel = [[NClickableLabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
        orientationLabel.center = CGPointMake(horizMiddle(self), bottom(self)-20);
        orientationLabel.text = @"Lock orientation";
        orientationLabel.textAlignment = UITextAlignmentRight;
        orientationLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        orientationLabel.target = self;
        orientationLabel.selector = @selector(toggleOrientationLockAndCheckbox);
        [self addSubview:orientationLabel];
        [orientationLabel release];
        
        NCheckbox *orientationLock = [[NCheckbox alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        orientationLock.tag = TAG_ORIENTATION_CHECKBOX;
        orientationLock.selected = menu.controller.currentPlayer.settings.lockedOrientation != -1;
        [orientationLock addTarget:self action:@selector(toggleOrientationLock) forControlEvents:UIControlEventTouchUpInside];
        [orientationLabel addSubview:orientationLock];
        [orientationLock release];

        [self layout:[[UIApplication sharedApplication] statusBarOrientation]];
        
    }
    return self;
}

-(void)toggleOrientationLock
{
    if (menu.controller.currentPlayer.settings.lockedOrientation == -1) {
        menu.controller.currentPlayer.settings.lockedOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    } else {
        menu.controller.currentPlayer.settings.lockedOrientation = -1;
    }
}

-(void)toggleOrientationLockAndCheckbox
{
    [self toggleOrientationLock];
    [(NCheckbox *)[self viewWithTag:TAG_ORIENTATION_CHECKBOX] toggle];
}

-(void)saveAndExit
{
    [CCPersistence savePlayerSettings:menu.controller.currentPlayer];
    [menu showMainPage];
}

-(void)dealloc
{
    [portraitLayouts release];
    [landscapeLayouts release];
    [super dealloc];
}

@end
