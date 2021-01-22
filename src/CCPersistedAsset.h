//  Copyright 2010 StadiaJack. All rights reserved.

/*!
   Author: StadiaJack
   Date: 3/14/10
 */
@interface CCPersistedAsset : NSObject<NSCoding> {
    int assetId;
    NSString *name;
    NSString *url;
}

@property (nonatomic, assign) int assetId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *url;

+(CCPersistedAsset *)includedAssetNamed:(NSString *)name assetId:(int)assetId;

@end
