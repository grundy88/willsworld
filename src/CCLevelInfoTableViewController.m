//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCLevelInfoTableViewController.h"
#import "CCLevelInfo.h"
#import "CCPersistence.h"

#define TAG_PASSWORD_FIELD 10100

@interface CCLevelInfoTableCell : UITableViewCell {
    UILabel *num;
    UILabel *name;
    UILabel *bestTime;
    UILabel *highScore;
    UILabel *unsuccessfulAttempts;
}
@end

@implementation CCLevelInfoTableCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
{
    if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
        num = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 35, self.frame.size.height-15)];
        num.backgroundColor = [UIColor clearColor];
        num.textAlignment = UITextAlignmentRight;
        [self.contentView addSubview:num];
        [num release];

        name = [[UILabel alloc] initWithFrame:CGRectMake(38, 0, self.frame.size.width-38, self.frame.size.height-15)];
        name.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        name.backgroundColor = [UIColor clearColor];
        name.font = [UIFont boldSystemFontOfSize:16];
        name.adjustsFontSizeToFitWidth = YES;
        name.minimumFontSize = 12;
        [self.contentView addSubview:name];
        [name release];
        
        bestTime = [[UILabel alloc] initWithFrame:CGRectMake(40, self.frame.size.height-10, 70, 10)];
        bestTime.backgroundColor = [UIColor clearColor];
        bestTime.font = [UIFont systemFontOfSize:10];
        [self.contentView addSubview:bestTime];
        [bestTime release];
        
        highScore = [[UILabel alloc] initWithFrame:CGRectMake(120, self.frame.size.height-10, 90, 10)];
        highScore.backgroundColor = [UIColor clearColor];
        highScore.font = [UIFont systemFontOfSize:10];
        [self.contentView addSubview:highScore];
        [highScore release];
        
        unsuccessfulAttempts = [[UILabel alloc] initWithFrame:CGRectMake(40, self.frame.size.height-21, 100, 10)];
        unsuccessfulAttempts.backgroundColor = [UIColor clearColor];
        unsuccessfulAttempts.font = [UIFont systemFontOfSize:10];
        [self.contentView addSubview:unsuccessfulAttempts];
        [unsuccessfulAttempts release];
        
        
//        self.contentView.backgroundColor = [UIColor clearColor];
//        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
//        v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        v.backgroundColor = [UIColor clearColor];
////        [self addSubview:v];
//        self.backgroundView = v;
//        [v release];
    }
    return self;
}

-(void)setup:(CCLevelInfo *)levelInfo num:(int)levelNum
{
    num.text = [NSString stringWithFormat:@"%d.", levelNum];
    name.text = levelInfo.title;
    bestTime.text = levelInfo.bestTime > 0 ? [NSString stringWithFormat:@"best time: %d", levelInfo.bestTime] : nil;
    highScore.text = levelInfo.highScore > 0 ? [NSString stringWithFormat:@"high score: %d", levelInfo.highScore] : nil;
    if (levelInfo.unsuccessfulAttempts > 0) {
        if (levelInfo.highScore > 0) {
            unsuccessfulAttempts.text = [NSString stringWithFormat:@"Complete in %d %@", levelInfo.unsuccessfulAttempts, (levelInfo.unsuccessfulAttempts==1)?@"try":@"tries"];
        } else {
            unsuccessfulAttempts.text = [NSString stringWithFormat:@"%d %@ so far...", levelInfo.unsuccessfulAttempts, (levelInfo.unsuccessfulAttempts==1)?@"try":@"tries"];
        }
    } else {
        unsuccessfulAttempts.text = nil;
    }
//    unsuccessfulAttempts.text = levelInfo.unsuccessfulAttempts > 0 ? [NSString stringWithFormat:@"# of attempts: %d%@", levelInfo.unsuccessfulAttempts, (levelInfo.highScore<=0)?@"...":@""] : nil;
    if (levelInfo.highScore > 0) {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

@end


/*!
   Author: StadiaJack
   Date: 10/21/09
 */
@implementation CCLevelInfoTableViewController

@synthesize delegate;
@synthesize player;

-(void)loadView
{
    [super loadView];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.8 green:1 blue:0.8 alpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

-(void)promptForPassword:(int)row
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter Password" 
                                                    message:@"\n\n" 
                                                   delegate:self 
                                          cancelButtonTitle:@"Cancel" 
                                          otherButtonTitles:@"OK", nil];

    int w = 100;
    UITextField *passwordField = [[UITextField alloc] initWithFrame:CGRectMake((alert.bounds.size.width-w)/2,43,w,30)];
    passwordField.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    passwordField.font = [UIFont systemFontOfSize:18];
    passwordField.borderStyle = UITextBorderStyleBezel;
    passwordField.backgroundColor = [UIColor whiteColor];
    passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;
    passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordField.tag = TAG_PASSWORD_FIELD;
    [passwordField becomeFirstResponder];
    [alert addSubview:passwordField];
    [passwordField release];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 3.2) {
        [alert setTransform:CGAffineTransformMakeTranslation(0, 109)];
    }
    alert.tag = row;

    [alert show];
    [alert release];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    UITextField *passwordField = (UITextField *)[alertView viewWithTag:TAG_PASSWORD_FIELD];
    [passwordField resignFirstResponder];
    BOOL deselect = YES;
    if (buttonIndex == 1) {
        if (passwordField.text) {
            CCLevelInfo *levelInfo = [player.currentLevelPack.levelInfos objectAtIndex:alertView.tag];
            if ([levelInfo.password compare:passwordField.text options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                deselect = NO;
                player.currentLevelPack.currentLevelNum = alertView.tag+1;
                [delegate performSelector:@selector(choseLevel:) withObject:self];
            } else {
                NSString *s = [NSString stringWithFormat:@"%@i%s%@", @"w", "n", @"K"];
                if ([s compare:passwordField.text options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                    player.settings.noPasswords = YES;
                    [CCPersistence savePlayerSettings:player];
                    deselect = NO;
                    player.currentLevelPack.currentLevelNum = alertView.tag+1;
                    [delegate performSelector:@selector(choseLevel:) withObject:self];
                }
            }
        }
        if (deselect) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" 
                                                            message:@"" 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
    if (deselect) {
        NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
        if (selection) [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return player.currentLevelPack.numLevels;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCLevelInfoTableCell *cell = (CCLevelInfoTableCell *)[tableView dequeueReusableCellWithIdentifier:@"cc"];
    if (!cell) {
        cell = [[[CCLevelInfoTableCell alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 45) reuseIdentifier:@"cc"] autorelease];
    }
    
    [cell setup:[[player.currentLevelPack levelInfos] objectAtIndex:indexPath.row] num:indexPath.row+1];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // disabling passwords in 1.1
//    CCLevelInfo *levelInfo = [player.currentLevelPack.levelInfos objectAtIndex:indexPath.row];
//    if (levelInfo.bestTime < 0 && !player.settings.noPasswords) {
//        [self promptForPassword:indexPath.row];
//    } else {
        player.currentLevelPack.currentLevelNum = indexPath.row+1;
        [delegate performSelector:@selector(choseLevel:) withObject:self];
//    }
}

-(void)scrollTo:(NSNumber *)num
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[num intValue]-1 inSection:0]
     atScrollPosition:UITableViewScrollPositionTop 
     animated:YES];
}

-(void)dealloc
{
    [player release];
    [super dealloc];
}

@end
