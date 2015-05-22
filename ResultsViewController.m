//
//  ResultsViewController.m
//  AlertApp
//
//  Created by iosDev on 3/30/15.
//  Copyright (c) 2015 iOSDev. All rights reserved.
//

#import "ResultsViewController.h"
#import "CustomUtility.h"


@interface ResultsViewController ()

@end

@implementation ResultsViewController

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.filteredResults.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableOrderedSet *contactList = [NSKeyedUnarchiver unarchiveObjectWithFile:[CustomUtility contactDataFileLocation]];
    
    ContactTableViewCell *cell = (ContactTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    ContactPerson *person = self.filteredResults[indexPath.row];
    
    NSLog(@"Contact person is in Results view controller %@", person);
    
    
    if ([contactList containsObject:person]) {
        
        [self configureCell:cell forContactPerson:person includeCheckMark:YES];
    } else {
 
            [self configureCell:cell forContactPerson:person];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView reloadData];
}




@end
