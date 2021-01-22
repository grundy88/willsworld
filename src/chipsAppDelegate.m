
#import "chipsAppDelegate.h"
#import "CCController.h"
#import "CCSkin.h"
#import "CCSounds.h"
#import "CCPersistence.h"

enum {
    kTagAlertFirstTime,
//    kTagAlertRate,
    kTagAlertBackdrop
};

#define KEY_APPOPEN_COUNT @"appLaunchCount"
//#define KEY_RATE_ALERT_SHOWN @"appLaunchRateDone"

@implementation chipsAppDelegate

@synthesize window;

-(void)appLaunchAd
{
    CCAdController *adController = [CCAdController new];
    [adController getLatestAd];
    if ([adController present:self]) {
        loadingAlu = YES;
        displayingAlu = YES;
    }
    [adController release];
}

//-(void)showRateAlert
//{
////    UIView *v = [[UIView alloc] initWithFrame:window.bounds];
////    v.backgroundColor = [UIColor blackColor];
////    v.alpha = 0.8;
////    v.tag = kTagAlertBackdrop;
////    [window addSubview:v];
////    [v release];
//
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Thanks for playing!"
//                                                        message:@"Hopefully you're having fun! I would love it if you could take a few seconds and go rate this app..."
//                                                       delegate:self 
//                                              cancelButtonTitle:@"No I won't" 
//                                              otherButtonTitles:@"Sure I'll do it", nil];
//    alertView.tag = kTagAlertRate;
//    [alertView show];
//    [self performSelector:@selector(xxx:) withObject:alertView afterDelay:0.01];
//}
//
//-(void)xxx:(UIAlertView *)alertView
//{
//    alertView.window.backgroundColor = [UIColor blackColor];
//    alertView.window.alpha = 0.8;
//    [alertView autorelease];
//}
//
//-(void)checkForRateAlert
//{
//    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
//    if (![nd boolForKey:KEY_RATE_ALERT_SHOWN]) {
//        int appOpenCount = [nd integerForKey:KEY_APPOPEN_COUNT];
//        if (appOpenCount == 3) {
//            [nd setBool:YES forKey:KEY_RATE_ALERT_SHOWN];
//            [self showRateAlert];
////            [self performSelector:@selector(showRateAlert) withObject:nil afterDelay:1];
//        } else {
//            [nd setInteger:appOpenCount+1 forKey:KEY_APPOPEN_COUNT];
//        }
//    }
//}
//
//-(void)rateApp
//{
//    // open the app store app to the ratings page
//    NSString *rateURL = @"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=387318366&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software";
//    [[UIApplication sharedApplication] performSelector:@selector(openURL:) withObject:[NSURL URLWithString:rateURL] afterDelay:1.0];
//}

-(void)startup
{
    // load current player
    // load current level pack
    // load current level

    [self appLaunchAd];
//    if (!loadingAlu) {
//        [self checkForRateAlert];
//    }
    
    firstTimeEver = ![[NSUserDefaults standardUserDefaults] objectForKey:PLAYER_LIST_KEY];
    
    // initialize sounds
    [CCSounds instance];
    
    loadingController = YES;
    CCController *controller = [CCController instance];
    [controller performSelectorInBackground:@selector(backgroundLoadCurrentPlayer:) withObject:self];
//    [controller loadCurrentPlayer];
}

-(void)firstTimeAlert
{
    if (firstTimeEver) {
        [[[CCController instance] mainView] startMenuButtonPulse];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome!" message:@"The pulsing button down there is the menu button. You can always press it to pause the game and check out the menu.\n\nTap anywhere else to start playing.\n\nHave fun!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert setTransform:CGAffineTransformMakeTranslation(0, 70)];
        alert.tag = kTagAlertFirstTime;
        [alert show];
        [alert autorelease];
        firstTimeEver = NO;
    }
}

-(void)hideSplash
{
    [window bringSubviewToFront:splashView];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(splashFadeDone)];
    splashView.alpha = 0;
    [UIView commitAnimations];
}

-(void)transitionToGame
{
    CCController *controller = [CCController instance];
    [window addSubview:controller.view];
    
    [self hideSplash];
    if (!displayingAlu) [self firstTimeAlert];
}

-(void)adDisplayed
{
    loadingAlu = NO;
    if (!loadingController) {
        if (![[CCController instance] isMenuUp]) {
            [self transitionToGame];
        } else {
            [self hideSplash];
        }
    }
}

-(void)adDismissed
{
    displayingAlu = NO;
    [self firstTimeAlert];
}

-(void)controllerLoadDone:(CCController *)controller
{
//    [NSThread sleepForTimeInterval:3];
    loadingController = NO;
    if (!loadingAlu) [self transitionToGame];
}

-(void)splashFadeDone
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [splashView removeFromSuperview];
    splashView = nil;
}

-(void)rotateActivity
{
    activityView.tag += 5;
    if (activityView.tag >= 360) activityView.tag = 0;
    activityView.transform = CGAffineTransformMakeRotation(activityView.tag * M_PI / 180);
    [self performSelector:@selector(rotateActivity) withObject:nil afterDelay:0.01];
}

-(void)showSplash
{
    NSString *defaultImageName;
    
#ifdef UI_USER_INTERFACE_IDIOM
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        defaultImageName = @"Default-Portrait.png";
    } else
#endif
    {
        defaultImageName = @"Default.png";
    }
    
    UIImage *splashImage = [UIImage imageNamed:defaultImageName];
    UIImageView *splashImageView = [[UIImageView alloc] initWithImage:splashImage];
    splashImageView.frame = [[UIScreen mainScreen] applicationFrame];
    [window addSubview:splashImageView];
    [splashImageView release];
    splashView = splashImageView;
    
    int n = (arc4random()%7)+1;
    UIImage *activityImage = [UIImage imageNamed:[NSString stringWithFormat:@"splash-activity-%d.png", n]];
    UIImageView *activityImageView = [[UIImageView alloc] initWithImage:activityImage];
    
    int spinnerSize;
    int spinnerY;
#ifdef UI_USER_INTERFACE_IDIOM
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        spinnerSize = 84;
        spinnerY = 650;
    } else
#endif
    {
        spinnerSize = 35;
        spinnerY = 315;
    }
    
    activityImageView.frame = CGRectMake((splashImageView.bounds.size.width-spinnerSize)/2, spinnerY, spinnerSize, spinnerSize);;
    [splashImageView addSubview:activityImageView];
    [activityImageView release];
    
    activityView = activityImageView;
    activityView.tag = 0;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    loadingAlu = NO;
    displayingAlu = NO;
    
//    [NSThread sleepForTimeInterval:3];
    [self showSplash];
    [self rotateActivity];
    
    [self performSelector:@selector(startup) withObject:nil afterDelay:0.01];
//    [self performSelector:@selector(startup) withObject:nil afterDelay:5];
    
    [window makeKeyAndVisible];
//    NSLog(@"Num levels: %d", [CCDataReader getNumLevelsInFile:FILE]);

//    int numLevels = [CCDataReader getNumLevelsInFile:FILE];
//    for (int level = 1; level <= numLevels; level++) {
//        [[CCDataReader newLevel:level fromFile:FILE] release];
//    }

//    CCLevel *level = [CCDataReader newLevel:5 fromFile:FILE];
    
//    [CCDataReader report];

//    CCMainView *mainView = [[CCMainView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
//    [window addSubview:mainView];
//    
//    [mainView startLevel:level];
//    
//    [mainView release];
//    [level release];
}

-(void)applicationWillResignActive:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    UIView *failAlertView = [[application keyWindow] viewWithTag:TAG_FAIL_ALERT];
    if (failAlertView) {
        UIAlertView *failAlert = (UIAlertView *)failAlertView;
        [failAlert dismissWithClickedButtonIndex:0 animated:NO];
        [[CCController instance] died:NO];
    }
    [[CCController instance] showMenu];
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
    [self showSplash];
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
    loadingAlu = NO;
    displayingAlu = NO;
    [self rotateActivity];
    [self appLaunchAd];
    if (!loadingAlu) {
        [self hideSplash];
//        [self checkForRateAlert];
    }
}

-(void)applicationWillTerminate:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case kTagAlertFirstTime: {
            CCController *controller = [CCController instance];
            [controller.mainView stopMenuButtonPulse];
            break;
        }
//        case kTagAlertRate:
//            [[window viewWithTag:kTagAlertBackdrop] removeFromSuperview];
//            if (buttonIndex == 1) {
//                [self rateApp];
//            }
//            break;
    }
}

- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
