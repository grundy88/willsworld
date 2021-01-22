//  Copyright 2009 StadiaJack. All rights reserved.

#define CHAR_WIDTH 17
#define CHAR_HEIGHT 23

/*!
   Author: StadiaJack
   Date: 10/20/09
 */
@interface CCDigits : NSObject {
    CGImageRef *charList;
    CGAffineTransform transform;
}

+(CCDigits *)instance;

-(void)drawString:(CGContextRef)context string:(NSString*)s x:(int)x y:(int)y yellow:(BOOL)yellow;
-(void)drawYellowString:(CGContextRef)context string:(NSString*)s x:(int)x y:(int)y;
-(void)drawGreenString:(CGContextRef)context string:(NSString*)s x:(int)x y:(int)y;
//-(void)drawCenteredString:(CGContextRef)context string:(NSString *)s x:(int)x y:(int)y;
//-(void)drawRightJustifiedString:(CGContextRef)context string:(NSString *)s x:(int)x y:(int)y;
//-(void)drawCharIndex:(CGContextRef)context index:(int)index x:(int)x y:(int)y;
//-(int)getCharIndex:(char)ch;

@end
