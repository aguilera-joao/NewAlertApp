//
//  ContactBaseTableViewController.m
//  AlertApp
//
//  Created by iosDev on 3/30/15.
//  Copyright (c) 2015 iOSDev. All rights reserved.
//

#import "ContactBaseTableViewController.h"
#import "ResultsViewController.h"

@interface ContactBaseTableViewController ()

@end

NSString *const kCellIdentifier = @"ContactCell";
NSString *const kTableCellNibName = @"ContactTableViewCell";



@implementation ContactBaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.tableView registerNib:[UINib
                                 nibWithNibName:kTableCellNibName
                                 bundle:[NSBundle mainBundle]]
                                 forCellReuseIdentifier:kCellIdentifier];
}


-(void)configureCell:(ContactTableViewCell *)cell forContactPerson:(ContactPerson *)person {

 
        
    if (person.firstName != nil && person.lastName != nil) {
        
        cell.nameTextLabel.text = person.name;
    } else if (person.lastName == nil) {
        
        cell.nameTextLabel.text = person.firstName;
    } else if (person.firstName == nil){
        
        cell.nameTextLabel.text = person.lastName;
    } else {
        
        cell.nameTextLabel.text = @"";
    }
    
    // if contact person has a phone number
    if ([person.phoneNumber count] > 0) {
        
        NSArray *arr = [person.phoneNumber allObjects];
        
        cell.phoneNumberTextLabel.text = [arr objectAtIndex:0];
    } else {
        
        cell.phoneNumberTextLabel.text = @"";
    }
    
    //if contact person has contact pic use that
    //else use the default picture in ContactTableViewCell class
    if (person.contactPicture.image) {
        cell.contactPic.image = person.contactPicture.image;
    }

    
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 56;
}




@end
