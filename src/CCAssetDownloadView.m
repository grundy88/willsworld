//  Copyright 2010 StadiaJack. All rights reserved.

#import "CCAssetDownloadView.h"
#import "CCMenuButton.h"
#import "CCPersistence.h"
#import "CCDataReader.h"

enum {
    TAG_BACK = 1,
    TAG_WAIT = 2,
    TAG_SPIN = 3
};


/*!
   Author: StadiaJack
   Date: 3/3/10
 */
@implementation CCAssetDownloadView

-(id)initWithFrame:(CGRect)frame 
              menu:(CCMenuView *)_menu
  previousEntryKey:(NSString *)previousEntryKey
      instructions:(NSString *)instructions
         assetType:(NSString *)assetType
      backSelector:(SEL)backSelector
    verifySelector:(SEL)verifySelector
{
    if (self = [super initWithFrame:frame menu:_menu]) {
        _previousEntryKey = [previousEntryKey copy];
        _assetType = [assetType copy];
        _verifySelector = verifySelector;
        
        CCMenuButton *backButton = [[CCMenuButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        backButton.title = @"Cancel";
        backButton.clickTarget = menu;
        backButton.clickSelector = backSelector;
        backButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        backButton.tag = TAG_BACK;
        [self addSubview:backButton];
        [backButton release];
        
        UILabel *instructionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, frame.size.width, 50)];
        instructionsLabel.text = instructions;
        instructionsLabel.backgroundColor = [UIColor clearColor];
        instructionsLabel.numberOfLines = 2;
        [self addSubview:instructionsLabel];
        [instructionsLabel release];
        
        NSString *lastEntry = [[NSUserDefaults standardUserDefaults] objectForKey:previousEntryKey];
        if (!lastEntry) lastEntry = @"http://";
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 100, frame.size.width, 25)];
        textField.delegate = self;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.keyboardType = UIKeyboardTypeURL;
        textField.returnKeyType = UIReturnKeyGo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.text = lastEntry;
        [self addSubview:textField];
        [textField release];
        
        [textField becomeFirstResponder];
    }
    return self;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    textField.enabled = NO;
    [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:_previousEntryKey];
    
    UILabel *wait = [[UILabel alloc] initWithFrame:CGRectMake(0, 140, self.frame.size.width, 25)];
    wait.text = @"Downloading - please wait...";
    wait.backgroundColor = [UIColor clearColor];
    wait.tag = TAG_WAIT;
    [self addSubview:wait];
    [wait release];
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activity.center = CGPointMake(self.frame.size.width/2, 180);
    activity.tag = TAG_SPIN;
    [activity startAnimating];
    [self addSubview:activity];
    [activity release];
    
    
    [self performSelector:@selector(doDownload:) withObject:textField.text afterDelay:0.1];
    
    return YES;
}

-(void)doDownload:(NSString *)url
{
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                         cachePolicy:NSURLRequestReloadIgnoringCacheData
                                     timeoutInterval:20];
    NSURLResponse *response;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req
                                         returningResponse:&response
                                                     error:&error];
    
    UILabel *report = [[UILabel alloc] initWithFrame:CGRectMake(0, 140, self.frame.size.width, 100)];
    report.backgroundColor = [UIColor clearColor];
    report.adjustsFontSizeToFitWidth = YES;
    report.numberOfLines = 0;
    [self addSubview:report];
    [report release];
    
    if (error) {
        NSLog(@"%@", [NSString stringWithFormat:@"Error: %@", [error localizedDescription]]);
        report.text = @"Could not download file - please check the URL and make sure you have a network connection";
        
    } else {
        // verify
        NSError *parseError = [self performSelector:(_verifySelector) withObject:data];
        
        if (parseError) {
            NSLog(@"%@", [NSString stringWithFormat:@"Error: %@", [parseError localizedDescription]]);
            report.text = [NSString stringWithFormat:@"Could not download file - please make sure the URL points to a valid %@", _assetType];

        } else {
            
            // save
            NSError *saveError = [CCPersistence saveDownloadedAssetOfType:_assetType
                                                                  fromUrl:url 
                                                                     data:data];
            if (saveError) {
                NSLog(@"%@", [NSString stringWithFormat:@"Error: %@", [saveError localizedDescription]]);
                report.text = @"Could not save file on this device";
            } else {
                report.text = [NSString stringWithFormat:@"%@ downloaded!", _assetType];
            }
        }
    }
    
    [[self viewWithTag:TAG_WAIT] removeFromSuperview];
    [[self viewWithTag:TAG_SPIN] removeFromSuperview];
    
    CCMenuButton *backButton = (CCMenuButton *)[self viewWithTag:TAG_BACK];
    backButton.title = @"<< Back";
}

// -----------------------------------------------------------------
#pragma mark -
#pragma mark verifiers

-(NSError *)verifyLevelPack:(NSData *)data
{
    NSError *parseError = nil;
    [CCDataReader loadLevelListFromData:data error:&parseError];
    return parseError;
}

-(NSError *)verifyTileset:(NSData *)data
{
    // todo create image from data, verify 416x512
    UIImage *image = [UIImage imageWithData:data];
    if (!image) {
        return [NSError errorWithDomain:@"CC" 
                                   code:30
                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"invalid image data", NSLocalizedDescriptionKey, nil]];
    }
//    if (image.size.width != 416 || image.size.height != 512) {
//        NSString *msg = [NSString stringWithFormat:@"invalid image size (%dx%d but must be 416x512)", (int)image.size.width, (int)image.size.height];
//        return [NSError errorWithDomain:@"CC" 
//                                   code:31
//                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:msg, NSLocalizedDescriptionKey, nil]];
//    }
    return nil;
}

-(NSError *)verifyBackground:(NSData *)data
{
    UIImage *image = [UIImage imageWithData:data];
    if (!image) {
        return [NSError errorWithDomain:@"CC" 
                                   code:40
                               userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"invalid image data", NSLocalizedDescriptionKey, nil]];
    }
    return nil;
}

// -----------------------------------------------------------------

-(void)dealloc
{
    [_previousEntryKey release];
    [_assetType release];
    [super dealloc];
}

@end
