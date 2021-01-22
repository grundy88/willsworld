//  Copyright 2010 StadiaJack. All rights reserved.

#import "CCHelpMenuView.h"
#import "CCMenuButton.h"
#import "CCTiles.h"

@interface CCTileView : UIView {
    CCTileTypes tileCode;
}
@property (nonatomic, assign) CCTileTypes tileCode;
+(CCTileView *)tileView:(CCTileTypes)tileType;
@end

@implementation CCTileView
@synthesize tileCode;

+(CCTileView *)tileView:(CCTileTypes)tileType
{
    CCTileView *tileView = [CCTileView new];
    tileView.frame = CGRectMake(0, 0, TILE_SIZE, TILE_SIZE);
    tileView.backgroundColor = [UIColor clearColor];
    tileView.tileCode = tileType;
    return [tileView autorelease];
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect r = CGRectMake(0, 0, TILE_SIZE, TILE_SIZE);
    [[CCTiles instance] drawTile:tileCode inRect:r context:context];
}
@end

/*!
   Author: StadiaJack
   Date: 4/11/10
 */
@implementation CCHelpMenuView

-(float)sectionIn:(UIView *)v at:(float)_y text:(NSString *)text numTiles:(int)numTiles, ...
{
    NSMutableArray *tileCodes = [NSMutableArray array];
    va_list args;
    va_start(args, numTiles);
    for (int i = 0; i < numTiles; i++) {
        CCTileTypes tileType = va_arg(args, CCTileTypes);
        [tileCodes addObject:[NSNumber numberWithInt:tileType]];
    }
    va_end(args);

    float x = 0;
    float y = _y+5;
    for (int i = 0; i < numTiles; i++) {
        UIView *tileView = [CCTileView tileView:[[tileCodes objectAtIndex:i] intValue]];
        tileView.frame = CGRectMake(x, y, tileView.bounds.size.width, tileView.bounds.size.height);
        [v addSubview:tileView];
        if ((i+1) % 2 == 0) {
            x = 0;
            y += 5 + tileView.bounds.size.height;
        } else {
            x += 5 + tileView.bounds.size.width;
        }
    }
    float inc = numTiles%2 == 0 ? 0 : TILE_SIZE;
    float ret = y + inc + 10;
    if (y == _y+5) ret = y + TILE_SIZE + 10;
    
    if (numTiles == 0) x = 0;
    else if (numTiles == 1) x = TILE_SIZE + 5;
    else x = TILE_SIZE*2 + 10;
    y = _y;
    
//    if (numTiles > 1) {
//        for (int i = 0; i < numTiles; i++) {
//            UIView *tileView = [CCTileView tileView:[[tileCodes objectAtIndex:i] intValue]];
//            tileView.frame = CGRectMake(x, y, tileView.bounds.size.width, tileView.bounds.size.height);
//            [v addSubview:tileView];
//            x += 5 + tileView.bounds.size.width;
//        }
//        x = 0;
//        y += TILE_SIZE + 5;
//    } else if (numTiles == 1) {
//        UIView *tileView = [CCTileView tileView:[[tileCodes objectAtIndex:0] intValue]];
//        tileView.frame = CGRectMake(x, y, tileView.bounds.size.width, tileView.bounds.size.height);
//        [v addSubview:tileView];
//        x += 5 + tileView.bounds.size.width;
//    }

    float w = self.bounds.size.width - x;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, TILE_SIZE+10)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.text = text;
    label.font = [UIFont systemFontOfSize:12];
//    [label sizeToFit];
    [v addSubview:label];
    [label release];
//    float inc = (numTiles == 1) ? MAX(label.bounds.size.height, TILE_SIZE) : label.bounds.size.height;
//    return y + inc + 10;
    return ret;
}

-(float)sectionIn:(UIView *)v at:(float)y text:(NSString *)text tile:(CCTileTypes)tile
{
    return [self sectionIn:v at:y text:text numTiles:1, tile];
}

-(float)sectionIn:(UIView *)v at:(float)y text:(NSString *)text
{
    return [self sectionIn:v at:y text:text numTiles:0];
}

-(id)initWithFrame:(CGRect)frame menu:(CCMenuView *)_menu
{
    if (self = [super initWithFrame:frame menu:_menu]) {
        
        CCMenuButton *backButton = [[CCMenuButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        backButton.title = @"<< Back";
        backButton.clickTarget = menu;
        backButton.clickSelector = @selector(showMainPage);
        backButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:backButton];
        [backButton release];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.bounds.size.width, 25)];
        title.backgroundColor = [UIColor clearColor];
        title.text = @"Instructions";
        title.textAlignment = UITextAlignmentCenter;
        title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        title.font = [UIFont boldSystemFontOfSize:20];
        [self addSubview:title];
        [title release];
        
        UIScrollView *container = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 55, self.bounds.size.width, self.bounds.size.height-55)];
        container.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:container];
        [container release];
        
        float y = 0;
        
        y = [self sectionIn:container at:y text:@"Make your way to the exit before time runs out." numTiles:2, CHIP_S, EXIT];
        y = [self sectionIn:container at:y text:@"You can't walk through walls." tile:WALL];
        y = [self sectionIn:container at:y text:@"Gather shape keys to unlock doors." numTiles:2, BLUE_KEY, BLUE_DOOR];
        y = [self sectionIn:container at:y text:@"Gather all coins to open the gate." numTiles:2, COMPUTER_CHIP, SOCKET];
        y = [self sectionIn:container at:y text:@"Blocks can be pushed when there's nothing in the way." tile:BLOCK];
        y = [self sectionIn:container at:y text:@"Push blocks into water to make dirt. Step on dirt to make floor." numTiles:2, WATER, DIRT];
        y = [self sectionIn:container at:y text:@"Flippers let you swim." numTiles:2, FLIPPERS, WATER];
        y = [self sectionIn:container at:y text:@"Fire boots let you walk in fire." numTiles:2, FIRE_BOOTS, FIRE];
        y = [self sectionIn:container at:y text:@"Force boots let you walk on force floors." numTiles:2, SUCTION_BOOTS, FORCE_N];
        y = [self sectionIn:container at:y text:@"Ice skates let you walk on ice." numTiles:2, ICE_SKATES, ICE];
        y = [self sectionIn:container at:y text:@"Quicksand will take away all your footwear." numTiles:1, THIEF];
//        y = [self sectionIn:container at:y text:@"Watch out for monsters." numTiles:9, BUG_N, FIREBALL_N, BALL_N, TANK_N, GLIDER_N, TEETH_S, WALKER_N, BLOB_N, PARAMECIUM_N ];
        y = [self sectionIn:container at:y text:@"Green buttons toggle special walls." numTiles:2, GREEN_BUTTON, SWITCH_BLOCK_CLOSED];
        y = [self sectionIn:container at:y text:@"Blue buttons make tanks turn around." numTiles:2, BLUE_BUTTON, TANK_N];
        y = [self sectionIn:container at:y text:@"Red buttons trigger clone machines." numTiles:2, CLONE_MACHINE, CLONE_BLOCK_N];
        y = [self sectionIn:container at:y text:@"Brown buttons release traps." numTiles:2, BROWN_BUTTON, TRAP];
        y = [self sectionIn:container at:y text:@"Monsters cannot cross dirt or gravel." numTiles:2, DIRT, GRAVEL];
        y = [self sectionIn:container at:y text:@"Touch blue walls to see if they're real or not." numTiles:1, BLUE_BLOCK_WALL];
        y = [self sectionIn:container at:y text:@"Teleports will take you somewhere else (depending on which way you enter)." numTiles:1, TELEPORT];
        y = [self sectionIn:container at:y text:@"Stepping on a popup creates a new wall." numTiles:1, PASS_ONCE];
        y = [self sectionIn:container at:y text:@"Bombs can be exploded by monsters or blocks (or you!)." numTiles:1, BOMB];
        y = [self sectionIn:container at:y text:@"Visit http://www.stadiagames.com/willsworld for more information, tips, and hints..." numTiles:0];
        
        
        container.contentSize = CGSizeMake(self.bounds.size.width, y);
    }
    return self;
}

@end
