#import "KRoundRect.h"

@implementation KRoundRect

@synthesize color;
@synthesize cornerFlags;

-(id)initWithFrame:(CGRect)frame 
    cornerDiameter:(float)_diameter 
       cornerFlags:(int)_cornerFlags
             color:(KRGBColor)_color 
        bezelColor:(KRGBColor)_bezelColor 
      outlineColor:(KRGBColor)_outlineColor 
      outlineWidth:(int)_outlineWidth
{
    if (self = [super initWithFrame:frame]) {
		self.opaque = NO;
        diameter = _diameter;
        color = _color;
        cornerFlags = _cornerFlags;
        bezelColor = _bezelColor;
        outlineColor = _outlineColor;
        outlineWidth = _outlineWidth;
    }
    return self;
}

+(KRoundRect *)createRoundRectInFrame:(CGRect)frame cornerDiameter:(float)diameter color:(KRGBColor)color
{
    return [[KRoundRect alloc] initWithFrame:frame cornerDiameter:diameter cornerFlags:CORNER_ALL color:color bezelColor:KRGBColorClear() outlineColor:KRGBColorClear() outlineWidth:0];
}

+(KRoundRect *)create3dRoundRectInFrame:(CGRect)frame cornerDiameter:(float)diameter color:(KRGBColor)color bezelColor:(KRGBColor)bezelColor
{
    return [[KRoundRect alloc] initWithFrame:frame cornerDiameter:diameter cornerFlags:CORNER_ALL color:color bezelColor:bezelColor outlineColor:KRGBColorClear() outlineWidth:0];
}

+(KRoundRect *)createOutlinedRoundRectInFrame:(CGRect)frame cornerDiameter:(float)diameter color:(KRGBColor)color outlineColor:(KRGBColor)outlineColor
{
    return [[KRoundRect alloc] initWithFrame:frame cornerDiameter:diameter cornerFlags:CORNER_ALL color:color bezelColor:KRGBColorClear() outlineColor:outlineColor outlineWidth:1];
}

-(void)drawRect:(CGRect)clip
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rect;
    if (!isClear(bezelColor)) {
        CGContextSetRGBFillColor (context, bezelColor.r, bezelColor.g, bezelColor.b, bezelColor.a);
        fillRoundedRect(context, CGRectMake(0, 0, self.bounds.size.width, diameter*2), diameter, diameter, cornerFlags);
        
        rect = CGRectMake(0, 1, self.bounds.size.width, self.bounds.size.height-1);
    } else {
        rect = self.bounds;
    }
    
    if (!isClear(outlineColor)) {
        rect = CGRectMake(outlineWidth, outlineWidth, self.bounds.size.width-outlineWidth*2, self.bounds.size.height-outlineWidth*2);
        CGContextSetRGBStrokeColor(context, outlineColor.r, outlineColor.g, outlineColor.b, outlineColor.a);
        CGContextSetLineWidth(context, outlineWidth+1);
        strokeRoundedRect(context, rect, diameter, diameter, cornerFlags);
        rect = CGRectMake(outlineWidth+1, outlineWidth+1, self.bounds.size.width-outlineWidth*2-2, self.bounds.size.height-outlineWidth*2-2);
    }

    CGContextSetRGBFillColor (context, color.r, color.g, color.b, color.a);
    fillRoundedRect(context, rect, diameter, diameter, cornerFlags);
    
    
}

@end
