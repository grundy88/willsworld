
#import "KRGBColor.h"

typedef enum {
    UPPER_RIGHT = 1,
    UPPER_LEFT = 2,
    LOWER_RIGHT = 4,
    LOWER_LEFT = 8
} KRoundedRectCorner;

#define CORNER_ALL UPPER_RIGHT|UPPER_LEFT|LOWER_RIGHT|LOWER_LEFT

static void addSomewhatRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight, int cornerFlags)
{
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {// 1
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);// 2
    CGContextTranslateCTM (context, CGRectGetMinX(rect),// 3
                           CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);// 4
    fw = CGRectGetWidth (rect) / ovalWidth;// 5
    fh = CGRectGetHeight (rect) / ovalHeight;// 6
    CGContextMoveToPoint(context, fw, fh/2); // 7
    if (cornerFlags & LOWER_RIGHT) {
        CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);// 8
    } else {
        CGContextAddLineToPoint(context, fw, fh);
    }
    if (cornerFlags & LOWER_LEFT) {
        CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);// 9
    } else {    
        CGContextAddLineToPoint(context, 0, fh);
    }
    if (cornerFlags & UPPER_LEFT) {
        CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);// 10
    } else {
        CGContextAddLineToPoint(context, 0, 0);
    }
    if (cornerFlags & UPPER_RIGHT) {
        CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // 11
    } else {
        CGContextAddLineToPoint(context, fw, 0);
    }
    CGContextClosePath(context);// 12
    CGContextRestoreGState(context);// 13
}

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
    addSomewhatRoundedRectToPath(context, rect, ovalWidth, ovalHeight, UPPER_LEFT|UPPER_RIGHT|LOWER_LEFT|LOWER_RIGHT);
}

static void strokeRoundedRect(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight, int cornerFlags)
{
    CGContextBeginPath(context);
    addSomewhatRoundedRectToPath(context, rect, ovalWidth, ovalHeight, cornerFlags);
    CGContextStrokePath(context);
}

static void fillRoundedRect(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight, int cornerFlags)
{
    CGContextBeginPath(context);
    addSomewhatRoundedRectToPath(context, rect, ovalWidth, ovalHeight, cornerFlags);
    CGContextFillPath(context);
}


@interface KRoundRect : UIView {
@private
    float diameter;
    int cornerFlags;
    KRGBColor color;
    KRGBColor bezelColor;
    KRGBColor outlineColor;
    int outlineWidth;
}

@property (nonatomic) KRGBColor color;
@property (nonatomic) int cornerFlags;

-(id)initWithFrame:(CGRect)frame 
    cornerDiameter:(float)_diameter 
       cornerFlags:(int)cornerFlags
             color:(KRGBColor)_color 
        bezelColor:(KRGBColor)_bezelColor 
      outlineColor:(KRGBColor)_outlineColor
      outlineWidth:(int)_outlineWidth;

+(KRoundRect *)createRoundRectInFrame:(CGRect)frame cornerDiameter:(float)diameter color:(KRGBColor)color;
+(KRoundRect *)create3dRoundRectInFrame:(CGRect)frame cornerDiameter:(float)diameter color:(KRGBColor)color bezelColor:(KRGBColor)bezelColor;
+(KRoundRect *)createOutlinedRoundRectInFrame:(CGRect)frame cornerDiameter:(float)diameter color:(KRGBColor)color outlineColor:(KRGBColor)outlineColor;

@end
