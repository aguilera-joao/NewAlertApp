//
//  ResultsViewController.m
//  AlertApp
//
//  Created by iosDev on 3/30/15.
//  Copyright (c) 2015 iOSDev. All rights reserved.
//

#import "ResultsViewController.h"


@interface ResultsViewController ()

@end

@implementation ResultsViewController

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.filteredResults.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContactTableViewCell *cell = (ContactTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    ContactPerson *person = self.filteredResults[indexPath.row];
    
    NSLog(@"Contact person is in Results view controller %@", person);
    [self configureCell:cell forContactPerson:person];
    
    return cell;
}




@end
