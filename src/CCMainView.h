
#import "CCLevel.h"
#import "CCLevelView.h"
#import "CCDigitView.h"
#import "CCItemView.h"
#import "CCBevelView.h"

#define TAG_FAIL_ALERT 89898

@class CCController;

@interface CCMainView : UIView
#if TARGET_IPHONE_SIMULATOR
#ifdef DEBUG
<UITextFieldDelegate>
#endif
#endif
{
    CCController *controller;
    
    UIView *leftButton;
    UIView *rightButton;
    UIView *upButton1;
    UIView *upButton2;
    UIView *downButton1;
    UIView *downButton2;
    UIView *leftButtonInvisible;
    UIView *rightButtonInvisible;
    UIView *upButtonInvisible;
    UIView *downButtonInvisible;
    
    CCLevel *level;
    CCLevelView *levelView;
    
    CCDigitView *levelNumView;
    CCDigitView *timeLeftView;
    UILabel *treasureNameLabel;
    CCDigitView *chipsLeftView;

    CCItemView *redKeyView;
    CCItemView *blueKeyView;
    CCItemView *yellowKeyView;
    CCItemView *greenKeyView;
    CCItemView *iceSkatesView;
    CCItemView *suctionBootsView;
    CCItemView *fireBootsView;
    CCItemView *flippersView;

    UIView *hintView;
    CCBevelView *hintContainer;
    
    CCBevelView *splashView;
    
    NSTimer *gameTimer;
    
    // buttonStack is directions pressed simultaneously
    CCDirection *buttonStack;
    CCDirection buttonDir;
    // buttonQueue is buffered up presses
    NSMutableArray *buttonQueue;
//    BOOL dirFromQueue;
    
    short halfStepCount;
    
    int deathCount;
    int skipDeathCount;
    NSTimeInterval duration;
    NSTimeInterval durationCheckpoint;
    BOOL paused;
    
#ifdef FRAME_RATE_DEBUG
    int frameCount;
    NSTimeInterval totalTime;
#endif
}

@property (nonatomic, readonly) CCItemView *redKeyView;
@property (nonatomic, readonly) CCItemView *blueKeyView;
@property (nonatomic, readonly) CCItemView *yellowKeyView;
@property (nonatomic, readonly) CCItemView *greenKeyView;
@property (nonatomic, readonly) CCItemView *iceSkatesView;
@property (nonatomic, readonly) CCItemView *suctionBootsView;
@property (nonatomic, readonly) CCItemView *fireBootsView;
@property (nonatomic, readonly) CCItemView *flippersView;

@property (nonatomic, readonly) UIView *leftButton;
@property (nonatomic, readonly) UIView *rightButton;
@property (nonatomic, readonly) UIView *upButton1;
@property (nonatomic, readonly) UIView *upButton2;
@property (nonatomic, readonly) UIView *downButton1;
@property (nonatomic, readonly) UIView *downButton2;
@property (nonatomic, readonly) UIView *leftButtonInvisible;
@property (nonatomic, readonly) UIView *rightButtonInvisible;
@property (nonatomic, readonly) UIView *upButtonInvisible;
@property (nonatomic, readonly) UIView *downButtonInvisible;

@property (nonatomic, readonly) CCDirection buttonDir;
@property (nonatomic, readonly) NSMutableArray *buttonQueue;
@property (nonatomic, readonly) CCDirection *buttonStack;

-(id)initWithFrame:(CGRect)frame controller:(CCController *)_controller;

-(CCDirection)getControlDir;
-(CCDirection)getControlDir:(BOOL)peek;
-(void)submitButtonDir:(CCDirection)dir addToQueue:(BOOL)queue;
-(void)removeButtonDir:(CCDirection)dir;
-(void)removeDirFromQueue:(CCDirection)dir;
-(void)clearButtonStack;

-(void)startLevel:(CCLevel *)_level firstTime:(BOOL)firstTime;
-(void)pause;
-(void)resume;
-(void)tilesetChanged;

-(void)setTreasureName:(NSString *)treasureName;

-(void)startMenuButtonPulse;
-(void)stopMenuButtonPulse;

@end
