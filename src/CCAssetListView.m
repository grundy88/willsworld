//  Copyright 2010 StadiaJack. All rights reserved.

#import "CCAssetListView.h"
#import "CCPersistedAsset.h"
#import "CCPersistence.h"
#import "CCMenuButton.h"

#define TAG_EDIT_BUTTON 44
#define TAG_TABLE_VIEW 45

/*!
   Author: StadiaJack
   Date: 3/14/10
 */
@implementation CCAssetTableCell

@synthesize mainView;
@synthesize renameView;
@synthesize nameLabel;
@synthesize renameField;
@synthesize renameButton;
@synthesize cancelButton;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
{
    if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
        mainView = [[UIView alloc] initWithFrame:self.frame];
        mainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:mainView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-50, self.frame.size.height-15)];
        nameLabel.backgroundColor = [UIColor clearColor];
        [mainView addSubview:nameLabel];
        [nameLabel release];
        
        renameButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        [renameButton setTitle:@"Rename" forState:UIControlStateNormal];
        renameButton.titleLabel.font = [UIFont systemFontOfSize:10];
        renameButton.frame = CGRectMake(0, 0, 60, 22);
        self.accessoryView = renameButton;
        
        
        renameView = [[UIView alloc] initWithFrame:self.frame];
        renameView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        renameView.backgroundColor = [UIColor yellowColor];
        
        renameField = [[UITextField alloc] initWithFrame:CGRectMake(0, (self.frame.size.height-28)/2, self.frame.size.width-70, 28)];
        renameField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        renameField.borderStyle = UITextBorderStyleRoundedRect;
        renameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        renameField.autocorrectionType = UITextAutocorrectionTypeNo;
        renameField.enablesReturnKeyAutomatically = YES;
        [renameView addSubview:renameField];
        [renameField release];
        
        cancelButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        cancelButton.userInteractionEnabled = YES;
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:10];
        cancelButton.frame = CGRectMake(0, 0, 60, 22);
        
    }
    return self;
}

-(void)setName:(NSString *)name
{
    nameLabel.text = name;
    renameField.placeholder = nameLabel.text;
    renameField.text = nil;
}

-(void)setup:(id)input
{
    CCPersistedAsset *asset = input;
    [self setName:asset.name];
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
        mainView.frame = self.bounds;
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

// ------------------------------------------------------------------
#pragma mark -

@implementation CCAssetListView

-(CCAssetTableCell *)newTableCell:(NSString *)reuseIdentifier
{
    return [[CCAssetTableCell alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 30) reuseIdentifier:reuseIdentifier];
}

-(NSMutableArray *)listData
{
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:2];
    [list addObject:[CCPersistence includedAssetsOfType:_assetType]];
    [list addObject:[CCPersistence downloadedAssetsOfType:_assetType]];
    return list;
}

-(CCPersistedAsset *)assetForIndexPath:(NSIndexPath *)indexPath
{
    return [[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

-(void)didSelectAsset:(CCPersistedAsset *)asset
{
}

-(void)didDeleteAsset:(CCPersistedAsset *)asset
{
}

#pragma mark -

-(id)initWithFrame:(CGRect)frame 
              menu:(CCMenuView *)_menu
         assetType:(NSString *)assetType
downloadButtonText:(NSString *)downloadButtonText
      backSelector:(SEL)backSelector
  downloadSelector:(SEL)downloadSelector
{
    if (self = [super initWithFrame:frame menu:_menu]) {
        _assetType = [assetType copy];
        
        data = [[self listData] retain];

        CCMenuButton *backButton = [[CCMenuButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        backButton.title = @"<< Back";
        backButton.clickTarget = menu;
        backButton.clickSelector = backSelector;
        backButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:backButton];
        [backButton release];
        
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
        
        CCMenuButton *dlButton = [[CCMenuButton alloc] initWithFrame:CGRectMake(0, frame.size.height-30, frame.size.width, 30)];
        dlButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        downloadButton.frame = CGRectMake(0, 0, frame.size.width, 30);
        downloadButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [downloadButton setTitle:downloadButtonText forState:UIControlStateNormal];
        downloadButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [downloadButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [downloadButton addTarget:menu action:downloadSelector forControlEvents:UIControlEventTouchUpInside];
        [dlButton addSubview:downloadButton];
        [self addSubview:dlButton];
        [dlButton release];
        
        if ([[data objectAtIndex:1] count] <= 0) editButton.hidden = YES;
        
        renaming = NO;
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
//        [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return data.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? @"included" : @"downloaded";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[data objectAtIndex:section] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCAssetTableCell *cell = (CCAssetTableCell *)[tableView dequeueReusableCellWithIdentifier:@"cc"];
    if (!cell) {
        cell = [[self newTableCell:@"cc"] autorelease];
        [cell.renameButton addTarget:self action:@selector(rename:) forControlEvents:UIControlEventTouchUpInside];
        [cell.cancelButton addTarget:self action:@selector(cancelRename:) forControlEvents:UIControlEventTouchUpInside];
        cell.renameField.delegate = self;
    }
    
    [cell setup:[[data objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    cell.accessoryView.hidden = (indexPath.section == 0);
    cell.renameButton.tag = indexPath.row;
    cell.cancelButton.tag = indexPath.row;
    cell.renameField.tag = indexPath.row;
    
    return cell;
}

-(void)rename:(id)sender
{
    if (renaming) return;
    renaming = YES;
    UITableView *tableView = (UITableView *)[self viewWithTag:TAG_TABLE_VIEW];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:1];
    CCAssetTableCell *cell = (CCAssetTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell flip];
    [cell.renameField becomeFirstResponder];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

-(void)cancelRename:(id)sender
{
    UITableView *tableView = (UITableView *)[self viewWithTag:TAG_TABLE_VIEW];
    CCAssetTableCell *cell = (CCAssetTableCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[sender tag] inSection:1]];
    tableView.frame = CGRectMake(0, 40, self.bounds.size.width, self.bounds.size.height-90);
    [cell flip];
    renaming = NO;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[textField tag] inSection:1];
    UITableView *tableView = (UITableView *)[self viewWithTag:TAG_TABLE_VIEW];
    CCAssetTableCell *cell = (CCAssetTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    tableView.frame = CGRectMake(0, 40, self.bounds.size.width, self.bounds.size.height-90);
    [cell flip];
    renaming = NO;
    // do the rename
    if (cell.renameField.text.length > 0) {
        cell.nameLabel.text = cell.renameField.text;
        cell.renameField.text = nil;
        cell.renameField.placeholder = cell.nameLabel.text;
        CCPersistedAsset *asset = [self assetForIndexPath:indexPath];
        [CCPersistence renameDownloadedAssetOfType:_assetType 
                                           assetId:asset.assetId
                                                to:cell.nameLabel.text];
    }
    return YES;
}

-(void)keyboardWillShow:(NSNotification *)notification
{
    CGRect r = keyboardFrameForNotification(notification);
    UITableView *tableView = (UITableView *)[self viewWithTag:TAG_TABLE_VIEW];
    tableView.frame = CGRectMake(0, 40, self.bounds.size.width, self.bounds.size.height-r.size.height);
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return renaming ? nil : indexPath;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section > 0;
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCPersistedAsset *asset = [self assetForIndexPath:indexPath];
    [self didSelectAsset:asset];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        CCPersistedAsset *asset = [[self assetForIndexPath:indexPath] retain];
        [[data objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        if ([CCPersistence deleteDownloadedAssetOfType:_assetType assetId:asset.assetId]) {
            [self didDeleteAsset:asset];
        }
        [asset release];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [data release];
    [_assetType release];
    [super dealloc];
}

@end
