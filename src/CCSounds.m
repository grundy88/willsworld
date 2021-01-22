
#import "CCSounds.h"
#import "CCController.h"

#include <AudioToolbox/AudioToolbox.h>
#include <CoreFoundation/CoreFoundation.h>

#define CC_SOUND_NOTIFICATION @"ccSound"

#define NUM_SOUNDS 18

static NSString *soundFiles[NUM_SOUNDS] = {
    @"clickDown.wav",
    @"clickUp.wav",
    @"woohoo.wav",
    @"waa.wav",
    @"teleport.wav",
    @"splash.wav",
    @"oof.wav",
    @"fire.wav",
    @"bomb.wav",
    @"coin.wav",
    @"key.wav",
    @"footwear.wav",
    @"thief.wav",
    @"aw.wav",
    @"gate.wav",
    @"door.wav",
    @"popup.wav",
    @"pop.wav"
};

static SystemSoundID soundIds[NUM_SOUNDS];

/*!
   Author: StadiaJack
   Date: 8/31/08
 */
@implementation CCSounds

+(CCSounds *)instance
{
    static CCSounds *instance;
    @synchronized(self) {
        if (!instance) {
            instance = [[CCSounds alloc] init];
        }
    }
    return instance;
}

-(void)setupSounds
{
    @synchronized(self) {
        if (initialized) return;
        initialized = TRUE;
    }
    
    AudioSessionInitialize(NULL, NULL, NULL, (void*)self);
    UInt32 category = kAudioSessionCategory_UserInterfaceSoundEffects;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);

    for (int index = 0; index < NUM_SOUNDS; index++)
    {
        const char *soundFilePath = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:soundFiles[index]] UTF8String];
        CFStringRef s = CFStringCreateWithCString(NULL, soundFilePath, kCFStringEncodingASCII);
        CFURLRef soundFileURL = CFURLCreateWithFileSystemPath (
                                                               kCFAllocatorDefault,
                                                               s,
                                                               kCFURLPOSIXPathStyle,
                                                               FALSE
                                                               );
        AudioServicesCreateSystemSoundID (soundFileURL, &soundIds[index]);
        CFRelease (soundFileURL);
        CFRelease(s);
    }
}

-(id)init
{
    if (self = [super init]) {
        [self performSelector:@selector(setupSounds)];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerPlaySound:) name:CC_SOUND_NOTIFICATION object:nil];
    }
    return self;
}

+(void)sound:(CCSoundId)soundId
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CC_SOUND_NOTIFICATION 
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:soundId] forKey:CC_SOUND_NOTIFICATION]];
}

// -----------------------------------------------------------------------------------------------

-(void)playSound:(int)soundIndex
{
    if (initialized) {
        AudioServicesPlaySystemSound(soundIds[soundIndex]);
    }
}

-(void)triggerPlaySound:(NSNotification *)notification
{
    int soundIndex = [[[notification userInfo] objectForKey:CC_SOUND_NOTIFICATION] intValue];
    [self playSound:soundIndex];
}

-(void)playClickDown
{
    if ([CCController instance].currentPlayer.settings.gameSoundLevel > CCGameSoundsNone) {
        [self playSound:ccsClickDown];
    }
}

-(void)playClickUp
{
    if ([CCController instance].currentPlayer.settings.gameSoundLevel > CCGameSoundsNone) {
        [self playSound:ccsClickUp];
    }
}

// -----------------------------------------------------------------------------------------------

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for (int index = 0; index < NUM_SOUNDS; index++)
    {
        AudioServicesDisposeSystemSoundID(soundIds[index]);
    }
    [super dealloc];
}

@end
