//
//  TKContactsMultiPickerController.m
//  TKContactsMultiPicker
//
//  Created by Jongtae Ahn on 12. 8. 31..
//  Copyright (c) 2012년 TABKO Inc. All rights reserved.
//

#import "TKContactsMultiPickerController.h"
#import "NSString+TKUtilities.h"
#import "UIImage+TKUtilities.h"

@interface TKContactsMultiPickerController(PrivateMethod)

- (IBAction)saveAction:(id)sender;
- (IBAction)dismissAction:(id)sender;

@end

@implementation TKContactsMultiPickerController
@synthesize tableView = _tableView;
@synthesize delegate = _delegate;
@synthesize savedSearchTerm = _savedSearchTerm;
@synthesize savedScopeButtonIndex = _savedScopeButtonIndex;
@synthesize searchWasActive = _searchWasActive;
@synthesize searchBar = _searchBar;

#pragma mark -
#pragma mark Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _selectedCount = 0;
        _listContent = [NSMutableArray new];
        _filteredListContent = [NSMutableArray new];
    }
    return self;
}

#pragma mark - 返回
-(void)leftButtItemClick{
    [self.navigationController popViewControllerAnimated:YES];
}
BOOL is_allow_address;//是否允许
#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    [self.navigationItem setTitle:@"个人通讯录"];
//    [self.navigationItem setLeftBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissAction:)] autorelease]];
//    [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction:)] autorelease]];
//    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    //隐藏系统的item
    [self.navigationItem setHidesBackButton:YES];
    
    _leftButt=[UIButton buttonWithType:UIButtonTypeCustom];
    _leftButt.frame=CGRectMake(10, (44-29)/2, 53, 29);
    [_leftButt setBackgroundImage:[UIImage imageNamed:@"nv_back.png"] forState:UIControlStateNormal];
    [_leftButt setBackgroundImage:[UIImage imageNamed:@"nv_back-pre.png"] forState:UIControlStateHighlighted];
    [_leftButt setTitle:@"  通讯录" forState:UIControlStateNormal];
    _leftButt.titleLabel.font=[UIFont systemFontOfSize:14];
    _leftButt.imageEdgeInsets=UIEdgeInsetsMake(0, -10, 0, 0);
    [_leftButt addTarget:self action:@selector(leftButtItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    if (self.savedSearchTerm)
	{
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setText:_savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
	
	self.searchDisplayController.searchResultsTableView.scrollEnabled = YES;
	self.searchDisplayController.searchBar.showsCancelButton = NO;
    
    // Create addressbook data model
    NSMutableArray *addressBookTemp = [NSMutableArray array];
    
    
    ABAddressBookRef addressBooks = nil;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
        
    {
        addressBooks =  ABAddressBookCreateWithOptions(NULL, NULL);
        
        //获取通讯录权限
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBooks, ^(bool granted, CFErrorRef error){dispatch_semaphore_signal(sema);});
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
        dispatch_release(sema);
        
    }
    
    else
        
    {
        addressBooks = ABAddressBookCreate();
        
    }

    ABAuthorizationStatus status=ABAddressBookGetAuthorizationStatus();
    
    if (status==kABAuthorizationStatusDenied) {
        //用户拒绝了
        
        is_allow_address=NO;
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"要启用通讯录,请先进入手机的\n\"设置->隐私->通讯录\"打开授权" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }else{
        is_allow_address=YES;
    }
    
//    ABAddressBookRef addressBooks = ABAddressBookCreate();
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBooks);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBooks);
    
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.labelText = @"数据加载中...";
    [HUD showAnimated:YES whileExecutingBlock:^{
        
        for (NSInteger i = 0; i < nPeople; i++)
        {
            TKAddressBook *addressBook = [[TKAddressBook alloc] init];
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            CFStringRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
            CFStringRef abLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
            CFStringRef abFullName = ABRecordCopyCompositeName(person);
            
            /*
             Save thumbnail image - performance decreasing
             UIImage *personImage = nil;
             if (person != nil && ABPersonHasImageData(person)) {
             if ( &ABPersonCopyImageDataWithFormat != nil ) {
             // iOS >= 4.1
             CFDataRef contactThumbnailData = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
             personImage = [[UIImage imageWithData:(NSData*)contactThumbnailData] thumbnailImage:CGSizeMake(44, 44)];
             CFRelease(contactThumbnailData);
             CFDataRef contactImageData = ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize);
             CFRelease(contactImageData);
             
             } else {
             // iOS < 4.1
             CFDataRef contactImageData = ABPersonCopyImageData(person);
             personImage = [[UIImage imageWithData:(NSData*)contactImageData] thumbnailImage:CGSizeMake(44, 44)];
             CFRelease(contactImageData);
             }
             }
             [addressBook setThumbnail:personImage];
             */
            
            NSString *nameString = (NSString *)abName;
            NSString *lastNameString = (NSString *)abLastName;
            
            if ((id)abFullName != nil) {
                nameString = (NSString *)abFullName;
            } else {
                if ((id)abLastName != nil)
                {
                    nameString = [NSString stringWithFormat:@"%@ %@", nameString, lastNameString];
                }
            }
            
            addressBook.name = nameString;
            addressBook.recordID = (int)ABRecordGetRecordID(person);;
            addressBook.rowSelected = NO;
            
            ABPropertyID multiProperties[] = {
                kABPersonPhoneProperty,
                kABPersonEmailProperty
            };
            NSInteger multiPropertiesTotal = sizeof(multiProperties) / sizeof(ABPropertyID);
            for (NSInteger j = 0; j < multiPropertiesTotal; j++) {
                ABPropertyID property = multiProperties[j];
                ABMultiValueRef valuesRef = ABRecordCopyValue(person, property);
                NSInteger valuesCount = 0;
                if (valuesRef != nil) valuesCount = ABMultiValueGetCount(valuesRef);
                
                if (valuesCount == 0) {
                    CFRelease(valuesRef);
                    continue;
                }
                
                for (NSInteger k = 0; k < valuesCount; k++) {
                    CFStringRef value = ABMultiValueCopyValueAtIndex(valuesRef, k);
                    switch (j) {
                        case 0: {// Phone number
                            
                            addressBook.tel = [(NSString*)value telephoneWithReformat];
                            if (addressBook.name==nil && ((NSObject *)addressBook.name) != [NSNull null]) {
                                addressBook.name=addressBook.tel;
                            }
                            break;
                        }
                        case 1: {// Email
                            addressBook.email = (NSString*)value;
                            if (addressBook.name==nil && ((NSObject *)addressBook.name) != [NSNull null]) {
                                addressBook.name=addressBook.email;
                            }
                            break;
                        }
                    }
                    CFRelease(value);
                }
                CFRelease(valuesRef);
            }
            
            if (addressBook.name==nil && ((NSObject *)addressBook.name) != [NSNull null]) {
                /**
                 *  如果名字还是为空，赋一个空值
                 */
                addressBook.name=@"没有名称";
            }
            
            [addressBookTemp addObject:addressBook];
            [addressBook release];
            
            if (abName) CFRelease(abName);
            if (abLastName) CFRelease(abLastName);
            if (abFullName) CFRelease(abFullName);
        }
        
        CFRelease(allPeople);
        CFRelease(addressBooks);
        
        // Sort data
        UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
        for (TKAddressBook *addressBook in addressBookTemp) {
            NSInteger sect = [theCollation sectionForObject:addressBook
                                    collationStringSelector:@selector(name)];
            addressBook.sectionNumber = sect;
        }
        
        NSInteger highSection = [[theCollation sectionTitles] count];
        NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:highSection];
        for (int i=0; i<=highSection; i++) {
            NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
            [sectionArrays addObject:sectionArray];
        }
        
        for (TKAddressBook *addressBook in addressBookTemp) {
            [(NSMutableArray *)[sectionArrays objectAtIndex:addressBook.sectionNumber] addObject:addressBook];
        }
        
        for (NSMutableArray *sectionArray in sectionArrays) {
            
            
            NSArray *sortedSection = [theCollation sortedArrayFromArray:sectionArray collationStringSelector:@selector(name)];
            [_listContent addObject:sortedSection];
        }
        
    } completionBlock:^{
        [self.tableView reloadData];
        [HUD removeFromSuperview];
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController.navigationBar addSubview:_leftButt];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [_leftButt removeFromSuperview];
}
-(void)viewDidUnload{
    [super viewDidUnload];
    _leftButt=nil;
}
#pragma mark - 屏幕旋转方向
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark -
#pragma mark UITableViewDataSource & UITableViewDelegate

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:
                [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    } else {
        if (title == UITableViewIndexSearch) {
            [tableView scrollRectToVisible:self.searchDisplayController.searchBar.frame animated:NO];
            return -1;
        } else {
            return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index-1];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
	} else {
        if (is_allow_address==NO) {
            return 0;
        }
        return [_listContent count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else {
        if (is_allow_address==NO) {
            return 0;
        }
        return [[_listContent objectAtIndex:section] count] ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return 0;
    if (is_allow_address==NO) {
        return 0;
    }
    return [[_listContent objectAtIndex:section] count] ? tableView.sectionHeaderHeight : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_filteredListContent count];
    } else {
        if (is_allow_address==NO) {
            return 0;
        }
        return [[_listContent objectAtIndex:section] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCustomCellID = @"QBPeoplePickerControllerCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCustomCellID];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCustomCellID] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
	
	TKAddressBook *addressBook = nil;
	if (tableView == self.searchDisplayController.searchResultsTableView){
        addressBook = (TKAddressBook *)[_filteredListContent objectAtIndex:indexPath.row];
    }else{
        if (is_allow_address==NO) {
            return cell;
        }else{
            addressBook = (TKAddressBook *)[[_listContent objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        }
    }
    if (_listContent.count!=0) {
        if ([[addressBook.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
            cell.textLabel.text = addressBook.name;
        } else {
            cell.textLabel.font = [UIFont italicSystemFontOfSize:cell.textLabel.font.pointSize];
            cell.textLabel.text = @"No Name";
        }
        
        cell.detailTextLabel.text=addressBook.tel;
    }
    
    
//	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//	[button setFrame:CGRectMake(30.0, 0.0, 28, 28)];
//	[button setBackgroundImage:[UIImage imageNamed:@"uncheckBox.png"] forState:UIControlStateNormal];
//    [button setBackgroundImage:[UIImage imageNamed:@"checkBox.png"] forState:UIControlStateSelected];
//	[button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
//    [button setSelected:addressBook.rowSelected];
//    
//	cell.accessoryView = button;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == self.searchDisplayController.searchResultsTableView) {
//		[self tableView:self.searchDisplayController.searchResultsTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
//		[self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:YES];
        _selectAddressBook = (TKAddressBook *)[_filteredListContent objectAtIndex:indexPath.row];
        
        UIActionSheet * actionSheet= [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拨打电话",@"发送短信",nil];
        //        actionSheet.tag=actionSheet_tag;
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
	}
	else {
//		[self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
//		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        
        _selectAddressBook = (TKAddressBook *)[[_listContent objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        UIActionSheet * actionSheet= [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拨打电话",@"发送短信",nil];
//        actionSheet.tag=actionSheet_tag;
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
        
	}
    
//    [self.navigationItem.rightBarButtonItem setEnabled:(_selectedCount > 0)];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	TKAddressBook *addressBook = nil;
    
	if (tableView == self.searchDisplayController.searchResultsTableView)
		addressBook = (TKAddressBook*)[_filteredListContent objectAtIndex:indexPath.row];
	else
        addressBook = (TKAddressBook*)[[_listContent objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    BOOL checked = !addressBook.rowSelected;
    addressBook.rowSelected = checked;
    
    // Enabled rightButtonItem
    if (checked) _selectedCount++;
    else _selectedCount--;
    [self.navigationItem.rightBarButtonItem setEnabled:(_selectedCount > 0 ? YES : NO)];
    
    UITableViewCell *cell =[self.tableView cellForRowAtIndexPath:indexPath];
    UIButton *button = (UIButton *)cell.accessoryView;
    [button setSelected:checked];
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

- (void)checkButtonTapped:(id)sender event:(id)event
{
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
	
	if (indexPath != nil)
	{
		[self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
	}
}

#pragma mark -
#pragma mark Save action

- (IBAction)saveAction:(id)sender
{
	NSMutableArray *objects = [NSMutableArray new];
    for (NSArray *section in _listContent) {
        for (TKAddressBook *addressBook in section)
        {
            if (addressBook.rowSelected)
                [objects addObject:addressBook];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(contactsMultiPickerController:didFinishPickingDataWithInfo:)])
        [self.delegate contactsMultiPickerController:self didFinishPickingDataWithInfo:objects];
    
	[objects release];
}

- (IBAction)dismissAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(contactsMultiPickerControllerDidCancel:)])
        [self.delegate contactsMultiPickerControllerDidCancel:self];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar
{
	[self.searchDisplayController.searchBar setShowsCancelButton:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
	[self.searchDisplayController setActive:NO animated:YES];
	[self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
	[self.searchDisplayController setActive:NO animated:YES];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark ContentFiltering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[_filteredListContent removeAllObjects];
    for (NSArray *section in _listContent) {
        for (TKAddressBook *addressBook in section)
        {
            NSComparisonResult result = [addressBook.name compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            if (result == NSOrderedSame)
            {
                [_filteredListContent addObject:addressBook];
            }
        }
    }
}

#pragma mark -
#pragma mark UISearchDisplayControllerDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
    [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
}

#pragma mark - 修改取消按钮
-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    if (IS_IOS_7)
    {
        // 7.0 系统的适配处理。
        controller.searchBar.showsCancelButton = YES;
        UIButton *cancelButton;
        UIView *topView = controller.searchBar.subviews[0];
        for (UIView *subView in topView.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
                cancelButton = (UIButton*)subView;
            }
        }
        if (cancelButton) {
            [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
            [cancelButton setBackgroundImage:[UIImage imageNamed:@"top_right"] forState:UIControlStateNormal];
            cancelButton.titleLabel.font=[UIFont systemFontOfSize:14];
            [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
    }else{
        controller.searchBar.showsCancelButton = YES;
        for(UIView *subView in controller.searchBar.subviews)
        {
            if([subView isKindOfClass:[UIButton class]])
            {
                [(UIButton*)subView setTitle:@"取消" forState:UIControlStateNormal];
            }
        }
    }
}
#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *tel=_selectAddressBook.tel;
    switch (buttonIndex) {
        case 0:
        {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",tel]]];
            
            break;
        }
        case 1:
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",tel]]];
            break;
        }
        default:
            break;
    }
    
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
	[_filteredListContent release];
    [_listContent release];
    [_tableView release];
    [_searchBar release];
	[super dealloc];
}

@end