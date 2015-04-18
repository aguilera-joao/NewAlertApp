//
//  ContactTableViewCell.h
//  AlertApp
//
//  Created by iosDev on 3/25/15.
//  Copyright (c) 2015 iOSDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactTableViewCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UIImageView *contactPic;
@property(nonatomic, weak) IBOutlet UILabel *nameTextLabel;
@property(nonatomic, weak) IBOutlet UILabel *phoneNumberTextLabel;

@end
