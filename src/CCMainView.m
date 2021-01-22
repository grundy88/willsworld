
#import "CCMainView.h"
#import "CCController.h"
#import "CCCommon.h"
#import "CCEntity.h"
#import "CCMonster.h"
#import "CCBlock.h"
#import "CCTiles.h"
#import "CCBevelView.h"
#import "CCDigits.h"
#import "CCSkin.h"
#import "CCLayoutManager.h"
#import "CCControlView.h"
#import "CCDPadView.h"
#import "CCSwipeControl.h"
#import "CCSounds.h"

#define HINT_TAG 123

#define SKIPLEVEL_TAG 444
#define SKIPLEVEL_SECONDS 10
#define SKIPLEVEL_COUNT 10

#define FAIL_TITLE @"FAIL"

#define KEYBOARD_ENTRY

@implementation CCMainView

@synthesize redKeyView;
@synthesize blueKeyView;
@synthesize yellowKeyView;
@synthesize greenKeyView;
@synthesize iceSkatesView;
@synthesize suctionBootsView;
@synthesize fireBootsView;
@synthesize flippersView;

@synthesize leftButton;
@synthesize rightButton;
@synthesize upButton1;
@synthesize upButton2;
@synthesize downButton1;
@synthesize downButton2;
@synthesize leftButtonInvisible;
@synthesize rightButtonInvisible;
@synthesize upButtonInvisible;
@synthesize downButtonInvisible;

@synthesize buttonDir;
@synthesize buttonQueue;
@synthesize buttonStack;

-(UIView *)addButtonForDirection:(CCDirection)tag
{
    CCControlView *control = [CCControlView new];
    [self addSubview:control];
    control.mainView = self;
    [control release];
    
    NSString *imageName = nil;
    switch (tag) {
        case NORTH:
            imageName = @"arrow-up.png";
            break;
        case WEST:
            imageName = @"arrow-left.png";
            break;
        case SOUTH:
            imageName = @"arrow-down.png";
            break;
        case EAST:
            imageName = @"arrow-right.png";
            break;
        default:
            return nil;
    }
    UIImageView *button = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    control.userInteractionEnabled = YES;
    control.multipleTouchEnabled = YES;
    button.userInteractionEnabled = NO;
    button.tag = TAG_BUTTON_IMAGE;
    control.alpha = 0.9;
    control.tag = tag;
    button.frame = control.bounds;
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [control addSubview:button];
    [button release];
    return control;
}

-(UILabel *)addInfoLabel:(UIView *)container frame:(CGRect)frame text:(NSString *)text
{
    UILabel *l = [[UILabel alloc] initWithFrame:frame];
    l.backgroundColor = [UIColor clearColor];
    l.textColor = [UIColor redColor];
    l.textAlignment = UITextAlignmentRight;
    l.font = [UIFont boldSystemFontOfSize:14];
    l.text = text;
//    l.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [container addSubview:l];
    [l release];
    return l;
}

-(CCItemView *)addItemView:(UIView *)container 
        objectCode:(byte)objectCode
//                 x:(int)x
//                 y:(int)y
{
    CCItemView *itemView = [CCItemView new];
    itemView.objectCode = objectCode;
    itemView.tag = objectCode;
    itemView.frame = CGRectMake(0, 0, TILE_SIZE, TILE_SIZE);
    [container addSubview:itemView];
    [itemView release];
    return itemView;
}

-(void)checkItemView:(CCItemView *)itemView num:(int)num
{
    if (itemView.num != num) {
        itemView.num = num;
    }
}

-(id)initWithFrame:(CGRect)frame controller:(CCController *)_controller
{
    self = [super initWithFrame:frame];
    if (self) {
        controller = _controller;
//        int bevel = 3;
//        int levelInset = 4;
//        int itemHeight = TILE_SIZE*2+bevel*2;
//        int itemWidth = TILE_SIZE*4+bevel*2;
//        int buttonSize = itemHeight;
//        int levelContainerSize = TILE_SIZE*NUM_VIEW_TILES+(levelInset*2);
//
//        int margin = (frame.size.width-levelContainerSize)/2;
////        int infoHeight = frame.size.height-buttonSize-buttonSize-levelContainerSize-4;
//        int infoHeight = 34;
//        
//        
//        CGRect infoFrame = CGRectMake(3, 0, frame.size.width-6, infoHeight);
//        CGRect bevelFrame = CGRectMake(margin, infoFrame.origin.y+infoFrame.size.height+1, levelContainerSize, levelContainerSize);
//        CGRect levelFrame = CGRectMake(levelInset, levelInset, TILE_SIZE*NUM_VIEW_TILES, TILE_SIZE*NUM_VIEW_TILES);
////        CGRect itemFrame = CGRectMake(margin, bevelFrame.origin.y+bevelFrame.size.height+1, levelContainerSize-buttonSize-margin, itemHeight);
//        CGRect itemFrame = CGRectMake((frame.size.width-itemWidth)/2, 
//                                      bevelFrame.origin.y+bevelFrame.size.height+1, 
//                                      itemWidth, itemHeight);

        CCBevelView *infoBevel = [CCBevelView new];
//        infoBevel.frame = infoFrame;
//        infoBevel.frame = CGRectMake(0, 0, 314, 34);

        infoBevel.tag = TAG_INFO_VIEW;
        infoBevel.bevelWidth = 3;
        infoBevel.autoresizingMask = UIViewAutoresizingNone;
//        infoBevel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:infoBevel];
        [infoBevel release];
        
        CCBevelView *keysBevel = [CCBevelView new];
        keysBevel.bevelWidth = 3;
        keysBevel.alpha = 0.9;
        keysBevel.tag = TAG_KEYS_VIEW;
        [self addSubview:keysBevel];
        [keysBevel release];
        
        CCBevelView *bootsBevel = [CCBevelView new];
        bootsBevel.bevelWidth = 3;
        bootsBevel.alpha = 0.9;
        bootsBevel.tag = TAG_BOOTS_VIEW;
        [self addSubview:bootsBevel];
        [bootsBevel release];
        
        CCBevelView *levelBevel = [CCBevelView new];
        levelBevel.tag = TAG_LEVEL_VIEW;
//        levelBevel.frame = bevelFrame;
        levelBevel.bevelWidth = 3;
        [self addSubview:levelBevel];
        [levelBevel release];
        
        // ---------------------------------------------------------
        // Level

        levelView = [CCLevelView new];
        levelView.frame = CGRectMake(LEVEL_INSET, LEVEL_INSET, TILE_SIZE*NUM_VIEW_TILES, TILE_SIZE*NUM_VIEW_TILES);
        
        [levelBevel addSubview:levelView];
        
        [levelView release];
        
        // ---------------------------------------------------------
        // Info
        
        int infox = 3;
        UILabel *l = [self addInfoLabel:infoBevel frame:CGRectMake(infox, 0, 46, infoBevel.bounds.size.height) text:@"LEVEL"];
        l.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        infox += 47;
        levelNumView = [CCDigitView new];
        levelNumView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        levelNumView.frame = CGRectMake(infox,
                                        (int)(infoBevel.bounds.size.height-levelNumView.frame.size.height)/2, 
                                        levelNumView.frame.size.width, levelNumView.frame.size.height);
        [infoBevel addSubview:levelNumView];
        [levelNumView release];
        
        infox += 55;
        [self addInfoLabel:infoBevel frame:CGRectMake(infox, 2, 46, 15) text:@"TIME"];
        [self addInfoLabel:infoBevel frame:CGRectMake(infox, 17, 46, 15) text:@"LEFT"];
        infox += 47;
        timeLeftView = [CCDigitView new];
        timeLeftView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        timeLeftView.frame = CGRectMake(infox,
                                        (int)(infoBevel.bounds.size.height-timeLeftView.frame.size.height)/2, 
                                        timeLeftView.frame.size.width, timeLeftView.frame.size.height);
        timeLeftView.yellowCutoff = 15;
        [infoBevel addSubview:timeLeftView];
        [timeLeftView release];
        
        infox += 55;
        treasureNameLabel = [self addInfoLabel:infoBevel frame:CGRectMake(infox, 2, 46, 15) text:controller.currentPlayer.settings.treasureName];
        [self addInfoLabel:infoBevel frame:CGRectMake(infox, 17, 46, 15) text:@"LEFT"];
        infox += 47;
        chipsLeftView = [CCDigitView new];
        chipsLeftView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        chipsLeftView.frame = CGRectMake(infox, 
                                         (int)(infoBevel.bounds.size.height-chipsLeftView.frame.size.height)/2, 
                                         chipsLeftView.frame.size.width, chipsLeftView.frame.size.height);
        chipsLeftView.yellowCutoff = 0;
        [infoBevel addSubview:chipsLeftView];
        [chipsLeftView release];
        

        // ---------------------------------------------------------
        // Items
        redKeyView = [self addItemView:keysBevel objectCode:RED_KEY];
        blueKeyView = [self addItemView:keysBevel objectCode:BLUE_KEY];
        yellowKeyView = [self addItemView:keysBevel objectCode:YELLOW_KEY];
        greenKeyView = [self addItemView:keysBevel objectCode:GREEN_KEY];
        iceSkatesView = [self addItemView:bootsBevel objectCode:ICE_SKATES];
        suctionBootsView = [self addItemView:bootsBevel objectCode:SUCTION_BOOTS];
        fireBootsView = [self addItemView:bootsBevel objectCode:FIRE_BOOTS];
        flippersView = [self addItemView:bootsBevel objectCode:FLIPPERS];
        
        // ---------------------------------------------------------
        // Buttons
        
        // one handed
        
        // two handed
        upButton1 = [self addButtonForDirection:NORTH];
        upButton2 = [self addButtonForDirection:NORTH];
        rightButton = [self addButtonForDirection:EAST];
        downButton1 = [self addButtonForDirection:SOUTH];
        downButton2 = [self addButtonForDirection:SOUTH];
        leftButton = [self addButtonForDirection:WEST];
        
        CCDPadView *dpad = [CCDPadView new];
        dpad.tag = TAG_DPAD;
        dpad.mainView = self;
        [self addSubview:dpad];
        [dpad release];
        
        CCSwipeControl *swipeControl = [CCSwipeControl new];
        swipeControl.tag = TAG_SWIPE_VIEW;
        swipeControl.mainView = self;
        [self addSubview:swipeControl];
        [swipeControl release];
        
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [menuButton setImage:[UIImage imageNamed:@"menu-button.png"] forState:UIControlStateNormal];
        menuButton.frame = CGRectMake(0, 0, 30, 30);
        menuButton.alpha = 0.8;
        menuButton.tag = TAG_MENUBUTTON_VIEW;
        menuButton.showsTouchWhenHighlighted = TRUE;
        [menuButton addTarget:[CCSounds instance] action:@selector(playClickDown) forControlEvents:UIControlEventTouchDown];
        [menuButton addTarget:[CCSounds instance] action:@selector(playClickUp) forControlEvents:UIControlEventTouchUpInside];
        [menuButton addTarget:controller action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:menuButton];
        
        splashView = [CCBevelView new];
        splashView.fillColor = KRGBColorMake(0, 0, 0, 1);
        [levelView addSubview:splashView];
        [splashView release];

        hintView = [UIView new];
        int w = 260;
        int h = 130;
        hintView.frame = CGRectMake((width(levelView)-w)/2, -18, w, h);
        hintView.hidden = YES;
        hintView.backgroundColor = [UIColor clearColor];
        hintView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [levelView addSubview:hintView];
        [hintView release];
        hintContainer = [CCBevelView new];
        hintContainer.userInteractionEnabled = NO;
        hintContainer.frame = hintView.bounds;
        hintContainer.fillColor = KRGBColorMake(0, 0, 0, 1);
        hintContainer.alpha = 0.7;
        hintContainer.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [hintView addSubview:hintContainer];
        [hintContainer release];
        
        buttonQueue = [NSMutableArray new];
        buttonStack = malloc(sizeof(CCDirection) * 4);
        
        gameTimer = nil;
        self.multipleTouchEnabled = YES;
        
        [[CCLayoutManager instance] layoutView:self orientation:UIInterfaceOrientationPortrait player:controller.currentPlayer];
        
#ifdef FRAME_RATE_DEBUG
        frameCount = 0;
        totalTime = 0;
#endif

#if TARGET_IPHONE_SIMULATOR
#ifdef DEBUG
#ifdef KEYBOARD_ENTRY
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, bottom(menuButton)+10, 50, 25)];
        textField.borderStyle = UITextBorderStyleBezel;
        textField.backgroundColor = [UIColor whiteColor];
        textField.delegate = self;
        [self addSubview:textField];
        [textField release];
#endif
#endif
#endif
    }
    return self;
}

// -----------------------------------------------------------------

#if TARGET_IPHONE_SIMULATOR
#ifdef DEBUG
#ifdef KEYBOARD_ENTRY
-(void)hideKeyboard
{
    for (UIWindow *w in [[UIApplication sharedApplication] windows]) {
//        NSLog(@"- %s %s %f,%f  %fx%f", NAMEOF(w), w.keyWindow?"yes":"no", w.frame.origin.x, w.frame.origin.y, w.frame.size.width, w.frame.size.height);
        if (!w.keyWindow) {
            w.hidden = YES;
        }
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    NSLog(@"textFieldDidBeginEditing");
//    textField.hidden = YES;
    [self performSelector:@selector(hideKeyboard) withObject:nil afterDelay:0.01];
}

- (BOOL)textField:(UITextField *)textField 
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
//    NSLog(@"shouldChangeCharactersInRange %@", string);
    CCDirection dir = NONE;
    switch ([string characterAtIndex:0]) {
        case 0xF700:
        case 'i':
            dir = NORTH;
            break;
        case 0xF701:
        case 'k':
            dir = SOUTH;
            break;
        case 0xF702:
        case 'j':
            dir = WEST;
            break;
        case 0xF703:
        case 'l':
            dir = EAST;
            break;
    }
    if (dir != NONE) {
        [self submitButtonDir:dir addToQueue:YES];
        [self performSelector:@selector(buttonUp:) withObject:[NSNumber numberWithInt:dir] afterDelay:0.1];
    }
    return NO;
}

-(void)buttonUp:(NSNumber *)n
{
    [self removeButtonDir:[n intValue]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.hidden = NO;
}
#endif
#endif
#endif

// -----------------------------------------------------------------

-(void)startMenuButtonPulse
{
    UIView *menuButton = [self viewWithTag:TAG_MENUBUTTON_VIEW];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationRepeatCount:5000];
    [UIView setAnimationRepeatAutoreverses:TRUE];
    [UIView setAnimationDuration:0.75];
    menuButton.transform = CGAffineTransformMakeScale(1.4, 1.4);
    [UIView commitAnimations];
}

-(void)stopMenuButtonPulse
{
    UIView *menuButton = [self viewWithTag:TAG_MENUBUTTON_VIEW];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.75];
    menuButton.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
}

//-(CGPoint)viewOffset
//{
//    int x = level.chip.pixelx-(4*TILE_SIZE);
//    int y = level.chip.pixely-(4*TILE_SIZE);
//    if (x < 0) x = 0;
//    else if (x > TILE_SIZE*(LEVEL_SIZE-NUM_VIEW_TILES)) x = TILE_SIZE*(LEVEL_SIZE-NUM_VIEW_TILES);
//    if (y < 0) y = 0;
//    else if (y > TILE_SIZE*(LEVEL_SIZE-NUM_VIEW_TILES)) y = TILE_SIZE*(LEVEL_SIZE-NUM_VIEW_TILES);
//    return CGPointMake(x, y);
//}

-(void)setLevelViewOffset
{
    int x = level.chip.pixelx-(4*TILE_SIZE);
    int y = level.chip.pixely-(4*TILE_SIZE);
    if (x < 0) x = 0;
    else if (x > TILE_SIZE*(LEVEL_SIZE-NUM_VIEW_TILES)) x = TILE_SIZE*(LEVEL_SIZE-NUM_VIEW_TILES);
    if (y < 0) y = 0;
    else if (y > TILE_SIZE*(LEVEL_SIZE-NUM_VIEW_TILES)) y = TILE_SIZE*(LEVEL_SIZE-NUM_VIEW_TILES);
    levelView.offsetx = x;
    levelView.offsety = y;
}

-(NSTimeInterval)getGameClock
{
    if (durationCheckpoint > 0) {
        NSTimeInterval d = [NSDate timeIntervalSinceReferenceDate];
        return duration + (d - durationCheckpoint);
    } else {
        return duration;
    }
}

-(void)setGameClockCheckpoint
{
    duration = [self getGameClock];
    durationCheckpoint = [NSDate timeIntervalSinceReferenceDate];
}

-(void)startGameClock
{
    [self setGameClockCheckpoint];
}

-(void)stopGameClock
{
    duration = [self getGameClock];
    durationCheckpoint = -1;
}

-(void)startLevel:(CCLevel *)_level firstTime:(BOOL)firstTime
{
    [level release];
    level = [_level retain];
    
    levelView.level = level;
    [self setLevelViewOffset];
//    levelView.offset = [self viewOffset];
    level.chip.mainView = self;

    levelNumView.num = level.number;
    timeLeftView.num = level.timeLimit > 0 ? level.timeLimit : -1;
    chipsLeftView.num = level.chipCount;

    for (UIView *v in splashView.subviews) {
        [v removeFromSuperview];
    }
    CGSize titleSize = [level.title sizeWithFont:[UIFont boldSystemFontOfSize:20]];
    NSString *password = [NSString stringWithFormat:@"Password: %@", level.password];
    CGSize passwordSize = [password sizeWithFont:[UIFont boldSystemFontOfSize:20]];
    int w = MIN(MAX(titleSize.width, passwordSize.width) + 25, self.bounds.size.width);
    int h = titleSize.height*2 + 10;
    splashView.frame = CGRectMake((levelView.bounds.size.width-w)/2, levelView.bounds.size.height-85, w, h);
    
    UILabel *l = [self addInfoLabel:splashView 
                              frame:CGRectMake(splashView.bevelWidth, splashView.bevelWidth, w-splashView.bevelWidth*2, h/2)
                               text:level.title];
    l.textColor = [UIColor yellowColor];
    l.textAlignment = UITextAlignmentCenter;
    l.font = [UIFont boldSystemFontOfSize:20];
    l.adjustsFontSizeToFitWidth = YES;
    l.minimumFontSize = 12;
    l = [self addInfoLabel:splashView 
                     frame:CGRectMake(splashView.bevelWidth, splashView.bounds.size.height/2, w-splashView.bevelWidth*2, h/2)
                      text:[NSString stringWithFormat:@"Password: %@", level.password]];
    l.textColor = [UIColor yellowColor];
    l.textAlignment = UITextAlignmentCenter;
    l.font = [UIFont boldSystemFontOfSize:20];
    splashView.hidden = NO;
    
    for (UIView *v in hintView.subviews) {
        if (v != hintContainer) {
            [v removeFromSuperview];
        }
    }
    //    CGSize hintSize = [level.hint sizeWithFont: [UIFont italicSystemFontOfSize:18] constrainedToSize:CGSizeMake(260, 1000)];
//    NSLog(@"%f %f", hintSize.width, hintSize.height);
//    hintView.frame = CGRectMake((self.frame.size.width-hintSize.width+4)/2, 25, hintSize.width+4, hintSize.height+4);
    l = [self addInfoLabel:hintView 
                     frame:CGRectMake(hintContainer.bevelWidth+2, hintContainer.bevelWidth+2, hintContainer.bounds.size.width-hintContainer.bevelWidth*2-4, hintContainer.bounds.size.height-hintContainer.bevelWidth*2-4)
                      text:level.hint];
    l.textColor = [UIColor cyanColor];
    l.textAlignment = UITextAlignmentCenter;
    l.numberOfLines = 0;
    l.font = [UIFont italicSystemFontOfSize:18];
    
    paused = NO;
    
    buttonDir = NONE;
    [buttonQueue removeAllObjects];
    for (int i = 0; i < 4; i++) buttonStack[i] = NONE;

    [levelView setNeedsDisplay];
    [levelNumView setNeedsDisplay];
    [chipsLeftView setNeedsDisplay];
    [timeLeftView setNeedsDisplay];
    redKeyView.num = 0;
    blueKeyView.num = 0;
    yellowKeyView.num = 0;
    greenKeyView.num = 0;
    iceSkatesView.num = 0;
    suctionBootsView.num = 0;
    fireBootsView.num = 0;
    flippersView.num = 0;
    
    if (firstTime) {
        deathCount = 0;
        skipDeathCount = 0;
    }
    duration = 0;
    durationCheckpoint = -1;
    
    halfStepCount = 0;
    level.monsterWait = YES;

    [level.chip start];
    for (CCMonster *monster in level.monsters) {
        [monster start];
    }
    for (CCBlock *block in level.blocks) {
        [block start];
    }

    hintView.hidden = !level.showHint;
}

-(void)pause
{
    [self stopGameClock];
    paused = YES;
    [gameTimer invalidate];
    gameTimer = nil;
}

-(void)resume
{
    paused = NO;
    if (splashView.hidden) {
        gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/FRAME_RATE
                                                     target:self
                                                   selector:@selector(gameLoop)
                                                   userInfo:nil
                                                    repeats:YES];
        [self startGameClock];
    }
}

-(void)tilesetChanged
{
    [levelView setNeedsDisplay];
    [redKeyView setNeedsDisplay];
    [blueKeyView setNeedsDisplay];
    [yellowKeyView setNeedsDisplay];
    [greenKeyView setNeedsDisplay];
    [iceSkatesView setNeedsDisplay];
    [suctionBootsView setNeedsDisplay];
    [fireBootsView setNeedsDisplay];
    [flippersView setNeedsDisplay];
}

-(void)setTreasureName:(NSString *)treasureName
{
    treasureNameLabel.text = treasureName;
}


// -----------------------------------------------------------------------------------------------
#pragma mark -

-(int)findDirInButtonStack:(CCDirection)dir
{
    int p = 0;
    for (; p < 4 && buttonStack[p] != dir; p++);
    if (p >= 4) p = -1;
    return p;
}

static void printButtonStack(CCDirection buttonStack[4]) {
    printf("button stack: ");
    for (int i = 0; i < 4 && buttonStack[i] != NONE; i++) {
        if (i > 0) printf(", ");
        CCDirection d = buttonStack[i];
        printf("%s", dirName(d));
    }
    printf("\n");
}

-(void)removeDirFromQueue:(CCDirection)dir
{
    for (int i = 0; i < buttonQueue.count; i++) {
        if ([[buttonQueue objectAtIndex:i] intValue] == dir) {
            [buttonQueue removeObjectAtIndex:i];
            return;
        }
    }
}

-(void)submitButtonDir:(CCDirection)dir addToQueue:(BOOL)queue
{
#if BUTTON_DEBUG >= 1 && BUTTON_DEBUG <= 2
    printf("submit: %s\n", dirName(dir));
#endif
    if (isDir(dir)) {
        buttonDir = dir;
        
        int p = [self findDirInButtonStack:dir];
        if (p == -1) p = 3;
        for (int i = p; i > 0; i--) {
            buttonStack[i] = buttonStack[i-1];
        }
        buttonStack[0] = dir;
#if BUTTON_DEBUG == 1
        printButtonStack(buttonStack);
#endif
        
        if (queue && !level.chip.trapped || (level.chip.trapped && buttonQueue.count == 0)) {
            [buttonQueue addObject:[NSNumber numberWithInt:buttonDir]];
        }
    } else {
        buttonDir = NONE;
    }
}

-(void)removeButtonDir:(CCDirection)dir
{
#if BUTTON_DEBUG >= 1 && BUTTON_DEBUG <= 2
    printf("remove: %s\n", dirName(dir));
#endif
    BOOL compacting = NO;
    for (int i = 0; i < 4 && buttonStack[i] != NONE; i++) {
        if (buttonStack[i] == dir) compacting = YES;
        if (compacting) {
            if (i < 3) {
                buttonStack[i] = buttonStack[i+1];
            } else {
                buttonStack[i] = NONE;
            }
        }
    }
    buttonDir = buttonStack[0];
#if BUTTON_DEBUG == 1
    printButtonStack(buttonStack);
#endif
}

-(void)clearButtonStack
{
    for (int i = 0; i < 4; i++) {
        buttonStack[i] = NONE;
    }
    buttonDir = NONE;
}

-(CCDirection)getControlDir:(BOOL)peek
{
    CCDirection d = NONE;
    if (buttonDir || buttonQueue.count > 0) {
        if (buttonQueue.count > 0) {
            d = [[buttonQueue objectAtIndex:0] intValue];
            level.chip.playOof = YES;
#if BUTTON_DEBUG >= 1 && BUTTON_DEBUG <= 3
            printf("chip moving %s from button queue\n", dirName(d));
#endif
        } else {
            d = buttonDir;
#if BUTTON_DEBUG >= 1 && BUTTON_DEBUG <= 3
                printf("chip moving %s from buttonDir\n", dirName(d));
//            } else {
//                printf("chip skipping buttonDir move\n");
#endif
//            }
        }
        
        if (!peek) [self removeDirFromQueue:d];
#if BUTTON_DEBUG == 1
        printf("button queue: ");
        for (NSNumber *n in buttonQueue) printf(" %s", dirName([n intValue]));
        printf("\n");
#endif
    }
    return d;
}

-(CCDirection)getControlDir
{
    return [self getControlDir:NO];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!paused) {
//        if (!gameTimer) {
        if (!splashView.hidden) {
            splashView.hidden = YES;
            [controller levelStarted];
            [self stopMenuButtonPulse];
            [self resume];
        }
        
        if (hintView == [[touches anyObject] view]) {
            hintView.hidden = YES;
        }
    }
}

-(void)initiateMoves
{
    [level.chip move];
    
    for (CCMonster *monster in level.monsters) {
        [monster move];
    }

    for (CCBlock *block in level.blocks) {
        [block move];
    }
}

-(void)animateMoves
{
    [level.chip animate];
    
    for (CCMonster *monster in level.monsters) {
        [monster animate];
    }
    
    for (CCBlock *block in level.blocks) {
        [block animate];
    }
    
    [self setLevelViewOffset];
//    levelView.offset = [self viewOffset];
}

-(void)doPostMoves
{
    for (CCBlock *block in level.blocks) {
        [block postMove];
    }
    for (CCMonster *monster in level.monsters) {
        [monster postMove];
    }
    if ([level.chip postMove]) {
        hintView.hidden = !level.showHint;
    } else {
        [level.chip checkDirReset];
    }
}

-(void)gameLoop
{
    /*
     0: if not trapped and not moving - start next move + animate
     1: if moving - animate
     2: if moving - animate
     3: if moving - animate + post move
    */
    
#ifdef FRAME_RATE_DEBUG
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
#endif

    int secondsElapsed = [self getGameClock];
    
    if (level.movePhase == 0) {
        [self initiateMoves];
        [self animateMoves];
        
        level.movePhase++;
        
//        if (level.chip.sliding && level.died) {
//            [self stopGameClock];
//            [gameTimer invalidate];
//            gameTimer = nil;
//            deathCount++;
//            if ([self getGameClock] > 10) {
//                skipDeathCount++;
//            } else {
//                skipDeathCount = 0;
//            }
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:level.died delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
//            [alert release];
//        }

    } else if (level.movePhase == (level.numPhases - 1)) {
        [self animateMoves];
        [self doPostMoves];
        
        [level addRemoveMovables];
        
        halfStepCount++;
        if (halfStepCount > 3) halfStepCount = 0;
        level.monsterWait = (halfStepCount < 2);

        level.movePhase = 0;

        
//        if (level.died) {
//            [self stopGameClock];
//            [gameTimer invalidate];
//            gameTimer = nil;
//            deathCount++;
//            if ([self getGameClock] > 10) {
//                skipDeathCount++;
//            } else {
//                skipDeathCount = 0;
//            }
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:level.died delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
//            [alert release];
//        }
        if (level.exited) {
            [self stopGameClock];
            [gameTimer invalidate];
            gameTimer = nil;
            
            int timeLeft = 0;
//            if (level.timeLimit > 0) timeLeft = level.timeLimit - secondsElapsed;
            if (level.timeLimit > 0) timeLeft = timeLeftView.num;
            
            int levelBonus = controller.currentPlayer.currentLevelPack.currentLevelNum * 500;
            if (!controller.currentPlayer.settings.noDeathPenalty) {
                for (int i = 0; i < deathCount && levelBonus >= 500; i++) {
                    levelBonus *= 0.8;
                }
            }
            [controller saveTime:timeLeft levelBonus:levelBonus];
            
            if (controller.currentPlayer.settings.gameSoundLevel > CCGameSoundsNone) {
                [CCSounds sound:ccsLevelComplete];
            }
        }
        
        if (chipsLeftView.num != level.chipCount) {
            chipsLeftView.num = level.chipCount;
            [chipsLeftView setNeedsDisplay];
        }
        
        [self checkItemView:redKeyView num:level.numRedKeys];
        [self checkItemView:blueKeyView num:level.numBlueKeys];
        [self checkItemView:yellowKeyView num:level.numYellowKeys];
        [self checkItemView:greenKeyView num:level.greenKey?1:0];
        [self checkItemView:iceSkatesView num:level.iceSkates?1:0];
        [self checkItemView:suctionBootsView num:level.suctionBoots?1:0];
        [self checkItemView:fireBootsView num:level.fireBoots?1:0];
        [self checkItemView:flippersView num:level.flippers?1:0];
        
//        NSLog(@"chip: %d %d", level.chip.x, level.chip.y);
//        CCBlock *b = [level.blocks objectAtIndex:0];
//        NSLog(@"block: %d %d", b.x, b.y);
//        [NSThread sleepForTimeInterval:0.5];
        
    } else {
        [self animateMoves];
        level.movePhase++;
    }
    
    if (level.died && gameTimer) {
        [self stopGameClock];
        [gameTimer invalidate];
        gameTimer = nil;
        deathCount++;
        if ([self getGameClock] > SKIPLEVEL_SECONDS) {
            skipDeathCount++;
        } else {
            skipDeathCount = 0;
        }
        [level.chip sound:ccsDied];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:FAIL_TITLE message:level.died delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = TAG_FAIL_ALERT;
        [alert show];
        [alert release];
    }

    [levelView setNeedsDisplay];

    if (!level.died && !level.exited) {
        if (level.timeLimit > 0) {
            if (timeLeftView.num != level.timeLimit - secondsElapsed) {
                timeLeftView.num = level.timeLimit - secondsElapsed;
                [timeLeftView setNeedsDisplay];
                if (timeLeftView.num <= timeLeftView.yellowCutoff) {
                    if (controller.currentPlayer.settings.gameSoundLevel > CCGameSoundsNone) {
                        [CCSounds sound:ccsClickDown];
                    }
                }
            }
            if (secondsElapsed >= level.timeLimit) {
                [gameTimer invalidate];
                gameTimer = nil;
                if (controller.currentPlayer.settings.gameSoundLevel > CCGameSoundsNone) {
                    [CCSounds sound:ccsTimeOver];
                }
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:FAIL_TITLE message:MESSAGE_TIME delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                alert.tag = TAG_FAIL_ALERT;
                [alert show];
                [alert release];
            }
        }
    }

#ifdef FRAME_RATE_DEBUG
    NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
    frameCount++;
    totalTime += (end - start);
    if (frameCount % 100 == 0) {
        NSLog(@"avg time in game loop: %f", totalTime / frameCount);
    }
#endif
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == SKIPLEVEL_TAG) {
        // buttonIndex 0 = NO, else YES
        [controller died:(buttonIndex == 1)];
    } else if (skipDeathCount == SKIPLEVEL_COUNT && controller.currentPlayer.currentLevelPack.currentLevelNum < controller.currentPlayer.currentLevelPack.numLevels) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:MESSAGE_SKIPLEVEL delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = SKIPLEVEL_TAG;
        [alert show];
        [alert release];
    } else {
        [controller died:NO];
    }
}

-(void)dealloc
{
    [level release];
    [buttonQueue release];
    [gameTimer invalidate];
    [super dealloc];
}


@end
