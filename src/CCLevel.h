#import "CCChip.h"
#import "CCCoord.h"

@interface CCLevel : NSObject {
    ushort number;
    NSString *title;
    NSString *password;
    ushort timeLimit;
    ushort chipCount;
    NSString *hint;
    
    CCMovable **movableLayer;
    byte *topLayer;
    byte *bottomLayer;
    byte *drawOverride;
    
    CCCoord **buttons;
    CCTrap **traps;
    
    NSMutableArray *monsters;
    NSMutableArray *newMonsters;
    NSMutableArray *deadMonsters;
    
    NSMutableArray *blocks;
    NSMutableArray *newBlocks;
    NSMutableArray *deadBlocks;
    
    CCChip *chip;
    int numRedKeys;
    int numBlueKeys;
    int numYellowKeys;
    BOOL greenKey;
    BOOL fireBoots;
    BOOL iceSkates;
    BOOL flippers;
    BOOL suctionBoots;
    
    NSString *died;
    BOOL exited;
    BOOL showHint;
    
    int numPhases;
    int movePhase;
    int slidePhase;
    
    BOOL monsterWait;
}

@property (nonatomic, assign) ushort number;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) ushort timeLimit;
@property (nonatomic, assign) ushort chipCount;
@property (nonatomic, copy) NSString *hint;

@property (nonatomic, readonly) CCMovable **movableLayer;
@property (nonatomic, readonly) byte *topLayer;
@property (nonatomic, readonly) byte *bottomLayer;
@property (nonatomic, readonly) byte *drawOverride;

@property (nonatomic, readonly) CCCoord **buttons;
@property (nonatomic, readonly) CCTrap **traps;

@property (nonatomic, readonly) NSMutableArray *monsters;
@property (nonatomic, readonly) NSMutableArray *newMonsters;
@property (nonatomic, readonly) NSMutableArray *deadMonsters;

@property (nonatomic, readonly) NSMutableArray *blocks;
@property (nonatomic, readonly) NSMutableArray *newBlocks;
@property (nonatomic, readonly) NSMutableArray *deadBlocks;

@property (nonatomic, copy) NSString *died;
@property (nonatomic, assign) BOOL exited;
@property (nonatomic, assign) BOOL showHint;

@property (nonatomic, assign) BOOL monsterWait;
@property (nonatomic, assign) int numPhases;
@property (nonatomic, assign) int movePhase;
@property (nonatomic, assign) int slidePhase;

@property (nonatomic, retain) CCChip *chip;
@property (nonatomic, assign) int numRedKeys;
@property (nonatomic, assign) int numBlueKeys;
@property (nonatomic, assign) int numYellowKeys;
@property (nonatomic, assign) BOOL greenKey;
@property (nonatomic, assign) BOOL fireBoots;
@property (nonatomic, assign) BOOL iceSkates;
@property (nonatomic, assign) BOOL flippers;
@property (nonatomic, assign) BOOL suctionBoots;

-(void)addRemoveMovables;
-(void)toggleWalls;
-(void)toggleTanks;
-(void)triggerCloneAtPoint:(CCPoint)point;
-(void)releaseTrapAtPoint:(CCPoint)point;
-(void)activateTrapAtPoint:(CCPoint)point;

-(void)report;

@end
