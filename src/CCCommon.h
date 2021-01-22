#define LEVEL_SIZE 32
#define TILE_SOURCE_HEIGHT 16
#define TILE_SOURCE_WIDTH 13
#define NUM_VIEW_TILES 9
#define FRAME_RATE 30
#define STEP_RATE 5

#ifdef UI_USER_INTERFACE_IDIOM
#define TILE_SIZE ((UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) ? 84 : 32)
#else
#define TILE_SIZE 32
#endif

#define MESSAGE_DROWNED @"Ooops! You can't swim without flippers!"
#define MESSAGE_BURNED @"Ooops! Don't step in the fire without fire boots!"
#define MESSAGE_KILLED @"Ooops! Look out for creatures!"
#define MESSAGE_CRUSHED @"Ooops! Watch out for moving blocks!"
#define MESSAGE_EXPLODED @"Ooops! Don't touch the bombs!"
#define MESSAGE_TIME @"Ooops! Out of time..."
#define MESSAGE_SKIPLEVEL @"Looks like you're having trouble - would you like to skip to the next level?"
#define MAX_MONSTERS 256
#define MAX_BLOCKS 128

//#define KILLED_DEBUG 1
//#define BUTTON_DEBUG 1
//#define FRAME_RATE_DEBUG 1
//#define MAP_GENERATOR 1
//#define MAP_GENERATOR_CURRENT_ONLY 1

#define isMonster(o) (o >= 0x40 && o <= 0x63)
#define isTransparent(o) (o >= 0x40 && o <= 0x6F)
#define isChip(o) (o >= CHIP_N && o <= CHIP_E)
#define isUnused(o) (o == 0x20 || (o >= 0x33 && o <= 0x3B))

typedef unsigned char byte;

typedef enum {
    NORTH = 100, 
    EAST = 101,
    SOUTH = 102,
    WEST = 103,
    NONE = 0
} CCDirection;

typedef enum {
    CCGameSoundsNone = 0,
    CCGameSoundsPlayerOnly,
    CCGameSoundsOnscreen,
    CCGameSoundsAll
} CCGameSoundLevel;

typedef struct {
    short x;
    short y;
} CCPoint;

static CGRect makeRotatedRect(CGRect rect) {
    return CGRectMake(rect.origin.x+(rect.size.width-rect.size.height)/2, rect.origin.y+(rect.size.height-rect.size.width)/2, rect.size.height, rect.size.width);
}


static short layerIndex(byte x, byte y) {
    return (y * LEVEL_SIZE) + x;
}

static short layerIndexForPoint(CCPoint p) {
    return layerIndex(p.x, p.y);
}

static CCPoint pointForLayerIndex(short index) {
    CCPoint p;
    p.x = index % LEVEL_SIZE;
    p.y = index / LEVEL_SIZE;
    return p;
}

static CCPoint CCPointMake(byte x, byte y) {
    CCPoint p; p.x = x; p.y = y; return p;
}

static CCPoint translate(byte x, byte y, CCDirection d) {
    switch (d) {
        case NORTH:
            return CCPointMake(x, y-1);
            break;
        case SOUTH:
            return CCPointMake(x, y+1);
            break;
        case EAST:
            return CCPointMake(x+1, y);
            break;
        case WEST:
            return CCPointMake(x-1, y);
            break;
    }
    return CCPointMake(x, y);
}

static BOOL isDir(int d) {
    return d >= NORTH && d <= WEST;
}

static CCDirection dirRight(CCDirection d) {
    d++;
    if (d > WEST) d = NORTH;
    return d;
}

static CCDirection dirLeft(CCDirection d) {
    d--;
    if (d < NORTH) d = WEST;
    return d;
}

static CCDirection dirOpposite(CCDirection d) {
    d += 2;
    if (d > WEST) d = NORTH + (d - WEST) - 1;
    return d;
}

static CCDirection randomDirection() {
    int i = arc4random() % 4;
    switch (i) {
        case 0:
            return NORTH;
            break;
        case 1:
            return EAST;
            break;
        case 2:
            return SOUTH;
            break;
    }
    return WEST;
}

static BOOL dirIsPerpendicular(CCDirection d1, CCDirection d2) {
    return (d1 != NONE) && (d2 != NONE) && (d1 != d2) && ((d1-d2)%2 != 0);
}

static CCDirection dirFromCode(byte baseCode, byte code) {
    CCDirection d = NONE;
    switch ((code - baseCode) % 4) {
        case 0:
            d = NORTH;
            break;
        case 1:
            d = WEST;
            break;
        case 2:
            d = SOUTH;
            break;
        case 3:
            d = EAST;
            break;
    }
    return d;
}

static char *dirName(CCDirection dir) {
    char *s;
    switch (dir) {
        case NORTH:
            s = "north";
            break;
        case EAST:
            s = "east";
            break;
        case SOUTH:
            s = "south";
            break;
        case WEST:
            s = "west";
            break;
        default:
            s = "none";
    }
    return s;
}


static CCDirection creatureDirFromCode(byte code) {
    return dirFromCode(0x40, code);
}


static float right(UIView *v) {
    return v.frame.origin.x + v.frame.size.width;
}

static float left(UIView *v) {
    return v.frame.origin.x;
}

static float top(UIView *v) {
    return v.frame.origin.y;
}

static float bottom(UIView *v) {
    return v.frame.origin.y + v.frame.size.height;
}

static float horizMiddle(UIView *v) {
    return v.frame.origin.x + v.frame.size.width/2;
}

static float vertMiddle(UIView *v) {
    return v.frame.origin.y + v.frame.size.height/2;
}

#define width(v) v.bounds.size.width
#define height(v) v.bounds.size.height

static void position(UIView *v, float x, float y) {
    v.frame = CGRectMake(x, y, v.bounds.size.width, v.bounds.size.height);
}

static NSString *displayName(NSString *s) {
    return [[[s stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] lastPathComponent] stringByDeletingPathExtension];
}

static CGRect keyboardFrameForNotification(NSNotification *notification) {
    CGRect r;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
//#if __IPHONE_3_2 >= __IPHONE_OS_VERSION_MAX_ALLOWED
        [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&r];
    } else {
//#else
        [[notification.userInfo valueForKey:@"UIKeyboardBoundsUserInfoKey"] getValue:&r];
//#endif
    }
    return r;
}

static BOOL ipad() {
#ifdef UI_USER_INTERFACE_IDIOM
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        return YES;
    }
#endif
    return NO;
}
