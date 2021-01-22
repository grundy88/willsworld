
#import "CCLevel.h"
#import "CCTiles.h"
#import "CCMonster.h"
#import "CCBlock.h"

@implementation CCLevel

@synthesize number;
@synthesize title;
@synthesize password;
@synthesize timeLimit;
@synthesize chipCount;
@synthesize hint;

@synthesize movableLayer;
@synthesize topLayer;
@synthesize bottomLayer;
@synthesize drawOverride;

@synthesize buttons;
@synthesize traps;

@synthesize monsters;
@synthesize newMonsters;
@synthesize deadMonsters;

@synthesize blocks;
@synthesize newBlocks;
@synthesize deadBlocks;

@synthesize chip;
@synthesize numRedKeys;
@synthesize numBlueKeys;
@synthesize numYellowKeys;
@synthesize greenKey;
@synthesize fireBoots;
@synthesize iceSkates;
@synthesize flippers;
@synthesize suctionBoots;

@synthesize died;
@synthesize exited;
@synthesize showHint;

@synthesize numPhases;
@synthesize movePhase;
@synthesize slidePhase;
@synthesize monsterWait;

-(id)init
{
    if (self = [super init]) {
        movableLayer = malloc(sizeof(CCMovable *) * LEVEL_SIZE * LEVEL_SIZE);
        topLayer = malloc(sizeof(byte) * LEVEL_SIZE * LEVEL_SIZE);
        bottomLayer = malloc(sizeof(byte) * LEVEL_SIZE * LEVEL_SIZE);
        drawOverride = malloc(sizeof(byte) * LEVEL_SIZE * LEVEL_SIZE);
        buttons = malloc(sizeof(CCCoord *) * LEVEL_SIZE * LEVEL_SIZE);
        traps = malloc(sizeof(CCTrap *) * LEVEL_SIZE * LEVEL_SIZE);
        
        for (int i = 0; i < LEVEL_SIZE*LEVEL_SIZE; i++) {
            movableLayer[i] = 0;
            topLayer[i] = 0;
            bottomLayer[i] = 0;
            drawOverride[i] = 0;
            buttons[i] = nil;
            traps[i] = nil;
        }

        monsters = [NSMutableArray new];
        newMonsters = [NSMutableArray new];
        deadMonsters = [NSMutableArray new];
        blocks = [NSMutableArray new];
        newBlocks = [NSMutableArray new];
        deadBlocks = [NSMutableArray new];

        died = nil;
        exited = NO;
        showHint = NO;
        
        movePhase = 0;
        slidePhase = 0;
        monsterWait = TRUE;
        numPhases = FRAME_RATE / STEP_RATE / 2;
        
        numRedKeys = 0;
        numBlueKeys = 0;
        numYellowKeys = 0;
        greenKey = NO;
        fireBoots = NO;
        iceSkates = NO;
        flippers = NO;
        suctionBoots = NO;
        
    }
    return self;
}

-(void)addRemoveMovables
{
    [monsters addObjectsFromArray:newMonsters];
    [monsters removeObjectsInArray:deadMonsters];
    [newMonsters removeAllObjects];
    [deadMonsters removeAllObjects];
    [blocks addObjectsFromArray:newBlocks];
    [blocks removeObjectsInArray:deadBlocks];
    [newBlocks removeAllObjects];
    [deadBlocks removeAllObjects];
}

-(void)toggleWalls
{
    for (int i = 0; i < LEVEL_SIZE*LEVEL_SIZE; i++) {
        if (topLayer[i] == SWITCH_BLOCK_OPEN) {
            topLayer[i] = SWITCH_BLOCK_CLOSED;
        } else if (topLayer[i] == SWITCH_BLOCK_CLOSED) {
            topLayer[i] = SWITCH_BLOCK_OPEN;
        }
    }
}

-(void)toggleTanks
{
    for (CCMonster *monster in monsters) {
        if (!monster.sliding && [monster isKindOfClass:[CCTank class]]) {
            monster.dir = dirOpposite(monster.dir);
            monster.objectCode = [monster currentObjectCode];
        }
    }
}

/*
 top         bottom      result
 -------------------------------
 monster     cloner      button: check monster dir, if free then create a monster, its first move is in its direction
                         push: as if a wall
 block       cloner      button: nothing
                         push: check opposite side, if free then create a block there
             cloner      button: nothing
                         push: as if invisible wall
 cloneblock  cloner      button: check cloneblock dir, if free then create a block there
                         push: as if a wall
 cloneblock              button: check cloneblock dir, if free then create a block there AND cloneblock disappears
                         push: as if a wall
             cloneblock  button: nothing
                         push: not shown, stepping on that tile reveals it, then it behaves as if on the top
 block       cloneblock  button: nothing
                         push: block is free and can be pushed, but chip doesn't move with it, cloneblock visible and behaves as if on top
 monster     cloneblock  button: nothing
                         push: monster is free, cloneblock visible and behaves as if on top
 */
-(void)triggerCloneAtPoint:(CCPoint)point
{
    // todo point may not be a machine/cloneblock...
    ushort index = layerIndexForPoint(point);
    byte t = topLayer[index];
    byte b = bottomLayer[index];
    if (b == CLONE_MACHINE) {
        if (t == CLONE_BLOCK_N ||
            t == CLONE_BLOCK_W ||
            t == CLONE_BLOCK_S ||
            t == CLONE_BLOCK_E)
        {
            if (blocks.count < MAX_BLOCKS) {
                CCBlock *block = [[CCBlock alloc] initInLevel:self x:point.x y:point.y];
                CCDirection d = dirFromCode(CLONE_BLOCK_N, t);
                if (![block blocked:d]) {
                    [block moveInDirection:d];
                    [newBlocks addObject:block];
                }
                [block release];
            }            
        } else if (isMonster(t)) {
            if (monsters.count < MAX_MONSTERS) {
                CCMonster *monster = [CCMonster newMonster:t level:self x:point.x y:point.y];
                if (![monster blocked:monster.dir]) {
                    monster.forceDir = monster.dir;
                    [newMonsters addObject:monster];
                }
                [monster release];
            }
        }
            
        
    } else if (t == CLONE_BLOCK_N ||
               t == CLONE_BLOCK_W ||
               t == CLONE_BLOCK_S ||
               t == CLONE_BLOCK_E)
    {
        CCBlock *block = [[CCBlock alloc] initInLevel:self x:point.x y:point.y];
        CCDirection d = dirFromCode(CLONE_BLOCK_N, t);
        if (![block blocked:d]) {
            CCPoint dest = translate(point.x, point.y, d);
            block.x = dest.x;
            block.y = dest.y;
            block.moving = YES;
            block.dir = d;
            block.objectCode = [block currentObjectCode];
            movableLayer[layerIndex(block.x, block.y)] = block;
            [blocks addObject:block];
            topLayer[index] = FLOOR;
        }
        [block release];
    }
}

-(void)releaseTrapAtPoint:(CCPoint)point
{
    short index = layerIndexForPoint(point);
    CCTrap *trap = traps[index];
    if (trap) {
        CCMovable *movable = movableLayer[index];
        movable.releasedFromTrap = YES;
        if (chip.x == point.x && chip.y == point.y) {
            chip.releasedFromTrap = YES;
        }
        trap.active = NO;
    }
}

-(void)activateTrapAtPoint:(CCPoint)point
{
    traps[layerIndexForPoint(point)].active = YES;
}

-(void)report
{
    printf("LEVEL REPORT\n");
    printf("  movables:\n");
    for (int i = 0; i < LEVEL_SIZE*LEVEL_SIZE; i++) {
        if (movableLayer[i]) {
            printf("%.2x ", movableLayer[i].objectCode);
        } else {
            printf(".. ");
        }
        if ((i+1) % LEVEL_SIZE == 0) printf("\n");
    }
}

-(void)dealloc
{
    free(movableLayer);
    free(topLayer);
    free(bottomLayer);
    for (int i = 0; i < LEVEL_SIZE*LEVEL_SIZE; i++) {
        [buttons[i] release];
        [traps[i] release];
    }
    free(buttons);
    free(traps);
    [title release];
    [password release];
    [hint release];
    [monsters release];
    [newMonsters release];
    [deadMonsters release];
    [blocks release];
    [newBlocks release];
    [deadBlocks release];
    [died release];
    [chip release];
    [super dealloc];
}

@end
