//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCitemView.h"
#import "CCTiles.h"


/*!
   Author: StadiaJack
   Date: 10/20/09
 */
@implementation CCItemView

@synthesize objectCode;
@synthesize num;

-(id)init
{
    if (self = [super init]) {
        num = 0;
    }
    return self;
}

-(void)setNum:(int)n
{
    if (num != n) {
        num = n;
        [self setNeedsDisplay];
    }
}

-(void)drawRect:(CGRect)rect
{
    CCTiles *tiles = [CCTiles instance];
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGRect r = CGRectMake(0, 0, TILE_SIZE, TILE_SIZE);
    [tiles drawTile:FLOOR inRect:r context:context];
     if (num > 0) [tiles drawTile:objectCode inRect:r context:context];
//    CGContextDrawLayerInRect(context, r, tiles.tiles[FLOOR]);
//    if (num > 0) CGContextDrawLayerInRect(context, r, tiles.tiles[objectCode]);
    CGContextRestoreGState(context);
    
    if (num > 1) {
        // badge
        NSString *s = [NSString stringWithFormat:@"%d", num];
        CGSize textSize = [s sizeWithFont:[UIFont systemFontOfSize:12]];
        float len = s.length;
        float capDiameter = textSize.height;
        float capRadius = capDiameter / 2.0;
        float inset = 2;
        
        float width = MAX(((len+1)/len)*textSize.width, textSize.height);
        CGRect badgeBounds = CGRectMake(0, 0, width, textSize.height);
        CGRect textBounds = CGRectOffset(badgeBounds, 0, -1);
        
        CGContextTranslateCTM(context, TILE_SIZE-width, 0);

        CGContextSetRGBFillColor(context, 0, 0.75, 0, 1);
        CGContextFillEllipseInRect( context, CGRectMake(
                                                        badgeBounds.origin.x,
                                                        badgeBounds.origin.y,
                                                        capDiameter,
                                                        capDiameter
                                   ) );
        
        CGContextFillEllipseInRect( context, CGRectMake(
                                                        badgeBounds.origin.x + badgeBounds.size.width - capDiameter,
                                                        badgeBounds.origin.y,
                                                        capDiameter,
                                                        capDiameter
                                   ) );
        
        CGContextFillRect( context, CGRectMake(
                                               badgeBounds.origin.x + capRadius,
                                               badgeBounds.origin.y,
                                               badgeBounds.size.width - capDiameter,
                                               capDiameter
                          ) );
        
        CGContextSetRGBFillColor(context, 0, 0.5, 0, 1);
        CGContextFillEllipseInRect( context, CGRectMake(
                                                        badgeBounds.origin.x + inset,
                                                        badgeBounds.origin.y + inset,
                                                        capDiameter - inset*2,
                                                        capDiameter - inset*2
                                                        ) );
        CGContextFillEllipseInRect( context, CGRectMake(
                                                        badgeBounds.origin.x + badgeBounds.size.width - capDiameter + inset,
                                                        badgeBounds.origin.y + inset,
                                                        capDiameter - inset*2,
                                                        capDiameter - inset*2
                                                        ) );
        CGContextFillRect( context, CGRectMake(
                                               badgeBounds.origin.x + capRadius,
                                               badgeBounds.origin.y + inset,
                                               badgeBounds.size.width - capDiameter,
                                               capDiameter - inset*2
                                               ) );
        
        CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f );
        [s drawInRect:textBounds
             withFont:[UIFont systemFontOfSize:12]
        lineBreakMode:UILineBreakModeClip
            alignment:UITextAlignmentCenter
        ];
    }
}    

@end
