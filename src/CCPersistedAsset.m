//  Copyright 2010 StadiaJack. All rights reserved.

#import "CCPersistedAsset.h"

#define CODE_ASSET_ID @"ai"
#define CODE_NAME @"n"
#define CODE_URL @"u"

/*!
   Author: StadiaJack
   Date: 3/14/10
 */
@implementation CCPersistedAsset

@synthesize assetId;
@synthesize name;
@synthesize url;

+(CCPersistedAsset *)includedAssetNamed:(NSString *)name assetId:(int)assetId
{
    CCPersistedAsset *asset = [CCPersistedAsset new];
    asset.assetId = assetId;
    asset.name = name;
    asset.url = nil;
    return [asset autorelease];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        self.assetId = [coder decodeIntForKey:CODE_ASSET_ID];
        self.name = [coder decodeObjectForKey:CODE_NAME];
        self.url = [coder decodeObjectForKey:CODE_URL];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt:assetId forKey:CODE_ASSET_ID];
    [coder encodeObject:name forKey:CODE_NAME];
    [coder encodeObject:url forKey:CODE_URL];
}

-(void)dealloc
{
    [name release];
    [url release];
    [super dealloc];
}

@end
