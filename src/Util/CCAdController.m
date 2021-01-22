//  Copyright 2010 StadiaJack. All rights reserved.

#import "CCAdController.h"
#import "CCPersistence.h"

//#define DEBUG_NEVER_SHOW 1
//#define DEBUG_ALWAYS_SHOW 1
//#define DEBUG_LOCAL_AD 1

#define AD_FILE @"alu.html"
//#define AD_URL @"http://devel3.mtv.rnmd.net/ww/ad.html"
#define AD_URL @"http://www.stadiagames.com/willsworld/ad.html"
#define MAX_AD_TIME 20

#define AD_PROPERTIES_MARKER @"stadiaalu"
#define AD_PROPERTIES_DELIM @":"

#define KEY_OFFSET @"aluo"
#define KEY_SPACING @"alus"
#define KEY_CAP @"aluc"
#define KEY_REQUEST_COUNT @"alurc"
#define KEY_IMPRESSION_COUNT @"aluic"
#define KEY_LAST_SEEN @"aluls"

#define KEY_AD_DATE @"aluad"

/*!
   Author: StadiaJack
   Date: 7/4/10
 */
@implementation CCAdController

-(NSString *)adPath
{
    return [NSString stringWithFormat:@"%@/%@", [CCPersistence persistenceDir:@"alu"], AD_FILE];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

// ----------------------------------------------------------------------------
#pragma mark -

-(void)displayAd
{
    [self retain];
    dismissing = NO;
    originalKeyWindow = [[UIApplication sharedApplication] keyWindow];
    UIWindow *adWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    adWindow.backgroundColor = [UIColor whiteColor];
    [adWindow makeKeyAndVisible];
    [adWindow addSubview:self.view];
    adWindow.alpha = 0;
    self.view.frame = adWindow.bounds;
}

-(BOOL)present:(NSObject<CCAdControllerDelegate> *)delegate
{
#ifdef DEBUG_NEVER_SHOW
    return NO;
#endif
    adDelegate = delegate;
    // check other installs
    BOOL b = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"ijacks://installed"]];
    if (!b) {
        b = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"stadia://installed"]];
    }
    if (b) {
        NSLog(@"No alu - thank you!!!");
#ifndef DEBUG_ALWAYS_SHOW
        return NO;
#endif
    }
    
    // check if ad exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self adPath]]) {
        NSLog(@"No alu - no file");
#ifndef DEBUG_LOCAL_AD
        return NO;
#endif
#ifndef DEBUG_ALWAYS_SHOW
        return NO;
#endif
    }
    
    // check offset
    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
    int requestCount = [[nd objectForKey:KEY_REQUEST_COUNT] intValue];
    int offset = [[nd objectForKey:KEY_OFFSET] intValue];
    if (requestCount < offset) {
        NSLog(@"No alu - offset %d not met by %d", offset, requestCount);
        [nd setObject:[NSString stringWithFormat:@"%d", requestCount+1] forKey:KEY_REQUEST_COUNT];
#ifndef DEBUG_ALWAYS_SHOW
        return NO;
#endif
    }
    
    // check spacing
    NSTimeInterval currTime = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval lastSeen = [nd doubleForKey:KEY_LAST_SEEN];
    int minutesSinceLastView = (currTime - lastSeen) / 60;
    int spacing = [nd integerForKey:KEY_SPACING];
    if (minutesSinceLastView < spacing) {
        NSLog(@"No alu - spacing %d not met by %d", spacing, minutesSinceLastView);
#ifndef DEBUG_ALWAYS_SHOW
        return NO;
#endif
    }
    
    // check freq cap
    int impressionCount = [nd integerForKey:KEY_IMPRESSION_COUNT];
    int frequencyCap = [nd integerForKey:KEY_CAP];
    if (impressionCount >= frequencyCap) {
        NSLog(@"No alu - impression count %d over cap %d", impressionCount, frequencyCap);
#ifndef DEBUG_ALWAYS_SHOW
        return NO;
#endif
    }

    // display modal web view
    [self displayAd];
    
    return YES;
}

-(void)dismiss
{
    @synchronized(self) {
        if (dismissing) return;
        dismissing = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [originalKeyWindow makeKeyWindow];
        originalKeyWindow = nil;
        UIWindow *adWindow = self.view.window;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(dismissDone)];
        adWindow.alpha = 0;
        [UIView commitAnimations];
    }
}

-(void)dismissDone
{
    UIWindow *adWindow = self.view.window;
    [self.view removeFromSuperview];
    [adWindow autorelease];
    
    [adDelegate adDismissed];
    
    [self autorelease];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *host = [[request URL] host];
    if ([host isEqualToString:@"com.stadia.close"]) {
        [self dismiss];
        return NO;
    } else if ([host isEqualToString:@"com.stadia.itunes"]) {
        NSString *itunesURL = [[[request URL] path] substringFromIndex:1];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:itunesURL]];
        return NO;
    } else if ([host isEqualToString:@"com.stadia.pin"]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        return NO;
    }
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(adDisplayed)];
    webView.window.alpha = 1;
    [UIView commitAnimations];
}

-(void)adDisplayed
{
    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
    NSTimeInterval currTime = [NSDate timeIntervalSinceReferenceDate];
    [nd setDouble:currTime forKey:KEY_LAST_SEEN];
    
    int impressionCount = [nd integerForKey:KEY_IMPRESSION_COUNT];
    [nd setInteger:impressionCount+1 forKey:KEY_IMPRESSION_COUNT];
    
    [adDelegate adDisplayed];

    // just in case the ad doesn't close itself
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:MAX_AD_TIME];
}

-(void)loadView
{
    [super loadView];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self adPath]]) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        webView.delegate = self;

        NSURL *url = [NSURL fileURLWithPath:[self adPath]];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        [webView loadRequest:req];
        
        [self.view addSubview:webView];
        [webView release];
    }
}

// ----------------------------------------------------------------------------
#pragma mark -

-(void)saveAdFile:(NSData *)data
{
    // save to file
    NSError *error = nil;
    [data writeToFile:[self adPath] options:NSAtomicWrite error:&error];
    if (error) {
        NSLog(@"Error writing alu: %@", [error localizedFailureReason]);
        [[NSFileManager defaultManager] removeItemAtPath:[self adPath] error:nil];
    }
    NSLog(@"Wrote %d alu bytes", [data length]);
    
    // parse for initial alu offset, freq cap, spacing
    NSString *adString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSScanner *scanner = [[NSScanner alloc] initWithString:adString];
    if ([scanner scanUpToString:AD_PROPERTIES_MARKER intoString:NULL]) {
        [scanner scanString:AD_PROPERTIES_MARKER intoString:NULL];
        NSString *adPropertiesString;
        if ([scanner scanUpToString:AD_PROPERTIES_MARKER intoString:&adPropertiesString]) {
            NSArray *adProperties = [adPropertiesString componentsSeparatedByString:AD_PROPERTIES_DELIM];
            NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
            if (adProperties.count >= 1) {
                [nd setObject:[adProperties objectAtIndex:0] forKey:KEY_OFFSET];
            }
            if (adProperties.count >= 2) {
                [nd setObject:[adProperties objectAtIndex:1] forKey:KEY_SPACING];
            }
            if (adProperties.count >= 3) {
                [nd setObject:[adProperties objectAtIndex:2] forKey:KEY_CAP];
            }
            // when a new ad comes, reset view count
            [nd setObject:nil forKey:KEY_IMPRESSION_COUNT];
        }
    }
    [scanner release];
    [adString release];
}

-(void)triggerRemoteAdLoad
{
//    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [self retain];
    adData = nil;
    NSURL *adUrl = [NSURL URLWithString:AD_URL];
    NSURLRequest *req = [NSURLRequest requestWithURL:adUrl];
    [NSURLConnection connectionWithRequest:req delegate:self];
//    [pool release];
}

-(void)getLatestAd
{
#ifndef DEBUG_LOCAL_AD
//    [self performSelectorInBackground:@selector(triggerRemoteAdLoad) withObject:nil];
//    [self performSelector:@selector(triggerRemoteAdLoad) withObject:nil afterDelay:0.1];
    [self retain];
    adData = nil;
    NSURL *adUrl = [NSURL URLWithString:AD_URL];
    NSURLRequest *req = [NSURLRequest requestWithURL:adUrl];
    [NSURLConnection connectionWithRequest:req delegate:self];
#else
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ad.html"];
    adData = [NSData dataWithContentsOfFile:path];
    [self saveAdFile:adData];
    adData = nil;
#endif
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    BOOL updateAd = NO;
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    int statusCode = [httpResponse statusCode];
    if (statusCode == 200) {
        updateAd = YES;
        // check Last-Modified header, only continue if later than last saved
        NSString *lastModifiedString = [[httpResponse allHeaderFields] objectForKey:@"Last-Modified"];
        if (lastModifiedString) {
            // Last-Modified=Mon, 12 Jul 2010 19:03:44 GMT
//            NSDateFormatter *formatter = [NSDateFormatter new];
//            formatter.dateFormat = @"EEE, d MMM yyyy HH:mm:ss zzz";
//            NSDate *lastModified = [formatter dateFromString:lastModifiedString];
//            if (lastModified) {
                NSString *adDateString = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_AD_DATE];
            if (adDateString && [lastModifiedString isEqualToString:adDateString]) {
//                if (adDate && [lastModified compare:adDate] != NSOrderedDescending) {
                NSLog(@"No alu load - ad not updated");
                updateAd = NO;
            } else {
                NSLog(@"Do alu load - alu updated");
            }

            // update last known date
            [[NSUserDefaults standardUserDefaults] setObject:lastModifiedString forKey:KEY_AD_DATE];
                
//            } else {
//                NSLog(@"Do alu load - no valid last modified date");
//            }
        } else {
            NSLog(@"Do alu load - no last modified header");
        }
    } else {
        NSLog(@"No alu load - status %d", statusCode);
    }
    
    if (updateAd) {
        adData = [NSMutableData new];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)newData
{
    [adData appendData:newData];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"No alu load - connection error");
    [self autorelease];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (adData) {
        if ([adData length] > 0) {
            [self saveAdFile:adData];
        } else {
            NSLog(@"No alu load - no data");
        }
    }
    [self autorelease];
}

// ----------------------------------------------------------------------------

-(void)dealloc
{
//    NSLog(@"CCAdController dealloc");
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [adData release];
    adDelegate = nil;
    [super dealloc];
}

@end
