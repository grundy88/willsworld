//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCDigits.h"

#define FILE @"digits.png"

/*!
   Author: StadiaJack
   Date: 10/20/09
 */
@implementation CCDigits

+(CCDigits *)instance
{
	static CCDigits *instance = nil;
	@synchronized(self) {
		if (!instance) {
			instance = [CCDigits new];
        }
	}
    
	return instance;
}


-(id)init
{
    if (self = [super init]) {
        UIImage *fonts = [UIImage imageNamed:FILE];
        int numChars = fonts.size.height / CHAR_HEIGHT;
        charList = malloc(numChars * sizeof(CGImageRef));
        int y = 0;
        for (int i = 0; i < numChars; i++) {
            CGRect charRect = CGRectMake(0, y, CHAR_WIDTH, CHAR_HEIGHT);
            CGImageRef charImage = CGImageCreateWithImageInRect(fonts.CGImage, charRect);
            charList[i] = charImage;
            y += CHAR_HEIGHT;
        }
        
        transform = CGAffineTransformMake(
                                          1.0,  0.0,
                                          0.0, -1.0,
                                          0.0,  0.0);
    }
    return self;
}

-(void)drawCharIndex:(CGContextRef)context index:(int)index x:(int)x y:(int)y
{
    CGImageRef charImage = charList[index];
    
    CGContextSaveGState(context);
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(context, CGRectMake(x, -y-CHAR_HEIGHT, CHAR_WIDTH, CHAR_HEIGHT), charImage);
    CGContextRestoreGState(context);
}

-(int)getCharIndex:(char)ch yellow:(BOOL)yellow
{
    int sx = 1;
    if ((ch >= '0') && (ch <= '9')) sx = 59-ch;
    if (ch == '-') sx = 0;
    if (!yellow) sx += 12;
    return sx;
}

-(void)drawString:(CGContextRef)context string:(NSString*)s x:(int)x y:(int)y yellow:(BOOL)yellow
{
    if (s == nil) return;
    int dx = x;
    int len = s.length;
    unichar chars[len];
    [s getCharacters:chars];
    for (int i = 0; i < len; i++) {
        int sx = [self getCharIndex:chars[i] yellow:yellow];
        if (sx >= 0) {
            [self drawCharIndex:context index:sx x:dx y:y];
        }
        dx += CHAR_WIDTH;
    }
}

-(int)stringWidth:(NSString *)s
{
    return s.length * (CHAR_WIDTH+1) - 1;
}

//-(void)drawCenteredString:(CGContextRef)context string:(NSString *)s x:(int)x y:(int)y
//{
//    return [self drawString:context string:s x:x-([self stringWidth:s]/2) y:y];
//}
//
//-(void)drawRightJustifiedString:(CGContextRef)context string:(NSString *)s x:(int)x y:(int)y
//{
//    return [self drawString:context string:s x:x-[self stringWidth:s] y:y];
//}

-(void)drawYellowString:(CGContextRef)context string:(NSString*)s x:(int)x y:(int)y
{
    [self drawString:context string:s x:x y:y yellow:YES];
}

-(void)drawGreenString:(CGContextRef)context string:(NSString*)s x:(int)x y:(int)y
{
    [self drawString:context string:s x:x y:y yellow:NO];
}

-(void)dealloc
{
    UIImage *fonts = [UIImage imageNamed:FILE];
    int numChars = fonts.size.height / CHAR_HEIGHT;
    for (int i = 0; i < numChars; i++) {
        CGImageRelease(charList[i]);
    }
    free(charList);
    [super dealloc];
}

@end
