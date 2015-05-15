//
//  EMContactMainViewController.m
//  AlertApp
//
//  Created by iosDev on 3/30/15.
//  Copyright (c) 2015 iOSDev. All rights reserved.
//

#import "EMContactMainViewController.h"
#import "EMContactSelctViewController.h"
#import "CustomUtility.h"
#import <AddressBook/AddressBook.h>
#import "ResultsViewController.h"
#import "ContactDetailViewController.h"


NSString *const kDenied = @"Access to address book is denied";
NSString *const kRestricted = @"Access to address book is restricted";
ABAddressBookRef addressBook;
static NSMutableOrderedSet *_currentSet;

@interface EMContactMainViewController () <UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate> {
    
    NSMutableOrderedSet *_contactSet;
    BOOL _fileExists;
}


@property (strong, nonatomic) UISearchController *searchController;
@property (nonatomic, strong) ResultsViewController *resultsViewController;

@end

@implementation EMContactMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initSearchBar];
    
    self.title = @"Emergency Contacts";
    
    //add button
    UIBarButtonItem *rightAddButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(nextView)];
    self.navigationItem.rightBarButtonItem = rightAddButton;
}


-(void)initSearchBar {
   
    _resultsViewController = [[ResultsViewController alloc]init];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsViewController];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.searchController.searchBar.delegate = self;
    self.resultsViewController.tableView.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.delegate = self;

    self.definesPresentationContext = YES;
}

    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)nextView {
    
     EMContactSelctViewController *emDetailView = [[EMContactSelctViewController alloc]init];
    
    //sort
    [CustomUtility sortContactList:_contactSet];
    
    
    //send data
    NSMutableArray *list = (NSMutableArray *)[_contactSet array];
    emDetailView.contactList = list;
    
    //push view
    [self.navigationController pushViewController:emDetailView animated:YES];
    
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _currentSet.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContactTableViewCell *cell = (ContactTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    if (_fileExists) {
        
        ContactPerson *person = [_currentSet objectAtIndex:indexPath.row];
        [self configureCell:cell forContactPerson:person];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContactPerson *person = (tableView == self.tableView) ? [_EMList objectAtIndex:indexPath.row] :
                                                         self.resultsViewController.filteredResults[indexPath.row];
    
    NSArray *numbers = [person phoneNumberArray];
    
    
    NSLog(@"Phone numbers are %@", numbers);
    
     [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ContactDetailViewController *dv = [[ContactDetailViewController alloc]init];
    
    [self.navigationController pushViewController:dv
                                         animated:YES];
    
    NSLog(@"Person selected is %@", person);
}

#pragma mark - delete cell

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row from the data source
        ContactPerson *p = [_currentSet objectAtIndex:indexPath.row];
        [_currentSet removeObject:p];
        
        //update file
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* contactData = [documentsPath stringByAppendingPathComponent:@"Contact.data"];
        BOOL suc = [NSKeyedArchiver archiveRootObject:_currentSet toFile:contactData];
        
        if (suc) {
            NSLog(@"I was able to save");
        } else {
            NSLog(@"I was not able to save");
        }
        
        //delete from table row
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView
          editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

-(void)setEditing:(BOOL)editing
         animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    
    [self.tableView setEditing:editing animated:animated];
}
#pragma mark - UISearchBarDelgate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
}

#pragma mark - UISearchControllerDelegate

- (void)presentSearchController:(UISearchController *)searchController {
    
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    // do something before the search controller is presented
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    // do something after the search controller is presented
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    // do something before the search controller is dismissed
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    // do something after the search controller is dismissed
}

#pragma mark - UISearchResultsUpdating

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchText = searchController.searchBar.text;
    NSArray *arr = [_currentSet array];
    NSMutableArray *searchResults = [arr mutableCopy];
    
    // strip out all the leading and trailing spaces
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // break up the search terms (separated by spaces)
    NSArray *searchItems = nil;
    if (strippedString.length > 0) {
        searchItems = [strippedString componentsSeparatedByString:@" "];
    }
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
    
    for (NSString *searchString in searchItems) {
        
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"name"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate  *finalPredicate = [NSComparisonPredicate
                                        predicateWithLeftExpression:lhs
                                        rightExpression: rhs
                                        modifier:NSDirectPredicateModifier
                                        type:NSContainsPredicateOperatorType
                                        options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        // at this OR predicate to our master AND predicate
        NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
        
    }
    
    NSCompoundPredicate *finalCompoundPredicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    searchResults = [[searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    
    NSLog(@"Search results are %@", searchResults);
    
    ResultsViewController *tableController = (ResultsViewController *)self.searchController.searchResultsController;
    tableController.filteredResults = searchResults;
    [tableController.tableView reloadData];
    
    
}




#pragma mark - Access Address book

- (void) displayMessage:(NSString *)paramMessage{
    [[[UIAlertView alloc] initWithTitle:nil
                                message:paramMessage
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:NO];
    
    CFErrorRef error = NULL;
    
    switch (ABAddressBookGetAuthorizationStatus()){
        case kABAuthorizationStatusAuthorized:{
            addressBook = ABAddressBookCreateWithOptions(NULL, &error);
            [self readFromAddressBook:addressBook];
            if (addressBook != NULL){
                CFRelease(addressBook);
            }
            break;
        }
        case kABAuthorizationStatusDenied:{
            [self displayMessage:kDenied];
            break;
        }
        case kABAuthorizationStatusNotDetermined:{
            addressBook = ABAddressBookCreateWithOptions(NULL, &error);
            ABAddressBookRequestAccessWithCompletion
            (addressBook, ^(bool granted, CFErrorRef error) {
                if (granted){
                    [self readFromAddressBook:addressBook];
                } else {
                    NSLog(@"Access was not granted");
                }
                if (addressBook != NULL){
                    CFRelease(addressBook);
                }
            });
            break;
        }
        case kABAuthorizationStatusRestricted:{
            [self displayMessage:kRestricted];
            break;
        }
    }
    
    NSLog(@"Hello from Viewwill in master Appear");
    
    if (!_currentSet) { _currentSet = [[NSMutableOrderedSet alloc]init]; }
    if (!_EMList)     { _EMList = [[NSMutableArray alloc]init]; }
    
    //chekc if Contact.data exists
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* contactData = [documentsPath stringByAppendingPathComponent:@"Contact.data"];
    //NSLog(@"Paht is %@", contactData);
    
    _fileExists = [[NSFileManager defaultManager] fileExistsAtPath:contactData];
    
    if (_fileExists) {
        
        _currentSet = [NSKeyedUnarchiver unarchiveObjectWithFile:contactData];
   //     [CustomUtility sortContactList:_currentSet];
        _EMList = (NSMutableArray *)[_currentSet array];
        
        
    }
    
    [self.tableView reloadData];
    
}


- (void) readFromAddressBook:(ABAddressBookRef)paramAddressBook{
    
    NSArray *allPeople = (__bridge_transfer NSArray *)
    ABAddressBookCopyArrayOfAllPeople(paramAddressBook);
    
    
    // ContactPersonSet = [[NSMutableSet alloc]init];
    
    //lazy init
    if (!_contactSet) {
        _contactSet = [[NSMutableOrderedSet alloc]init];
    }
    
    for (id person in allPeople) {
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(( ABRecordRef)CFBridgingRetain(person), kABPersonPhoneProperty);
        ABMultiValueRef firstName    = ABRecordCopyValue((ABRecordRef)CFBridgingRetain(person), kABPersonFirstNameProperty);
        ABMultiValueRef lastName     = ABRecordCopyValue((ABRecordRef)CFBridgingRetain(person), kABPersonLastNameProperty);
        
        //get values
        NSData *contactImageData = (__bridge NSData *)ABPersonCopyImageData((__bridge ABRecordRef)(person));
        NSArray *holdEachPersonMobileNumbers= (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneNumbers);
        
        UIImage *img = [[UIImage alloc]initWithData:contactImageData];
        
        UIImage *compressed = [self compressForUpload:img scale:.2f];
        
        UIImageView *contactPic = [[UIImageView alloc]initWithImage:compressed];
        
        ContactPerson *cp = [[ContactPerson alloc]initWithFirstName:(__bridge NSString *)(firstName) LastName:(__bridge NSString *)(lastName) andPhonNumbers:[NSMutableSet setWithArray:holdEachPersonMobileNumbers] andContactPicture:contactPic];
        
        [_contactSet addObject:cp];
        
//        NSLog(@"%@", cp);
        
    }
    
    
}

- (UIImage *)compressForUpload:(UIImage *)original scale:(CGFloat)scale
{
    // Calculate new size given scale factor.
    CGSize originalSize = original.size;
    CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    
    // Scale the original image to match the new size.
    UIGraphicsBeginImageContext(newSize);
    [original drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return compressedImage;
}


@end
