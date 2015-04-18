//
//  ContactPerson.h
//  ModelInt
//
//  Created by iosDev on 3/12/15.
//  Copyright (c) 2015 iosDev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ContactPerson : NSObject <NSCoding>

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableSet *phoneNumber;
@property (nonatomic, strong) UIImageView *contactPicture;

-(instancetype)initWithFirstName:(NSString *)firstName LastName:(NSString *)lastName andPhonNumbers:(NSMutableSet *)phoneNumbers andContactPicture:(UIImageView *)contacPic;
- (NSComparisonResult)compare:(ContactPerson *)otherObject;
-(NSArray *)phoneNumberArray;
@end
