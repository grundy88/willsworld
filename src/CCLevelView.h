#import "CCLevel.h"

@interface CCLevelView : UIView {
    CCLevel *level;
//    CGPoint offset;
    int offsetx;
    int offsety;

#ifdef FRAME_RATE_DEBUG
    int frameCount;
    NSTimeInterval totalTime;
#endif
}

@property (nonatomic, retain) CCLevel *level;
//@property (nonatomic, assign) CGPoint offset;
@property (nonatomic, assign) int offsetx;
@property (nonatomic, assign) int offsety;

@end
