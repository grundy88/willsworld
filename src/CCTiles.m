
#import "CCTiles.h"
#import "CCCommon.h"
#import "CCPersistence.h"
#import "CCPersistedAsset.h"

#define NUM_MONSTER_TYPES 9

@implementation CCTiles

//@synthesize tiles;

static NSString *monsterClassNames[] = {
    @"CCBug",
    @"CCFireball",
    @"CCBall", 
    @"CCTank", 
    @"CCGlider", 
    @"CCTeeth", 
    @"CCWalker", 
    @"CCBlob",
    @"CCParamecium"
};

+(CCTiles *)instance
{
	static CCTiles *instance = nil;
	@synchronized(self) {
		if (!instance) {
			instance = [CCTiles new];
        }
	}
	return instance;
}


CGImageRef CopyImageAndAddAlphaChannel(CGImageRef sourceImage) {
	CGImageRef retVal = NULL;
	
	size_t width = CGImageGetWidth(sourceImage);
	size_t height = CGImageGetHeight(sourceImage);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	CGContextRef offscreenContext = CGBitmapContextCreate(NULL, width, height, 
                                                          8, 0, colorSpace, kCGImageAlphaNoneSkipFirst);
	
	if (offscreenContext != NULL) {
		CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), sourceImage);
		
		retVal = CGBitmapContextCreateImage(offscreenContext);
		CGContextRelease(offscreenContext);
	}
	
	CGColorSpaceRelease(colorSpace);
	
	return retVal;
}

-(void)loadTilesFromImage:(UIImage *)tilesetImage
{
    if (tileImages) {
        for (int i = 0x00; i < NUM_TILES+4; i++) {
            CGImageRelease(tileImages[i]);
        }
        free(tileImages);
    }
    if (tileLayers) {
        for (int i = 0x00; i < NUM_TILES+4; i++) {
            CGLayerRelease(tileLayers[i]);
        }
        free(tileLayers);
    }
    tileImages = NULL;
    tileLayers = NULL;
    
#ifdef DEBUG
    NSLog(@"Begin tileset image processing");
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
#endif
    
    int requiredWidth = TILE_SIZE * TILE_SOURCE_WIDTH;
    int requiredHeight = TILE_SIZE * TILE_SOURCE_HEIGHT;
    CGFloat scale = 1.0;
    if ([tilesetImage respondsToSelector:@selector(scale)]) scale = tilesetImage.scale;
    BOOL tilesAreImages = (scale == 1);
//    BOOL tilesAreImages = NO;
   
#ifdef DEBUG
    NSLog(@"!!! tileset image scale is %f  %f", scale, tilesetImage.size.width);
#endif
    UIImage *tilesetImg;
    if (tilesetImage.size.width != requiredWidth && tilesetImage.size.height != requiredHeight) {

        NSLog(@"Resizing tileset to %dx%d", requiredWidth, requiredHeight);
        
        CGRect newRect = CGRectMake(0, 0, requiredWidth, requiredHeight);
        CGImageRef imageRef = tilesetImage.CGImage;

        if (UIGraphicsBeginImageContextWithOptions) {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(requiredWidth, requiredHeight), NO, 0);
        } else {
            UIGraphicsBeginImageContext(CGSizeMake(requiredWidth, requiredHeight));
        }
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGAffineTransform transform = CGAffineTransformMake(1.0,  0.0,
                                                            0.0, -1.0,
                                                            0.0,  requiredHeight);
        CGContextConcatCTM(context, transform);
        CGContextDrawImage(context, newRect, imageRef);
        tilesetImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        
//        // Build a context that's the same dimensions as the new size
//        CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
//        if (CGImageGetAlphaInfo(imageRef) == kCGImageAlphaNone) {
//            bitmapInfo &= ~kCGBitmapAlphaInfoMask;
//            bitmapInfo |= kCGImageAlphaNoneSkipLast;
//        }
//        CGContextRef bitmap = CGBitmapContextCreate(NULL,
//                                                    newRect.size.width,
//                                                    newRect.size.height,
//                                                    CGImageGetBitsPerComponent(imageRef),
//                                                    0,
//                                                    CGImageGetColorSpace(imageRef),
//                                                    bitmapInfo);
////                                                    CGImageGetBitmapInfo(imageRef));
//        CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);
//        CGContextDrawImage(bitmap, newRect, imageRef);
//        CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
//        tilesetImg = [UIImage imageWithCGImage:newImageRef];
//        CGContextRelease(bitmap);
//        CGImageRelease(newImageRef);

    } else {
        tilesetImg = tilesetImage;
    }
    
    CGImageRef tileset = CopyImageAndAddAlphaChannel(tilesetImg.CGImage);
//    CGImageRef tileset = CGImageRetain(tilesetImage.CGImage);
    
//    UIImage *tileset = [UIImage imageWithData:data];
    CGAffineTransform transform = CGAffineTransformMake(1.0,  0.0,
                                                        0.0, -1.0,
                                                        0.0,  0.0);
    
    if (tilesAreImages) {
        tileImages = malloc(sizeof(CGImageRef) * (NUM_TILES+4));
    } else {
        tileLayers = malloc(sizeof(CGLayerRef) * (NUM_TILES+4));
    }
    for (int i = 0x00; i < NUM_TILES; i++) {
//        NSLog(@" - creating tile %d", i);
        if (isTransparent(i)) {
            int imagex = ((i+0x30) / TILE_SOURCE_HEIGHT) * TILE_SIZE;
            int imagey = ((i+0x30) % TILE_SOURCE_HEIGHT) * TILE_SIZE;
            int maskx = ((i+0x60) / TILE_SOURCE_HEIGHT) * TILE_SIZE;
            int masky = ((i+0x60) % TILE_SOURCE_HEIGHT) * TILE_SIZE;

            CGImageRef img = CGImageCreateWithImageInRect(tileset, CGRectMake(imagex * scale, imagey * scale, TILE_SIZE * scale, TILE_SIZE * scale));
            CGImageRef maskRef = CGImageCreateWithImageInRect(tileset, CGRectMake(maskx * scale, masky * scale, TILE_SIZE * scale, TILE_SIZE * scale));
            
            if (UIGraphicsBeginImageContextWithOptions) {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(TILE_SIZE * scale, TILE_SIZE * scale), NO, 0);
            } else {
                UIGraphicsBeginImageContext(CGSizeMake(TILE_SIZE, TILE_SIZE));
            }
            CGContextRef context = UIGraphicsGetCurrentContext();
            if (tilesAreImages) {
                CGContextClipToMask(context, CGRectMake(0, 0, TILE_SIZE * scale, TILE_SIZE * scale), maskRef);
                CGContextDrawImage(context, CGRectMake(0, 0, TILE_SIZE * scale, TILE_SIZE * scale), img);
                tileImages[i] = CGImageRetain(UIGraphicsGetImageFromCurrentImageContext().CGImage);
            } else {
                tileLayers[i] = CGLayerCreateWithContext(context, CGSizeMake(TILE_SIZE * scale, TILE_SIZE * scale), NULL);
                CGContextRef layerContext = CGLayerGetContext(tileLayers[i]);
                CGContextConcatCTM(layerContext, transform);
                CGContextClipToMask(layerContext, CGRectMake(0, -TILE_SIZE * scale, TILE_SIZE * scale, TILE_SIZE * scale), maskRef);
                CGContextDrawImage(layerContext, CGRectMake(0, -TILE_SIZE * scale, TILE_SIZE * scale, TILE_SIZE * scale), img);
            }
            UIGraphicsEndImageContext();
            
//            if (UIGraphicsBeginImageContextWithOptions) {
//                UIGraphicsBeginImageContextWithOptions(CGSizeMake(TILE_SIZE * scale, TILE_SIZE * scale), NO, 0);
//            } else {
//                UIGraphicsBeginImageContext(CGSizeMake(TILE_SIZE, TILE_SIZE));
//            }
//            CGContextRef context = UIGraphicsGetCurrentContext();
//            CGContextClipToMask(context, CGRectMake(0, 0, TILE_SIZE * scale, TILE_SIZE * scale), maskRef);
//            CGContextDrawImage(context, CGRectMake(0, 0, TILE_SIZE * scale, TILE_SIZE * scale), img);
//            tiles[i] = CGImageRetain(UIGraphicsGetImageFromCurrentImageContext().CGImage);
//            UIGraphicsEndImageContext();
            
//            CGImageRef img = CGImageCreateWithImageInRect(tileset.CGImage, CGRectMake(imagex * scale, imagey * scale, TILE_SIZE * scale, TILE_SIZE * scale));
//            CGImageRef maskRef = CGImageCreateWithImageInRect(tileset.CGImage, CGRectMake(maskx * scale, masky * scale, TILE_SIZE * scale, TILE_SIZE * scale));
//
//            if (UIGraphicsBeginImageContextWithOptions) {
//                UIGraphicsBeginImageContextWithOptions(CGSizeMake(TILE_SIZE * scale, TILE_SIZE * scale), NO, 0);
//            } else {
//                UIGraphicsBeginImageContext(CGSizeMake(TILE_SIZE, TILE_SIZE));
//            }
//            CGContextRef context = UIGraphicsGetCurrentContext();
//            tiles[i] = CGLayerCreateWithContext(context, CGSizeMake(TILE_SIZE * scale, TILE_SIZE * scale), NULL);
//            CGContextRef layerContext = CGLayerGetContext(tiles[i]);
//            CGContextConcatCTM(layerContext, transform);
//            CGContextClipToMask(layerContext, CGRectMake(0, -TILE_SIZE * scale, TILE_SIZE * scale, TILE_SIZE * scale), maskRef);
//            CGContextDrawImage(layerContext, CGRectMake(0, -TILE_SIZE * scale, TILE_SIZE * scale, TILE_SIZE * scale), img);
//            UIGraphicsEndImageContext();
//            
            if (isChip(i)) {
                // special layers for chip in water
                int j = i+4;
                
                if (UIGraphicsBeginImageContextWithOptions) {
                    UIGraphicsBeginImageContextWithOptions(CGSizeMake(TILE_SIZE * scale, TILE_SIZE/2 * scale), NO, 0);
                } else {
                    UIGraphicsBeginImageContext(CGSizeMake(TILE_SIZE, TILE_SIZE/2));
                }
                CGContextRef context = UIGraphicsGetCurrentContext();
                if (tilesAreImages) {
                    CGContextClipToMask(context, CGRectMake(0, -TILE_SIZE/2 * scale, TILE_SIZE * scale, TILE_SIZE * scale), maskRef);
                    CGContextDrawImage(context, CGRectMake(0, -TILE_SIZE/2 * scale, TILE_SIZE * scale, TILE_SIZE * scale), img);
                    tileImages[j] = CGImageRetain(UIGraphicsGetImageFromCurrentImageContext().CGImage);
                } else {
                    tileLayers[j] = CGLayerCreateWithContext(context, CGSizeMake(TILE_SIZE * scale, TILE_SIZE/2 * scale), NULL);
                    CGContextRef layerContext = CGLayerGetContext(tileLayers[j]);
                    CGContextConcatCTM(layerContext, transform);
                    CGContextClipToMask(layerContext, CGRectMake(0, -TILE_SIZE * scale, TILE_SIZE * scale, TILE_SIZE * scale), maskRef);
                    CGContextDrawImage(layerContext, CGRectMake(0, -TILE_SIZE * scale, TILE_SIZE * scale, TILE_SIZE * scale), img);
                }
                UIGraphicsEndImageContext();
            }
            
            CGImageRelease(maskRef);
            CGImageRelease(img);
        } else {
            int x = (i / TILE_SOURCE_HEIGHT) * TILE_SIZE;
            int y = (i % TILE_SOURCE_HEIGHT) * TILE_SIZE;

            CGImageRef img = CGImageCreateWithImageInRect(tileset, CGRectMake(x * scale, y * scale, TILE_SIZE * scale, TILE_SIZE * scale));
            
            if (UIGraphicsBeginImageContextWithOptions) {
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(TILE_SIZE * scale, TILE_SIZE * scale), NO, 0);
            } else {
                UIGraphicsBeginImageContext(CGSizeMake(TILE_SIZE, TILE_SIZE));
            }
            CGContextRef context = UIGraphicsGetCurrentContext();
            if (tilesAreImages) {
                CGContextDrawImage(context, CGRectMake(0, 0, TILE_SIZE * scale, TILE_SIZE * scale), img);
                tileImages[i] = CGImageRetain(UIGraphicsGetImageFromCurrentImageContext().CGImage);
            } else {
                tileLayers[i] = CGLayerCreateWithContext(context, CGSizeMake(TILE_SIZE * scale, TILE_SIZE * scale), NULL);
                CGContextRef layerContext = CGLayerGetContext(tileLayers[i]);
                CGContextConcatCTM(layerContext, transform);
                CGContextDrawImage(layerContext, CGRectMake(0, -TILE_SIZE * scale, TILE_SIZE * scale, TILE_SIZE * scale), img);
            }
            UIGraphicsEndImageContext();
            CGImageRelease(img);
            
//            CGImageRef img = CGImageCreateWithImageInRect(tileset.CGImage, CGRectMake(x * scale, y * scale, TILE_SIZE * scale, TILE_SIZE * scale));
//            
//            if (UIGraphicsBeginImageContextWithOptions) {
//                UIGraphicsBeginImageContextWithOptions(CGSizeMake(TILE_SIZE * scale, TILE_SIZE * scale), NO, 0);
//            } else {
//                UIGraphicsBeginImageContext(CGSizeMake(TILE_SIZE, TILE_SIZE));
//            }
//            CGContextRef context = UIGraphicsGetCurrentContext();
//            tiles[i] = CGLayerCreateWithContext(context, CGSizeMake(TILE_SIZE * scale, TILE_SIZE * scale), NULL);
//            CGContextRef layerContext = CGLayerGetContext(tiles[i]);
//            CGContextConcatCTM(layerContext, transform);
//            CGContextDrawImage(layerContext, CGRectMake(0, -TILE_SIZE * scale, TILE_SIZE * scale, TILE_SIZE * scale), img);
//            UIGraphicsEndImageContext();
//            CGImageRelease(img);
        }
    }
    CGImageRelease(tileset);
#ifdef DEBUG
    NSLog(@"End tileset image processing - %f", [NSDate timeIntervalSinceReferenceDate] - start);
#endif
}

//-(NSString *)loadTileset:(NSString *)tilesetFilename
-(void)loadTileset:(CCPersistedAsset *)asset
{
    UIImage *tileset = [CCPersistence getImageAssetOfType:ASSET_TYPE_TILESET 
                                                  assetId:asset.assetId
                                                 fallback:BUILTIN_TILESET_1];

    [self loadTilesFromImage:tileset];
}

//-(id)init
//{
//    if (self = [super init]) {
//        tiles = nil;
//        NSString *tilesetFilename = [CCPersistence currentTileset];
//        [self loadTileset:tilesetFilename];
//    }
//    return self;
//}

-(NSString *)monsterClassName:(byte)objectCode
{
    int i = (objectCode - 0x40) / 4;
    if (i < 0 || i >= NUM_MONSTER_TYPES) return nil;
    return monsterClassNames[i];
}

-(CCDirection)dirFromFloor:(byte)code
{
    CCDirection d = NONE;
    switch (code) {
        case FORCE_N:
            d = NORTH;
            break;
        case FORCE_W:
            d = WEST;
            break;
        case FORCE_S:
            d = SOUTH;
            break;
        case FORCE_E:
            d = EAST;
            break;
    }
    return d;
}

-(void)drawTile:(byte)tileCode inRect:(CGRect)r context:(CGContextRef)context
{
    if (tileImages) {
        CGContextDrawImage(context, r, tileImages[tileCode]);
    } else {
        CGContextDrawLayerInRect(context, r, tileLayers[tileCode]);
    }
}


-(void)dealloc
{
    if (tileImages) {
        for (int i = 0x00; i < NUM_TILES+4; i++) {
            CGImageRelease(tileImages[i]);
        }
        free(tileImages);
    }
    if (tileLayers) {
        for (int i = 0x00; i < NUM_TILES+4; i++) {
            CGLayerRelease(tileLayers[i]);
        }
        free(tileLayers);
    }
    [super dealloc];
}

@end
