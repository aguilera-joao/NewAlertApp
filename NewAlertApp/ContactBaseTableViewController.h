//
//  ContactBaseTableViewController.h
//  AlertApp
//
//  Created by iosDev on 3/30/15.
//  Copyright (c) 2015 iOSDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactPerson.h"
#import "ContactTableViewCell.h"

extern NSString *const kCellIdentifier;

@interface ContactBaseTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *data;

-(void)configureCell:(ContactTableViewCell *)cell forContactPerson:(ContactPerson *)person;



@end
