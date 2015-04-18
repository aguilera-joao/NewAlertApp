//
//  SettingsTableViewController.m
//  AlertApp
//
//  Created by iosDev on 3/20/15.
//  Copyright (c) 2015 iOSDev. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "MessageViewController.h"
#import "EMContactMainViewController.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.e
    self.title = @"Settings";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    //go to message
    if (indexPath.row == 2 && indexPath.section == 0) {
        
        MessageViewController *v = [[MessageViewController alloc]initWithNibName:@"MessageViewController"
                                                                          bundle:[NSBundle mainBundle]];
         [self.navigationController pushViewController:v animated:YES];
       
        //[self.navigationController presentViewController:v animated:YES completion:nil];
    }
    
    
    //go to contacts
    if (indexPath.row == 0 && indexPath.section == 1) {
        
        EMContactMainViewController *emMasterView = [[EMContactMainViewController alloc]init];
        [self.navigationController pushViewController:emMasterView animated:YES];
        
    }
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
