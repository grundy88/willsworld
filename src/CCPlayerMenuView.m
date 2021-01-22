//  Copyright 2009 StadiaJack. All rights reserved.

#import "CCPlayerMenuView.h"
#import "CCController.h"
#import "CCMenuButton.h"
#import "CCPersistence.h"


/*!
   Author: StadiaJack
   Date: 12/13/09
 */

#define TAG_EDIT_BUTTON 44
#define TAG_TABLE_VIEW 45

/*!
 Author: StadiaJack
 Date: 11/23/09
 */

@interface CCPlayerTableCell : UITableViewCell {
    UILabel *name;
    UIView *mainView;
    UIView *renameView;
    UITextField *rename;
    UIButton *renameButton;
    UIButton *cancelButton;
}
@property(nonatomic, readonly) UIView *mainView;
@property(nonatomic, readonly) UIView *renameView;
@property(nonatomic, readonly) UILabel *name;
@property(nonatomic, readonly) UITextField *rename;
@property(nonatomic, readonly) UIButton *renameButton;
@property(nonatomic, readonly) UIButton *cancelButton;
-(void)flip;
@end

@implementation CCPlayerTableCell
@synthesize mainView;
@synthesize renameView;
@synthesize name;
@synthesize rename;
@synthesize renameButton;
@synthesize cancelButton;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
{
    if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
        mainView = [[UIView alloc] initWithFrame:self.frame];
        mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:mainView];
        
        name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-50, self.frame.size.height-15)];
        name.backgroundColor = [UIColor clearColor];
        [mainView addSubview:name];
        [name release];
        
        renameButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        [renameButton setTitle:@"Rename" forState:UIControlStateNormal];
        renameButton.titleLabel.font = [UIFont systemFontOfSize:10];
        renameButton.frame = CGRectMake(0, 0, 60, 22);
        self.accessoryView = renameButton;
        
        
        renameView = [[UIView alloc] initWithFrame:self.frame];
        renameView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        renameView.backgroundColor = [UIColor yellowColor];
        
        rename = [[UITextField alloc] initWithFrame:CGRectMake(0, (self.frame.size.height-28)/2, self.frame.size.width-70, 28)];
        rename.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        rename.borderStyle = UITextBorderStyleRoundedRect;
        rename.autocapitalizationType = UITextAutocapitalizationTypeNone;
        rename.autocorrectionType = UITextAutocorrectionTypeNo;
        rename.enablesReturnKeyAutomatically = YES;
        [renameView addSubview:rename];
        [rename release];
        
        cancelButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        cancelButton.userInteractionEnabled = YES;
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:10];
        cancelButton.frame = CGRectMake(0, 0, 60, 22);
        
    }
    return self;
}

-(void)setup:(NSString *)playerName
{
    name.text = playerName;
    rename.placeholder = name.text;
    rename.text = nil;
}

-(void)flip
{
	[UIView beginAnimations:nil context:NULL];
    //	[UIView setAnimationDuration:0.3];
	[UIView setAnimationTransition:([mainView superview] ? UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
                           forView:self.contentView
                             cache:YES];
	if ([mainView superview]) {
		[mainView removeFromSuperview];
		[self.contentView addSubview:renameView];
        renameView.frame = self.bounds;
        self.accessoryView = cancelButton;
	} else {
		[renameView removeFromSuperview];
		[self.contentView addSubview:mainView];
        self.accessoryView = renameButton;
	}
	
	[UIView commitAnimations];
}

-(void)dealloc
{
    [mainView release];
    [renameView release];
    [renameButton release];
    [cancelButton release];
    [super dealloc];
}

@end



@implementation CCPlayerMenuView

-(id)initWithFrame:(CGRect)frame menu:(CCMenuView *)_menu
{
    if (self = [super initWithFrame:frame menu:_menu]) {
        
        CCMenuButton *backButton = [[CCMenuButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        backButton.title = @"<< Back";
        backButton.clickTarget = menu;
        backButton.clickSelector = @selector(showMainPage);
        backButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:backButton];
        [backButton release];
        
        players = [NSMutableArray new];
        [players addObjectsFromArray:[CCPersistence loadPlayerNames]];
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, self.bounds.size.width, self.bounds.size.height-90) style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tag = TAG_TABLE_VIEW;
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tableView.backgroundColor = [UIColor colorWithRed:0.8 green:1 blue:0.8 alpha:1];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:tableView];
        [tableView release];
        
        CCMenuButton *editButton = [[CCMenuButton alloc] initWithFrame:CGRectMake(frame.size.width-80, 0, 80, 30)];
        editButton.title = @"Edit";
        editButton.clickTarget = self;
        editButton.clickSelector = @selector(toggleEdit:);
        editButton.clickContext = tableView;
        editButton.tag = TAG_EDIT_BUTTON;
        editButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:editButton];
        [editButton release];
        
        CCMenuButton *addButton = [[CCMenuButton alloc] initWithFrame:CGRectMake(0, frame.size.height-30, frame.size.width, 30)];
        addButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        UIButton *addButtonButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        addButtonButton.frame = CGRectMake(0, 0, frame.size.width, 30);
        [addButtonButton setTitle:@"Add Player" forState:UIControlStateNormal];
        addButtonButton.titleLabel.font = [UIFont systemFontOfSize:14];
        addButtonButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [addButtonButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [addButtonButton addTarget:self action:@selector(addPlayer) forControlEvents:UIControlEventTouchUpInside];
        [addButton addSubview:addButtonButton];
        [self addSubview:addButton];
        [addButton release];

        if ([players count] <= 1) editButton.hidden = YES;
        if ([players count] >= 10) addButton.hidden = YES;
        
        renaming = NO;
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return players.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCPlayerTableCell *cell = (CCPlayerTableCell *)[tableView dequeueReusableCellWithIdentifier:@"cc"];
    if (!cell) {
        cell = [[[CCPlayerTableCell alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 45) reuseIdentifier:@"cc"] autorelease];
        [cell.renameButton addTarget:self action:@selector(rename:) forControlEvents:UIControlEventTouchUpInside];
        [cell.cancelButton addTarget:self action:@selector(cancelRename:) forControlEvents:UIControlEventTouchUpInside];
        cell.rename.delegate = self;
    }
    
    [cell setup:[players objectAtIndex:indexPath.row]];
    cell.renameButton.tag = indexPath.row;
    cell.cancelButton.tag = indexPath.row;
    cell.rename.tag = indexPath.row;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *playerName = [players objectAtIndex:indexPath.row];
    [CCPersistence setCurrentPlayer:playerName];
    [menu.controller loadCurrentPlayer];
//    [CCPersistence loadPlayerNamed:playerName];
    [menu.controller backgroundChanged];
    [menu.controller startLevel:YES savePlayer:NO];
//    [menu.controller hideMenu];
}

-(void)rename:(id)sender
{
    if (renaming) return;
    renaming = YES;
    [self viewWithTag:TAG_EDIT_BUTTON].hidden = YES;
    UITableView *tableView = (UITableView *)[self viewWithTag:TAG_TABLE_VIEW];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    CCPlayerTableCell *cell = (CCPlayerTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell flip];
    [cell.rename becomeFirstResponder];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

-(void)cancelRename:(id)sender
{
    UITableView *tableView = (UITableView *)[self viewWithTag:TAG_TABLE_VIEW];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    CCPlayerTableCell *cell = (CCPlayerTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    tableView.frame = CGRectMake(0, 40, self.bounds.size.width, self.bounds.size.height-90);
    if (renaming) {
        [cell flip];
        renaming = NO;
    } else if (adding) {
        [players removeLastObject];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        adding = NO;
    }
    if (players.count > 1) {
        [self viewWithTag:TAG_EDIT_BUTTON].hidden = NO;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[textField tag] inSection:0];
    UITableView *tableView = (UITableView *)[self viewWithTag:TAG_TABLE_VIEW];
    CCPlayerTableCell *cell = (CCPlayerTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSString *newName = cell.rename.text;
    NSString *oldName = cell.name.text;

    // check for duplicates, alert and return NO if found

    [textField resignFirstResponder];
    tableView.frame = CGRectMake(0, 40, self.bounds.size.width, self.bounds.size.height-90);
    [cell flip];

    if (cell.rename.text.length > 0) {
        
        cell.name.text = newName;
        cell.rename.text = nil;
        cell.rename.placeholder = newName;
        
        // do the rename/add
        if (renaming) {
            BOOL current = [menu.controller.currentPlayer.name isEqualToString:oldName];
            renaming = NO;
            [CCPersistence renamePlayerName:oldName to:newName];
            if (current) {
                menu.controller.currentPlayer.name = newName;
            }
        } else if (adding) {
            adding = NO;
            [CCPersistence addPlayerNamed:newName];
        }
    }
    if (players.count > 1) {
        [self viewWithTag:TAG_EDIT_BUTTON].hidden = NO;
    }
    return YES;
}

-(void)keyboardWillShow:(NSNotification *)notification
{
    CGRect r = keyboardFrameForNotification(notification);
    //    NSLog(@"------------- %f %f  %f %f", r.origin.x, r.origin.y, r.size.width, r.size.height);
    UITableView *tableView = (UITableView *)[self viewWithTag:TAG_TABLE_VIEW];
    tableView.frame = CGRectMake(0, 40, self.bounds.size.width, self.bounds.size.height-r.size.height);
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return renaming ? nil : indexPath;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)toggleEdit:(UITableView *)tableView
{
    if (tableView.editing) {
        ((CCMenuButton *)[self viewWithTag:TAG_EDIT_BUTTON]).title = @"Edit";
        [tableView setEditing:NO animated:YES];
    } else {
        ((CCMenuButton *)[self viewWithTag:TAG_EDIT_BUTTON]).title = @"Done";
        [tableView setEditing:YES animated:YES];
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete && players.count > 1) {
        NSString *playerName = [players objectAtIndex:indexPath.row];
        NSString *newCurrentPlayerName = [CCPersistence deletePlayerNamed:playerName];
        [players removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        if (players.count <= 1) {
            [self viewWithTag:TAG_EDIT_BUTTON].hidden = YES;
            tableView.editing = NO;
        }
        if (newCurrentPlayerName) {
//            [CCPersistence loadPlayerNamed:newCurrentPlayerName];
            [menu.controller loadCurrentPlayer];
            [menu.controller backgroundChanged];
            [menu.controller startLevel:YES savePlayer:NO];
        }
    }
}

-(void)addPlayer
{
    [self viewWithTag:TAG_EDIT_BUTTON].hidden = YES;
    adding = YES;
    [players addObject:@""];
    UITableView *tableView = (UITableView *)[self viewWithTag:TAG_TABLE_VIEW];
    [tableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:players.count-1 inSection:0];
    CCPlayerTableCell *cell = (CCPlayerTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.renameButton.tag = indexPath.row;
    cell.cancelButton.tag = indexPath.row;
    cell.rename.tag = indexPath.row;
    [cell flip];
    [cell.rename becomeFirstResponder];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [players release];
    [super dealloc];
}

@end
