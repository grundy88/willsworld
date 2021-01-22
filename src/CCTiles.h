#import "CCCommon.h"
#import "CCPersistedAsset.h"

#define NUM_TILES 0x70

typedef enum {
    FLOOR                   = 0x00,
    WALL                    = 0x01,
    COMPUTER_CHIP           = 0x02,
    WATER                   = 0x03,
    FIRE                    = 0x04,
    INVISIBLE_WALL_NOAPPEAR = 0x05,
    THIN_WALL_N             = 0x06,
    THIN_WALL_W             = 0x07,
    THIN_WALL_S             = 0x08,
    THIN_WALL_E             = 0x09,
    BLOCK                   = 0x0A,
    DIRT                    = 0x0B,
    ICE                     = 0x0C,
    FORCE_S                 = 0x0D,
    CLONE_BLOCK_N           = 0x0E,
    CLONE_BLOCK_W           = 0x0F,
    CLONE_BLOCK_S           = 0x10,
    CLONE_BLOCK_E           = 0x11,
    FORCE_N                 = 0x12,
    FORCE_E                 = 0x13,
    FORCE_W                 = 0x14,
    EXIT                    = 0x15,
    BLUE_DOOR               = 0x16,
    RED_DOOR                = 0x17,
    GREEN_DOOR              = 0x18,
    YELLOW_DOOR             = 0x19,
    ICE_SE                  = 0x1A,
    ICE_SW                  = 0x1B,
    ICE_NW                  = 0x1C,
    ICE_NE                  = 0x1D,
    BLUE_BLOCK_FLOOR        = 0x1E,
    BLUE_BLOCK_WALL         = 0x1F,
    THIEF                   = 0x21,
    SOCKET                  = 0x22,
    GREEN_BUTTON            = 0x23,
    RED_BUTTON              = 0x24,
    SWITCH_BLOCK_CLOSED     = 0x25,
    SWITCH_BLOCK_OPEN       = 0x26,
    BROWN_BUTTON            = 0x27,
    BLUE_BUTTON             = 0x28,
    TELEPORT                = 0x29,
    BOMB                    = 0x2A,
    TRAP                    = 0x2B,
    INVISIBLE_WALL_APPEAR   = 0x2C,
    GRAVEL                  = 0x2D,
    PASS_ONCE               = 0x2E,
    HINT                    = 0x2F,
    THIN_WALL_SE            = 0x30,
    CLONE_MACHINE           = 0x31,
    FORCE_RANDOM            = 0x32,
    DROWNING_CHIP           = 0x33,
    BURNED_CHIP             = 0x34,
    BURNED_CHIP2            = 0x35,
    CHIP_IN_EXIT            = 0x39,
    EXIT_END_GAME           = 0x3A,
    EXIT_END_GAME2          = 0x3B,
    CHIP_SWIMMING_N         = 0x3C,
    CHIP_SWIMMING_W         = 0x3D,
    CHIP_SWIMMING_S         = 0x3E,
    CHIP_SWIMMING_E         = 0x3F,
    BUG_N                   = 0x40,
    BUG_W                   = 0x41,
    BUG_S                   = 0x42,
    BUG_E                   = 0x43,
    FIREBALL_N              = 0x44,
    FIREBALL_W              = 0x45,
    FIREBALL_S              = 0x46,
    FIREBALL_E              = 0x47,
    BALL_N                  = 0x48,
    BALL_W                  = 0x49,
    BALL_S                  = 0x4A,
    BALL_E                  = 0x4B,
    TANK_N                  = 0x4C,
    TANK_W                  = 0x4D,
    TANK_S                  = 0x4E,
    TANK_E                  = 0x4F,
    GLIDER_N                = 0x50,
    GLIDER_W                = 0x51,
    GLIDER_S                = 0x52,
    GLIDER_E                = 0x53,
    TEETH_N                 = 0x54,
    TEETH_W                 = 0x55,
    TEETH_S                 = 0x56,
    TEETH_E                 = 0x57,
    WALKER_N                = 0x58,
    WALKER_W                = 0x59,
    WALKER_S                = 0x5A,
    WALKER_E                = 0x5B,
    BLOB_N                  = 0x5C,
    BLOB_W                  = 0x5D,
    BLOB_S                  = 0x5E,
    BLOB_E                  = 0x5F,
    PARAMECIUM_N            = 0x60,
    PARAMECIUM_W            = 0x61,
    PARAMECIUM_S            = 0x62,
    PARAMECIUM_E            = 0x63,
    BLUE_KEY                = 0x64,
    RED_KEY                 = 0x65,
    GREEN_KEY               = 0x66,
    YELLOW_KEY              = 0x67,
    FLIPPERS                = 0x68,
    FIRE_BOOTS              = 0x69,
    ICE_SKATES              = 0x6A,
    SUCTION_BOOTS           = 0x6B,
    CHIP_N                  = 0x6C,
    CHIP_W                  = 0x6D,
    CHIP_S                  = 0x6E,
    CHIP_E                  = 0x6F,
    NO_TILE                 = 0xFF
} CCTileTypes;

@interface CCTiles : NSObject {
    CGLayerRef *tileLayers;
    CGImageRef *tileImages;
}

//@property (nonatomic, readonly) CGLayerRef *tiles;
//@property (nonatomic, readonly) CGImageRef *tiles;

+(CCTiles *)instance;

-(void)loadTileset:(CCPersistedAsset *)asset;

-(NSString *)monsterClassName:(byte)objectCode;
-(CCDirection)dirFromFloor:(byte)code;

-(void)drawTile:(byte)tileCode inRect:(CGRect)r context:(CGContextRef)context;

@end
