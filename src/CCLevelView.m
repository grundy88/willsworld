
#import "CCLevelView.h"
#import "CCTiles.h"
#import "CCMonster.h"
#import "CCBlock.h"
#import "CCCommon.h"
#import <UIKit/UIKit.h>

@implementation CCLevelView

@synthesize level;
@synthesize offsetx;
@synthesize offsety;

-(id)init
{
    if (self = [super init]) {
        level = nil;
//        offset = CGPointMake(0, 0);
        offsetx = 0;
        offsety = 0;
        
#ifdef FRAME_RATE_DEBUG
        frameCount = 0;
        totalTime = 0;
#endif
    }
    return self;
}


-(void)drawRect:(CGRect)rect
{
    //    NSLog(@"drawRect: %.3f,%.3f %.3f,%.3f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
#ifdef FRAME_RATE_DEBUG
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
#endif
    
    if (level) {
        CCTiles *tiles = [CCTiles instance];
        CGContextRef context = UIGraphicsGetCurrentContext();

//        int tilex = offset.x / TILE_SIZE;
//        int tiley = offset.y / TILE_SIZE;
//        int pixelx = -((int)offset.x % TILE_SIZE);
//        int pixely = -((int)offset.y % TILE_SIZE);
        int tilex = offsetx / TILE_SIZE;
        int tiley = offsety / TILE_SIZE;
        int pixelx = -(offsetx % TILE_SIZE);
        int pixely = -(offsety % TILE_SIZE);
//        NSLog(@"offset: %f,%f  tile: %d,%d  pixel: %d,%d", offset.x, offset.y, tilex, tiley, pixelx, pixely);
        
        
        for (int px = pixelx, tx = tilex; px < NUM_VIEW_TILES * TILE_SIZE; px += TILE_SIZE, tx++) {
            for (int py = pixely, ty = tiley; py < NUM_VIEW_TILES * TILE_SIZE; py += TILE_SIZE, ty++) {
                short index = layerIndex(tx, ty);
                CGRect r = CGRectMake(px, py, TILE_SIZE, TILE_SIZE);
                byte o = level.drawOverride[index];
                if (o == NONE) {
                    o = level.topLayer[index];
                } else if (level.movePhase >= level.numPhases-1) {
                    level.drawOverride[index] = NONE;
                }

                if (isTransparent(o)) {
                    // top layer is transparent, draw bottom layer first
                    [tiles drawTile:level.bottomLayer[index] inRect:r context:context];
                }
                [tiles drawTile:o inRect:r context:context];
            }
        }
        
        // monsters
        for (int tx = tilex-1; tx <= tilex + NUM_VIEW_TILES + 1; tx++) {
            for (int ty = tiley-1; ty <= tiley + NUM_VIEW_TILES + 1; ty++) {
                if (tx >= 0 && tx < LEVEL_SIZE && ty >= 0 && ty < LEVEL_SIZE) {
                    short index = layerIndex(tx, ty);
                    CCMovable *movable = level.movableLayer[index];
                    if (movable && movable.objectCode != BLOCK) {
                        int x = movable.pixelx - offsetx;
                        int y = movable.pixely - offsety;
                        CGRect r = CGRectMake(x, y, TILE_SIZE, TILE_SIZE);
                        [tiles drawTile:movable.objectCode inRect:r context:context];
                    }
                }
            }
        }
        
        if (level.chip.objectCode > 0) {
            int x = level.chip.pixelx - offsetx;
            int y = level.chip.pixely - offsety;
            if (level.topLayer[layerIndex(level.chip.x, level.chip.y)] == WATER) {
                CGRect r = CGRectMake(x, y+(TILE_SIZE/4), TILE_SIZE, TILE_SIZE/2);
                [tiles drawTile:level.chip.objectCode+4 inRect:r context:context];
            } else {
                CGRect r = CGRectMake(x, y, TILE_SIZE, TILE_SIZE);
                [tiles drawTile:level.chip.objectCode inRect:r context:context];
            }
        }
        
        // blocks
        for (int tx = tilex-1; tx <= tilex + NUM_VIEW_TILES + 1; tx++) {
            for (int ty = tiley-1; ty <= tiley + NUM_VIEW_TILES + 1; ty++) {
                if (tx >= 0 && tx < LEVEL_SIZE && ty >= 0 && ty < LEVEL_SIZE) {
                    short index = layerIndex(tx, ty);
                    CCMovable *movable = level.movableLayer[index];
                    if (movable && movable.objectCode == BLOCK) {
                        int x = movable.pixelx - offsetx;
                        int y = movable.pixely - offsety;
                        CGRect r = CGRectMake(x, y, TILE_SIZE, TILE_SIZE);
                        [tiles drawTile:movable.objectCode inRect:r context:context];
                    }
                }
            }
        }
    }    
    
#ifdef FRAME_RATE_DEBUG
    NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
    frameCount++;
    totalTime += (end - start);
    if (frameCount % 100 == 0) {
        NSLog(@"avg time in level draw: %f", totalTime / frameCount);
    }
#endif
    
}

// -----------------------------------------------------------------------------------------------
#pragma mark -

-(void)dealloc
{
    [super dealloc];
}


@end
