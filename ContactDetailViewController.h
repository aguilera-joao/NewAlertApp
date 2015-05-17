//
//  ContactDetailViewController.h
//  AlertApp
//
//  Created by iosDev on 3/31/15.
//  Copyright (c) 2015 iOSDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactPerson.h"

@interface ContactDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (strong, nonatomic) ContactPerson *contact;

@end
