//  Copyright 2010 StadiaJack. All rights reserved.

/*!
   Author: StadiaJack
   Date: 7/4/10
 */

@protocol CCAdControllerDelegate;

@interface CCAdController : UIViewController <UIWebViewDelegate> {
    UIWindow *originalKeyWindow;
    NSMutableData *adData;
    NSObject<CCAdControllerDelegate> *adDelegate;
    
    BOOL dismissing;
}

-(void)getLatestAd;
-(BOOL)present:(NSObject<CCAdControllerDelegate> *)delegate;
-(void)dismiss;

@end

@protocol CCAdControllerDelegate
-(void)adDisplayed;
-(void)adDismissed;
@end
