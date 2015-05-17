//
//  ContactDetailViewController.m
//  AlertApp
//
//  Created by iosDev on 3/31/15.
//  Copyright (c) 2015 iOSDev. All rights reserved.
//

#import "ContactDetailViewController.h"

@interface ContactDetailViewController ()

@end

@implementation ContactDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _contactNameLabel.text = _contact.name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
