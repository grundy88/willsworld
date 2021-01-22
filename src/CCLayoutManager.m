//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCLayoutManager.h"
#import "CCPlayer.h"
#import "CCCommon.h"
#import "CCMainView.h"
#import "CCBevelView.h"
#import "CCSkin.h"

/*!
   Author: StadiaJack
   Date: 11/4/09
 */
@implementation CCLayoutManager

-(void)itemHorizontal:(CCBevelView *)itemView 
                item1:(UIView *)item1
                item2:(UIView *)item2
                item3:(UIView *)item3
                item4:(UIView *)item4
{
    itemView.bounds = CGRectMake(0, 0, TILE_SIZE*4+BEVEL*2, TILE_SIZE+BEVEL*2);
    int x = BEVEL + TILE_SIZE/2;
    int y = BEVEL + TILE_SIZE/2;
    item1.center = CGPointMake(x, y);
    x += TILE_SIZE;
    item2.center = CGPointMake(x, y);
    x += TILE_SIZE;
    item3.center = CGPointMake(x, y);
    x += TILE_SIZE;
    item4.center = CGPointMake(x, y);
}

-(void)itemVertical:(CCBevelView *)itemView 
              item1:(UIView *)item1
              item2:(UIView *)item2
              item3:(UIView *)item3
              item4:(UIView *)item4
{
    itemView.bounds = CGRectMake(0, 0, TILE_SIZE+BEVEL*2, TILE_SIZE*4+BEVEL*2);
    int x = BEVEL + TILE_SIZE/2;
    int y = BEVEL + TILE_SIZE/2;
    item1.center = CGPointMake(x, y);
    y += TILE_SIZE;
    item2.center = CGPointMake(x, y);
    y += TILE_SIZE;
    item3.center = CGPointMake(x, y);
    y += TILE_SIZE;
    item4.center = CGPointMake(x, y);
}

-(void)itemSquare:(CCBevelView *)itemView 
            item1:(UIView *)item1
            item2:(UIView *)item2
            item3:(UIView *)item3
            item4:(UIView *)item4
{
    itemView.bounds = CGRectMake(0, 0, TILE_SIZE*2+BEVEL*2, TILE_SIZE*2+BEVEL*2);
    int x = BEVEL + TILE_SIZE/2;
    int y = BEVEL + TILE_SIZE/2;
    item1.center = CGPointMake(x, y);
    x += TILE_SIZE;
    item2.center = CGPointMake(x, y);
    x = BEVEL + TILE_SIZE/2;
    y = BEVEL + TILE_SIZE/2 + TILE_SIZE;
    item3.center = CGPointMake(x, y);
    x += TILE_SIZE;
    item4.center = CGPointMake(x, y);
}


-(void)layoutView:(CCMainView *)mainView orientation:(UIInterfaceOrientation)orientation player:(CCPlayer *)player
{
    CCSkin *skin = [CCSkin instance];
    
    int levelContainerSize = TILE_SIZE*NUM_VIEW_TILES+(LEVEL_INSET*2);
    int infoHeight = 34;

    CGRect infoFrame = CGRectMake(3, 0, 314, infoHeight);
    CGRect bevelFrame = CGRectMake(0, 0, levelContainerSize, levelContainerSize);

    CCBevelView *infoBevel = (CCBevelView *)[mainView viewWithTag:TAG_INFO_VIEW];
    CCBevelView *levelBevel = (CCBevelView *)[mainView viewWithTag:TAG_LEVEL_VIEW];
    CCBevelView *keysBevel = (CCBevelView *)[mainView viewWithTag:TAG_KEYS_VIEW];
    CCBevelView *bootsBevel = (CCBevelView *)[mainView viewWithTag:TAG_BOOTS_VIEW];
    UIView *menuButton = [mainView viewWithTag:TAG_MENUBUTTON_VIEW];
    UIView *dpad = [mainView viewWithTag:TAG_DPAD];
    UIView *swipeView = [mainView viewWithTag:TAG_SWIPE_VIEW];

//    infoBevel.transform = CGAffineTransformIdentity;
//    infoBevel.frame = infoFrame;
    levelBevel.transform = CGAffineTransformIdentity;
    levelBevel.bounds = bevelFrame;
    
    int buttonSize = ipad() ? 100 : 73;

    if (UIInterfaceOrientationIsPortrait(orientation)) {
        CCLayoutType layoutType = player.settings.portraitLayout;
//        layoutType = CCLayoutTouchLevel;
        
        // info view (always in the same place)
        infoBevel.transform = CGAffineTransformIdentity;
        infoBevel.frame = infoFrame;
        infoBevel.center = CGPointMake(horizMiddle(mainView), infoHeight/2);
        
        // level view
        if ((layoutType == CCLayoutTwoHandsLeft) ||
            (layoutType == CCLayoutTwoHandsRight) ||
            (layoutType == CCLayoutOneHand) ||
            (layoutType == CCLayoutOneHandLeft) ||
            (layoutType == CCLayoutOneHandRight) ||
            (layoutType == CCLayoutDPadLeft) ||
            (layoutType == CCLayoutDPadRight) ||
            ipad())
        {
            levelBevel.center = CGPointMake(horizMiddle(mainView), infoHeight+1+levelContainerSize/2);
        } else {
            levelBevel.center = CGPointMake(horizMiddle(mainView), mainView.frame.size.height/2);
        }            

        // keys/boots
        keysBevel.transform = CGAffineTransformIdentity;
        bootsBevel.transform = CGAffineTransformIdentity;
        switch (layoutType) {
            case CCLayoutTwoHandsLeft:
            case CCLayoutTwoHandsRight:
                [self itemHorizontal:keysBevel item1:mainView.redKeyView item2:mainView.blueKeyView item3:mainView.yellowKeyView item4:mainView.greenKeyView];
                keysBevel.center = CGPointMake(horizMiddle(mainView), bottom(levelBevel)+3+keysBevel.bounds.size.height/2);
                keysBevel.skipFlags = CCBevelSkipBottom;

                [self itemHorizontal:bootsBevel item1:mainView.iceSkatesView item2:mainView.suctionBootsView item3:mainView.fireBootsView item4:mainView.flippersView];
                bootsBevel.center = CGPointMake(horizMiddle(mainView), bottom(keysBevel)+bootsBevel.bounds.size.height/2-BEVEL*2);
                bootsBevel.skipFlags = CCBevelSkipTop;
                
                break;
            case CCLayoutOneHand:
                [self itemSquare:keysBevel item1:mainView.redKeyView item2:mainView.blueKeyView item3:mainView.yellowKeyView item4:mainView.greenKeyView];
                position(keysBevel, left(levelBevel)+30, bottom(levelBevel)+3);
                keysBevel.skipFlags = 0;
                
                [self itemSquare:bootsBevel item1:mainView.iceSkatesView item2:mainView.suctionBootsView item3:mainView.fireBootsView item4:mainView.flippersView];
                position(bootsBevel, right(levelBevel)-width(bootsBevel)-30, bottom(levelBevel)+3);
                bootsBevel.skipFlags = 0;
                
                break;
            case CCLayoutDPadLeft:
            case CCLayoutOneHandLeft: {
                int margin = ipad()?30:0;
                [self itemHorizontal:keysBevel item1:mainView.redKeyView item2:mainView.blueKeyView item3:mainView.yellowKeyView item4:mainView.greenKeyView];
                position(keysBevel, right(levelBevel)-width(keysBevel)-margin, bottom(mainView)-height(keysBevel)*2);
                keysBevel.skipFlags = CCBevelSkipBottom;
                
                [self itemHorizontal:bootsBevel item1:mainView.iceSkatesView item2:mainView.suctionBootsView item3:mainView.fireBootsView item4:mainView.flippersView];
                position(bootsBevel, left(keysBevel), bottom(keysBevel)-BEVEL*2);
                bootsBevel.skipFlags = CCBevelSkipTop;

                break;
            }
            case CCLayoutDPadRight:
            case CCLayoutOneHandRight: {
                int margin = ipad()?30:0;
                [self itemHorizontal:keysBevel item1:mainView.redKeyView item2:mainView.blueKeyView item3:mainView.yellowKeyView item4:mainView.greenKeyView];
                position(keysBevel, left(levelBevel)+margin, bottom(mainView)-height(keysBevel)*2);
                keysBevel.skipFlags = CCBevelSkipBottom;
                
                [self itemHorizontal:bootsBevel item1:mainView.iceSkatesView item2:mainView.suctionBootsView item3:mainView.fireBootsView item4:mainView.flippersView];
                position(bootsBevel, left(keysBevel), bottom(keysBevel)-BEVEL*2);
                bootsBevel.skipFlags = CCBevelSkipTop;

                break;
            }
            case CCLayoutTouchLevel:
            case CCLayoutSwipe:
                [self itemHorizontal:keysBevel item1:mainView.redKeyView item2:mainView.blueKeyView item3:mainView.yellowKeyView item4:mainView.greenKeyView];
                keysBevel.center = CGPointMake(horizMiddle(mainView), bottom(levelBevel)+10+keysBevel.bounds.size.height/2);
                keysBevel.skipFlags = CCBevelSkipBottom;
                
                [self itemHorizontal:bootsBevel item1:mainView.iceSkatesView item2:mainView.suctionBootsView item3:mainView.fireBootsView item4:mainView.flippersView];
                bootsBevel.center = CGPointMake(horizMiddle(mainView), bottom(keysBevel)+bootsBevel.bounds.size.height/2-BEVEL*2);
                bootsBevel.skipFlags = CCBevelSkipTop;

                break;
        }
        [keysBevel setNeedsDisplay];
        [bootsBevel setNeedsDisplay];
        
        // buttons
        menuButton.transform = CGAffineTransformIdentity;
        mainView.upButton1.alpha = 0;
        mainView.downButton1.alpha = 0;
        mainView.upButton2.alpha = 0;
        mainView.downButton2.alpha = 0;
        mainView.leftButton.alpha = 0;
        mainView.rightButton.alpha = 0;
        dpad.alpha = 0;
        swipeView.alpha = 0;
        [mainView.upButton1 viewWithTag:TAG_BUTTON_IMAGE].alpha = 1;
        [mainView.downButton1 viewWithTag:TAG_BUTTON_IMAGE].alpha = 1;
        [mainView.leftButton viewWithTag:TAG_BUTTON_IMAGE].alpha = 1;
        [mainView.rightButton viewWithTag:TAG_BUTTON_IMAGE].alpha = 1;
        
        switch (layoutType) {
            case CCLayoutTwoHandsLeft:
                mainView.upButton1.alpha = skin.buttonAlpha;
                mainView.downButton1.alpha = skin.buttonAlpha;
                mainView.leftButton.alpha = skin.buttonAlpha;
                mainView.rightButton.alpha = skin.buttonAlpha;
                
                if (ipad()) {
                    mainView.upButton1.frame = CGRectMake(0, 0, buttonSize, buttonSize);
                    mainView.downButton1.frame = CGRectMake(0, 0, buttonSize, buttonSize);
                    mainView.upButton1.center = CGPointMake(left(keysBevel)/2, bottom(levelBevel)+buttonSize/2+1);
                    mainView.downButton1.center = CGPointMake(mainView.upButton1.center.x, bottom(mainView.upButton1)+buttonSize/2+1);
                    mainView.rightButton.frame = CGRectMake(right(levelBevel)-buttonSize, vertMiddle(mainView.upButton1), buttonSize, buttonSize);
                    mainView.leftButton.frame = CGRectMake(left(mainView.rightButton)-buttonSize-1, top(mainView.rightButton), buttonSize, buttonSize);
                } else {
                    mainView.downButton1.frame = CGRectMake(left(levelBevel), bottom(mainView)-buttonSize-1, buttonSize, buttonSize);
                    mainView.upButton1.frame = CGRectMake(left(levelBevel), top(mainView.downButton1)-buttonSize-1, buttonSize, buttonSize);
                    mainView.rightButton.frame = CGRectMake(right(levelBevel)-buttonSize, top(mainView.downButton1), buttonSize, buttonSize);
                    mainView.leftButton.frame = CGRectMake(left(mainView.rightButton)-buttonSize-1, top(mainView.rightButton), buttonSize, buttonSize);
                }
                
                position(menuButton, width(mainView)-width(menuButton)-3, bottom(levelBevel)+3);
                break;
            case CCLayoutTwoHandsRight:
                mainView.upButton1.alpha = skin.buttonAlpha;
                mainView.downButton1.alpha = skin.buttonAlpha;
                mainView.leftButton.alpha = skin.buttonAlpha;
                mainView.rightButton.alpha = skin.buttonAlpha;

                if (ipad()) {
                    mainView.upButton1.frame = CGRectMake(0, 0, buttonSize, buttonSize);
                    mainView.downButton1.frame = CGRectMake(0, 0, buttonSize, buttonSize);
                    mainView.upButton1.center = CGPointMake(right(keysBevel)+(right(mainView)-right(keysBevel))/2, bottom(levelBevel)+buttonSize/2+1);
                    mainView.downButton1.center = CGPointMake(mainView.upButton1.center.x, bottom(mainView.upButton1)+buttonSize/2+1);
                    mainView.leftButton.frame = CGRectMake(left(levelBevel), vertMiddle(mainView.upButton1), buttonSize, buttonSize);
                    mainView.rightButton.frame = CGRectMake(right(mainView.leftButton)+1, top(mainView.leftButton), buttonSize, buttonSize);
                } else {
                    mainView.upButton1.frame = CGRectMake(right(levelBevel)-buttonSize, bottom(levelBevel)+1, buttonSize, buttonSize);
                    mainView.downButton1.frame = CGRectMake(right(levelBevel)-buttonSize, bottom(mainView.upButton1)+1, buttonSize, buttonSize);
                    mainView.leftButton.frame = CGRectMake(left(levelBevel), top(mainView.downButton1), buttonSize, buttonSize);
                    mainView.rightButton.frame = CGRectMake(right(mainView.leftButton)+1, top(mainView.leftButton), buttonSize, buttonSize);
                }
                
                position(menuButton, 3, bottom(levelBevel)+3);
                break;
            case CCLayoutOneHand:
                mainView.upButton1.alpha = skin.buttonAlpha;
                mainView.downButton1.alpha = skin.buttonAlpha;
                mainView.leftButton.alpha = skin.buttonAlpha;
                mainView.rightButton.alpha = skin.buttonAlpha;
                
                mainView.upButton1.frame = CGRectMake(horizMiddle(levelBevel)-buttonSize/2, bottom(levelBevel)+1, buttonSize, buttonSize);
                mainView.downButton1.frame = CGRectMake(left(mainView.upButton1), bottom(mainView.upButton1)+1, buttonSize, buttonSize);
                mainView.leftButton.frame = CGRectMake(left(levelBevel), top(mainView.downButton1), buttonSize, buttonSize);
                mainView.rightButton.frame = CGRectMake(right(levelBevel)-buttonSize, top(mainView.downButton1), buttonSize, buttonSize);

                position(menuButton, 3, bottom(levelBevel)+3);
                break;
            case CCLayoutOneHandLeft:
                mainView.upButton1.alpha = skin.buttonAlpha;
                mainView.downButton1.alpha = skin.buttonAlpha;
                mainView.leftButton.alpha = skin.buttonAlpha;
                mainView.rightButton.alpha = skin.buttonAlpha;
                
                mainView.leftButton.frame = CGRectMake(left(levelBevel), bottom(mainView)-buttonSize-1, buttonSize, buttonSize);
                mainView.downButton1.frame = CGRectMake(right(mainView.leftButton)+1, top(mainView.leftButton), buttonSize, buttonSize);
                mainView.upButton1.frame = CGRectMake(left(mainView.downButton1), top(mainView.downButton1)-buttonSize-1, buttonSize, buttonSize);
                mainView.rightButton.frame = CGRectMake(right(mainView.downButton1)+1, top(mainView.downButton1), buttonSize, buttonSize);
                
                position(menuButton, width(mainView)-width(menuButton)-3, bottom(levelBevel)+3);
                break;
            case CCLayoutOneHandRight:
                mainView.upButton1.alpha = skin.buttonAlpha;
                mainView.downButton1.alpha = skin.buttonAlpha;
                mainView.leftButton.alpha = skin.buttonAlpha;
                mainView.rightButton.alpha = skin.buttonAlpha;
                
                mainView.rightButton.frame = CGRectMake(right(levelBevel)-buttonSize, bottom(mainView)-buttonSize-1, buttonSize, buttonSize);
                mainView.downButton1.frame = CGRectMake(left(mainView.rightButton)-buttonSize-1, top(mainView.rightButton), buttonSize, buttonSize);
                mainView.upButton1.frame = CGRectMake(left(mainView.downButton1), top(mainView.downButton1)-buttonSize-1, buttonSize, buttonSize);
                mainView.leftButton.frame = CGRectMake(left(mainView.downButton1)-buttonSize-1, top(mainView.downButton1), buttonSize, buttonSize);
                
                position(menuButton, 3, bottom(levelBevel)+3);
                break;
            case CCLayoutDPadLeft: {
                dpad.alpha = 0.7;
                float s = bottom(mainView)-bottom(levelBevel);
                dpad.frame = CGRectMake(0, 0, s, s);
                dpad.center = CGPointMake(left(keysBevel)/2, bottom(levelBevel)+(bottom(mainView)-bottom(levelBevel))/2);
                
                position(menuButton, width(mainView)-width(menuButton)-3, bottom(levelBevel)+3);

                break;
            }
            case CCLayoutDPadRight: {
                dpad.alpha = 0.7;
                float s = bottom(mainView)-bottom(levelBevel);
                dpad.frame = CGRectMake(0, 0, s, s);
                dpad.center = CGPointMake(right(keysBevel)+(right(mainView)-right(keysBevel))/2, bottom(levelBevel)+(bottom(mainView)-bottom(levelBevel))/2);
                
                position(menuButton, 3, bottom(levelBevel)+3);

                break;
            }
            case CCLayoutTouchLevel:
                mainView.upButton1.alpha = skin.buttonAlpha;
                mainView.downButton1.alpha = skin.buttonAlpha;
                mainView.leftButton.alpha = skin.buttonAlpha;
                mainView.rightButton.alpha = skin.buttonAlpha;
                
                [mainView.upButton1 viewWithTag:TAG_BUTTON_IMAGE].alpha = 0;
                [mainView.downButton1 viewWithTag:TAG_BUTTON_IMAGE].alpha = 0;
                [mainView.leftButton viewWithTag:TAG_BUTTON_IMAGE].alpha = 0;
                [mainView.rightButton viewWithTag:TAG_BUTTON_IMAGE].alpha = 0;
                
                int w = mainView.bounds.size.width/2-20;
                int h = mainView.bounds.size.height/3;
                mainView.upButton1.frame = CGRectMake(0, 0, mainView.bounds.size.width, h);
                mainView.downButton1.frame = CGRectMake(0, h*2, mainView.bounds.size.width, h);
                mainView.leftButton.frame = CGRectMake(0, h, w, h);
                mainView.rightButton.frame = CGRectMake(mainView.bounds.size.width-w, h, w, h);
                
                position(menuButton, 3, bottom(levelBevel)+3);
                
                break;
            case CCLayoutSwipe:
                swipeView.alpha = 1;
                swipeView.frame = mainView.bounds;
                position(menuButton, 3, bottom(levelBevel)+3);
                
                break;
        }
        
    } else {
        CCLayoutType layoutType = player.settings.landscapeLayout;
//        layoutType = CCLayoutDPadLeft;

        float levelScale = ipad() ?
                    (height(mainView)-height(infoBevel)) / (float)levelContainerSize :
                    1.0;
        // info and level views
        if (!ipad()) {
            if (CGAffineTransformIsIdentity(infoBevel.transform)) {
                infoBevel.transform = CGAffineTransformMakeScale(0.7, 0.7);
            }
        } else {
            if (CGAffineTransformIsIdentity(levelBevel.transform)) {
                levelBevel.transform = CGAffineTransformMakeScale(levelScale, levelScale);
            }
        }
        switch (layoutType) {
            case CCLayoutLandscapeButtons:
            case CCLayoutTouchLevel:
            case CCLayoutSwipe:
                if (ipad()) {
                    infoBevel.center = CGPointMake(horizMiddle(mainView), vertMiddle(infoBevel));
                    levelBevel.center = CGPointMake(horizMiddle(mainView), vertMiddle(mainView) + height(infoBevel)/2);
                } else {
                    infoBevel.center = CGPointMake(horizMiddle(mainView), 12);
                    levelBevel.center = CGPointMake(horizMiddle(mainView), vertMiddle(mainView)+12);
                }
                break;
            case CCLayoutTwoHandsRight:
                buttonSize = ipad() ? 95 : 60;
                levelBevel.center = CGPointMake(width(mainView) - buttonSize - levelContainerSize*levelScale/2,
                                                height(mainView) - levelContainerSize*levelScale/2);
                infoBevel.center = CGPointMake(levelBevel.center.x, top(levelBevel)/2);
                break;
            case CCLayoutTwoHandsLeft:
                buttonSize = ipad() ? 95 : 60;
                levelBevel.center = CGPointMake(buttonSize + levelContainerSize*levelScale/2,
                                                height(mainView) - levelContainerSize*levelScale/2);
                infoBevel.center = CGPointMake(levelBevel.center.x, top(levelBevel)/2);
                break;
            case CCLayoutDPadRight:
                levelBevel.center = CGPointMake(levelContainerSize*levelScale/2,
                                                height(mainView) - levelContainerSize*levelScale/2);
                infoBevel.center = CGPointMake(levelBevel.center.x, top(levelBevel)/2);
                break;
            case CCLayoutDPadLeft:
                levelBevel.center = CGPointMake(width(mainView) - levelContainerSize*levelScale/2,
                                                height(mainView) - levelContainerSize*levelScale/2);
                infoBevel.center = CGPointMake(levelBevel.center.x, top(levelBevel)/2);
                break;
        }
        

        // keys/boots
        switch (layoutType) {
            case CCLayoutLandscapeButtons:
                if (ipad()) {
                    [self itemVertical:keysBevel item1:mainView.redKeyView item2:mainView.blueKeyView item3:mainView.yellowKeyView item4:mainView.greenKeyView];
                    keysBevel.transform = CGAffineTransformMakeScale(0.6, 0.6);
                    keysBevel.center = CGPointMake(left(levelBevel)-width(keysBevel),
                                                   top(levelBevel)+height(levelBevel)/6);
                    keysBevel.skipFlags = 0;
                    
                    [self itemVertical:bootsBevel item1:mainView.iceSkatesView item2:mainView.suctionBootsView item3:mainView.fireBootsView item4:mainView.flippersView];
                    bootsBevel.transform = CGAffineTransformMakeScale(0.6, 0.6);
                    bootsBevel.center = CGPointMake(right(levelBevel)+width(bootsBevel),
                                                    top(levelBevel)+height(levelBevel)/6);
                    bootsBevel.skipFlags = 0;
                } else {
                    [self itemHorizontal:keysBevel item1:mainView.redKeyView item2:mainView.blueKeyView item3:mainView.yellowKeyView item4:mainView.greenKeyView];
                    keysBevel.transform = CGAffineTransformMakeScale(0.6, 0.6);
                    keysBevel.center = CGPointMake(50, 12);
                    keysBevel.skipFlags = 0;
                    
                    [self itemHorizontal:bootsBevel item1:mainView.iceSkatesView item2:mainView.suctionBootsView item3:mainView.fireBootsView item4:mainView.flippersView];
                    bootsBevel.transform = CGAffineTransformMakeScale(0.6, 0.6);
                    bootsBevel.center = CGPointMake(430, 12);
                    bootsBevel.skipFlags = 0;
                }
                
                break;
            case CCLayoutTwoHandsRight:
                [self itemVertical:keysBevel item1:mainView.redKeyView item2:mainView.blueKeyView item3:mainView.yellowKeyView item4:mainView.greenKeyView];
                keysBevel.transform = CGAffineTransformIdentity;
                position(keysBevel, left(levelBevel)/2-width(keysBevel)+BEVEL, top(levelBevel)+20);
                keysBevel.skipFlags = CCBevelSkipRight;
                
                [self itemVertical:bootsBevel item1:mainView.iceSkatesView item2:mainView.suctionBootsView item3:mainView.fireBootsView item4:mainView.flippersView];
                bootsBevel.transform = CGAffineTransformIdentity;
                position(bootsBevel, right(keysBevel)-BEVEL*2, top(levelBevel)+20);
                bootsBevel.skipFlags = CCBevelSkipLeft;
                
                break;
            case CCLayoutTwoHandsLeft:
                [self itemVertical:keysBevel item1:mainView.redKeyView item2:mainView.blueKeyView item3:mainView.yellowKeyView item4:mainView.greenKeyView];
                keysBevel.transform = CGAffineTransformIdentity;
                position(keysBevel, right(levelBevel)+(width(mainView)-right(levelBevel))/2-width(keysBevel)+BEVEL, top(levelBevel)+20);
                keysBevel.skipFlags = CCBevelSkipRight;
                
                [self itemVertical:bootsBevel item1:mainView.iceSkatesView item2:mainView.suctionBootsView item3:mainView.fireBootsView item4:mainView.flippersView];
                bootsBevel.transform = CGAffineTransformIdentity;
                position(bootsBevel, right(keysBevel)-BEVEL*2, top(levelBevel)+20);
                bootsBevel.skipFlags = CCBevelSkipLeft;
                
                break;
            case CCLayoutDPadRight:
                if (ipad()) {
                    [self itemVertical:keysBevel item1:mainView.redKeyView item2:mainView.blueKeyView item3:mainView.yellowKeyView item4:mainView.greenKeyView];
                    keysBevel.transform = CGAffineTransformIdentity;
                    position(keysBevel, right(levelBevel)+(width(mainView)-right(levelBevel))/2-width(keysBevel)+BEVEL, top(levelBevel));
                    keysBevel.skipFlags = CCBevelSkipRight;
                    
                    [self itemVertical:bootsBevel item1:mainView.iceSkatesView item2:mainView.suctionBootsView item3:mainView.fireBootsView item4:mainView.flippersView];
                    bootsBevel.transform = CGAffineTransformIdentity;
                    position(bootsBevel, right(keysBevel)-BEVEL*2, top(levelBevel));
                    bootsBevel.skipFlags = CCBevelSkipLeft;
                } else {
                    [self itemHorizontal:keysBevel item1:mainView.redKeyView item2:mainView.blueKeyView item3:mainView.yellowKeyView item4:mainView.greenKeyView];
                    keysBevel.transform = CGAffineTransformIdentity;
                    keysBevel.center = CGPointMake((width(mainView)-right(levelBevel))/2+right(levelBevel), top(levelBevel)+30);
                    keysBevel.skipFlags = CCBevelSkipBottom;
                    
                    [self itemHorizontal:bootsBevel item1:mainView.iceSkatesView item2:mainView.suctionBootsView item3:mainView.fireBootsView item4:mainView.flippersView];
                    bootsBevel.transform = CGAffineTransformIdentity;
                    position(bootsBevel, left(keysBevel), bottom(keysBevel)-BEVEL*2);
                    bootsBevel.skipFlags = CCBevelSkipTop;
                }
                break;
            case CCLayoutDPadLeft:
                if (ipad()) {
                    [self itemVertical:keysBevel item1:mainView.redKeyView item2:mainView.blueKeyView item3:mainView.yellowKeyView item4:mainView.greenKeyView];
                    keysBevel.transform = CGAffineTransformIdentity;
                    position(keysBevel, left(levelBevel)/2-width(keysBevel)+BEVEL, top(levelBevel));
                    keysBevel.skipFlags = CCBevelSkipRight;
                    
                    [self itemVertical:bootsBevel item1:mainView.iceSkatesView item2:mainView.suctionBootsView item3:mainView.fireBootsView item4:mainView.flippersView];
                    bootsBevel.transform = CGAffineTransformIdentity;
                    position(bootsBevel, right(keysBevel)-BEVEL*2, top(levelBevel));
                    bootsBevel.skipFlags = CCBevelSkipLeft;
                } else {
                    [self itemHorizontal:keysBevel item1:mainView.redKeyView item2:mainView.blueKeyView item3:mainView.yellowKeyView item4:mainView.greenKeyView];
                    keysBevel.transform = CGAffineTransformIdentity;
                    keysBevel.center = CGPointMake(left(levelBevel)/2, top(levelBevel)+30);
                    keysBevel.skipFlags = CCBevelSkipBottom;
                    
                    [self itemHorizontal:bootsBevel item1:mainView.iceSkatesView item2:mainView.suctionBootsView item3:mainView.fireBootsView item4:mainView.flippersView];
                    bootsBevel.transform = CGAffineTransformIdentity;
                    position(bootsBevel, left(keysBevel), bottom(keysBevel)-BEVEL*2);
                    bootsBevel.skipFlags = CCBevelSkipTop;
                }                
                break;
            case CCLayoutTouchLevel:
            case CCLayoutSwipe:
                [self itemVertical:keysBevel item1:mainView.redKeyView item2:mainView.blueKeyView item3:mainView.yellowKeyView item4:mainView.greenKeyView];
                keysBevel.transform = CGAffineTransformIdentity;
                keysBevel.center = CGPointMake(left(levelBevel)/2, top(levelBevel)+height(levelBevel)/4);
                keysBevel.skipFlags = 0;
                
                [self itemVertical:bootsBevel item1:mainView.iceSkatesView item2:mainView.suctionBootsView item3:mainView.fireBootsView item4:mainView.flippersView];
                bootsBevel.transform = CGAffineTransformIdentity;
                bootsBevel.center = CGPointMake(width(mainView)-horizMiddle(keysBevel), vertMiddle(keysBevel));
                bootsBevel.skipFlags = 0;

                break;
        }
        [keysBevel setNeedsDisplay];
        [bootsBevel setNeedsDisplay];

        // buttons
        menuButton.transform = CGAffineTransformIdentity;
        mainView.upButton1.alpha = 0;
        mainView.downButton1.alpha = 0;
        mainView.upButton2.alpha = 0;
        mainView.downButton2.alpha = 0;
        mainView.leftButton.alpha = 0;
        mainView.rightButton.alpha = 0;
        dpad.alpha = 0;
        swipeView.alpha = 0;
        [mainView.upButton1 viewWithTag:TAG_BUTTON_IMAGE].alpha = 1;
        [mainView.downButton1 viewWithTag:TAG_BUTTON_IMAGE].alpha = 1;
        [mainView.leftButton viewWithTag:TAG_BUTTON_IMAGE].alpha = 1;
        [mainView.rightButton viewWithTag:TAG_BUTTON_IMAGE].alpha = 1;
        int buttonSize;

        switch (layoutType) {
            case CCLayoutLandscapeButtons:
                if (ipad()) {
                    buttonSize = 120;
                    
                    mainView.upButton1.alpha = skin.buttonAlpha;
                    mainView.upButton2.alpha = skin.buttonAlpha;
                    mainView.downButton1.alpha = skin.buttonAlpha;
                    mainView.downButton2.alpha = skin.buttonAlpha;
                    mainView.leftButton.alpha = skin.buttonAlpha;
                    mainView.rightButton.alpha = skin.buttonAlpha;
                    
                    mainView.downButton1.frame = CGRectMake(right(levelBevel)+(width(mainView)-right(levelBevel)-buttonSize)/2, bottom(levelBevel)-buttonSize, buttonSize, buttonSize);
                    mainView.rightButton.frame = CGRectMake(left(mainView.downButton1), top(mainView.downButton1)-buttonSize*1.1, buttonSize, buttonSize);
                    mainView.upButton1.frame = CGRectMake(left(mainView.rightButton), top(mainView.rightButton)-buttonSize*1.1, buttonSize, buttonSize);

                    mainView.downButton2.frame = CGRectMake((left(levelBevel)-buttonSize)/2, bottom(levelBevel)-buttonSize, buttonSize, buttonSize);
                    mainView.leftButton.frame = CGRectMake(left(mainView.downButton2), top(mainView.downButton2)-buttonSize*1.1, buttonSize, buttonSize);
                    mainView.upButton2.frame = CGRectMake(left(mainView.leftButton), top(mainView.leftButton)-buttonSize*1.1, buttonSize, buttonSize);

                    position(menuButton, left(levelBevel), 0);
                    menuButton.transform = CGAffineTransformMakeScale(0.8, 0.8);

                } else {
                    buttonSize = 90;

                    mainView.upButton1.alpha = skin.buttonAlpha;
                    mainView.upButton2.alpha = skin.buttonAlpha;
                    mainView.downButton1.alpha = skin.buttonAlpha;
                    mainView.downButton2.alpha = skin.buttonAlpha;
                    mainView.leftButton.alpha = skin.buttonAlpha;
                    mainView.rightButton.alpha = skin.buttonAlpha;

                    mainView.upButton1.frame = CGRectMake(right(levelBevel)+1, top(levelBevel), buttonSize, buttonSize);
                    mainView.rightButton.frame = CGRectMake(right(levelBevel)+1, vertMiddle(levelBevel)-buttonSize/2, buttonSize, buttonSize);
                    mainView.downButton1.frame = CGRectMake(right(levelBevel)+1, bottom(levelBevel)-buttonSize, buttonSize, buttonSize);
                    
                    mainView.upButton2.frame = CGRectMake(1, top(levelBevel), buttonSize, buttonSize);
                    mainView.leftButton.frame = CGRectMake(1, vertMiddle(levelBevel)-buttonSize/2, buttonSize, buttonSize);
                    mainView.downButton2.frame = CGRectMake(1, bottom(levelBevel)-buttonSize, buttonSize, buttonSize);
                    
                    position(menuButton, right(keysBevel)+4, -4);
                    menuButton.transform = CGAffineTransformMakeScale(0.8, 0.8);
                }
                break;
                
            case CCLayoutTwoHandsRight:
                buttonSize = ipad() ? 95 : 60;
                
                mainView.upButton1.alpha = skin.buttonAlpha;
                mainView.downButton1.alpha = skin.buttonAlpha;
                mainView.leftButton.alpha = skin.buttonAlpha;
                mainView.rightButton.alpha = skin.buttonAlpha;
                
                mainView.leftButton.frame = CGRectMake(0, bottom(levelBevel)-buttonSize*2, buttonSize, buttonSize);
                mainView.rightButton.frame = CGRectMake(right(mainView.leftButton)+1, top(mainView.leftButton), buttonSize, buttonSize);
                mainView.downButton1.frame = CGRectMake(right(levelBevel)+1, bottom(levelBevel)-buttonSize*2, buttonSize, buttonSize);
                mainView.upButton1.frame = CGRectMake(right(levelBevel)+1, top(mainView.downButton1)-buttonSize-1, buttonSize, buttonSize);
                
                position(menuButton, 1, 1);
                menuButton.transform = CGAffineTransformIdentity;
                break;
                
            case CCLayoutTwoHandsLeft:
                buttonSize = ipad() ? 95 : 60;
                
                mainView.upButton1.alpha = skin.buttonAlpha;
                mainView.downButton1.alpha = skin.buttonAlpha;
                mainView.leftButton.alpha = skin.buttonAlpha;
                mainView.rightButton.alpha = skin.buttonAlpha;
                
                mainView.leftButton.frame = CGRectMake(right(levelBevel)+1, bottom(levelBevel)-buttonSize*2, buttonSize, buttonSize);
                mainView.rightButton.frame = CGRectMake(right(mainView.leftButton)+1, top(mainView.leftButton), buttonSize, buttonSize);
                mainView.downButton1.frame = CGRectMake(1, bottom(levelBevel)-buttonSize*2, buttonSize, buttonSize);
                mainView.upButton1.frame = CGRectMake(1, top(mainView.downButton1)-buttonSize-1, buttonSize, buttonSize);
                
                menuButton.transform = CGAffineTransformIdentity;
                position(menuButton, mainView.frame.size.width-menuButton.bounds.size.width-1, 1);
                break;
                
            case CCLayoutDPadRight: {
                dpad.alpha = 0.7;
                int dpadSize = width(mainView)-levelContainerSize*levelScale;
                int y = MIN(vertMiddle(levelBevel), bottom(levelBevel)-dpadSize);
                dpad.frame = CGRectMake((width(mainView)-right(levelBevel)-dpadSize)/2+right(levelBevel), y, dpadSize, dpadSize);
                
                menuButton.transform = CGAffineTransformIdentity;
                position(menuButton, width(mainView)-width(menuButton)-1, 1);
                break;
            }
                
            case CCLayoutDPadLeft: {
                dpad.alpha = 0.7;
                int dpadSize = width(mainView)-levelContainerSize*levelScale;
                int y = MIN(vertMiddle(levelBevel), bottom(levelBevel)-dpadSize);
                dpad.frame = CGRectMake((left(levelBevel)-dpadSize)/2, y, dpadSize, dpadSize);
                
                menuButton.transform = CGAffineTransformIdentity;
                position(menuButton, 1, 1);
                break;
            }
                
            case CCLayoutTouchLevel:
                mainView.upButton1.alpha = skin.buttonAlpha;
                mainView.downButton1.alpha = skin.buttonAlpha;
                mainView.leftButton.alpha = skin.buttonAlpha;
                mainView.rightButton.alpha = skin.buttonAlpha;
                
                [mainView.upButton1 viewWithTag:TAG_BUTTON_IMAGE].alpha = 0;
                [mainView.downButton1 viewWithTag:TAG_BUTTON_IMAGE].alpha = 0;
                [mainView.leftButton viewWithTag:TAG_BUTTON_IMAGE].alpha = 0;
                [mainView.rightButton viewWithTag:TAG_BUTTON_IMAGE].alpha = 0;
                
                int w = mainView.bounds.size.width/2-20;
                int h = mainView.bounds.size.height/3;
                mainView.upButton1.frame = CGRectMake(0, 0, mainView.bounds.size.width, h);
                mainView.downButton1.frame = CGRectMake(0, h*2, mainView.bounds.size.width, h);
                mainView.leftButton.frame = CGRectMake(0, h, w, h);
                mainView.rightButton.frame = CGRectMake(mainView.bounds.size.width-w, h, w, h);
                
                menuButton.transform = CGAffineTransformIdentity;
                position(menuButton, 1, 1);
                
                break;
            case CCLayoutSwipe:
                swipeView.alpha = 1;
                swipeView.frame = mainView.bounds;
                menuButton.transform = CGAffineTransformIdentity;
                position(menuButton, 1, 1);
                
                break;
        }
    }
}

+(CCLayoutManager *)instance
{
	static CCLayoutManager *instance = nil;
	@synchronized(self) {
		if (!instance) {
			instance = [CCLayoutManager new];
        }
	}
	return instance;
}

@end
