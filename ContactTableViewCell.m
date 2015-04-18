//
//  ContactTableViewCell.m
//  AlertApp
//
//  Created by iosDev on 3/25/15.
//  Copyright (c) 2015 iOSDev. All rights reserved.
//

#import "ContactTableViewCell.h"

@implementation ContactTableViewCell

- (void)awakeFromNib {
    
    NSLog(@"Hello from wake up nib");
    // Initialization code
    self.contactPic.layer.cornerRadius = self.contactPic.frame.size.width / 2;
    self.contactPic.layer.borderWidth = 1.5f;
    self.contactPic.layer.borderColor = [UIColor lightTextColor].CGColor;
    self.contactPic.clipsToBounds = YES;
    
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
