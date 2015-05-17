//
//  EMContactSelctViewController.m
//  TableTest
//
//  Created by iosDev on 3/30/15.
//  Copyright (c) 2015 iosDev. All rights reserved.
//

#import "EMContactSelctViewController.h"
#import "EMContactMainViewController.h"
#import "CustomUtility.h"
#import "ContactTableViewCell.h"
#import "ResultsViewController.h"

@interface EMContactSelctViewController () <UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate>  {
    
    BOOL _fileExists;
    NSMutableOrderedSet *_EMList;
    
}

@property (strong, nonatomic) UISearchController *searchController;
@property (nonatomic, strong) ResultsViewController *resultsViewController;

@end



@implementation EMContactSelctViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initSearchBar];
    
    self.title = @"Contacts";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSString *contactData = [CustomUtility contactDataFileLocation];
    
    _fileExists = [[NSFileManager defaultManager] fileExistsAtPath:contactData];
    
    //save data
    if (_fileExists) {
        NSLog(@"File exists");
        _EMList = [NSKeyedUnarchiver unarchiveObjectWithFile:contactData];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    EMContactMainViewController *m = [[EMContactMainViewController alloc]init];
    m.EMList = (NSMutableArray *)[_EMList array];

        
        NSString *docFile = [CustomUtility contactDataFileLocation];
        //save data
        
        [CustomUtility sortContactList:_EMList];
    
       BOOL sucess = [NSKeyedArchiver archiveRootObject:_EMList toFile:docFile];
    
    
       if (sucess) {
            NSLog(@"Was able to save");
        } else {
            NSLog(@"Was NOT able to save data");
        }

  
    
}


void runOnMainQueueWithoutDeadlocking2(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContactTableViewCell *cell = (ContactTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    ContactPerson *person = self.contactList[indexPath.row];
    
    [self configureCell:cell forContactPerson:person];
    
    if ([_EMList containsObject:person]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    ContactTableViewCell *cell =  (ContactTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    BOOL isSelected = (cell.accessoryType == UITableViewCellAccessoryCheckmark);
    
    NSLog(@"Index path is %lu", (long)indexPath.row);
    
    if (!_EMList) { _EMList = [[NSMutableOrderedSet alloc]init]; }
    
       if (isSelected) {
        
        cell.accessoryType = UITableViewCellAccessoryNone;
       
           ContactPerson *person = (tableView == self.tableView) ? [_contactList objectAtIndex:indexPath.row] :
           self.resultsViewController.filteredResults[indexPath.row];
           
        [_EMList removeObject:person];
        
         NSLog(@"removed %@", person);
        
    } else {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        ContactPerson *person = (tableView == self.tableView) ? [_contactList objectAtIndex:indexPath.row] :
        self.resultsViewController.filteredResults[indexPath.row];
        
        [_EMList addObject:person];
        
         NSLog(@"Added %@", person);
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return [self.contactList count];
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
    [self.tableView reloadData];
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    // do something after the search controller is dismissed
}

#pragma mark - UISearchResultsUpdating

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = [_contactList mutableCopy];
    
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


@end
