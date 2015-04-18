//
//  ContactPerson.m
//  ModelInt
//
//  Created by iosDev on 3/12/15.
//  Copyright (c) 2015 iosDev. All rights reserved.
//

#import "ContactPerson.h"

NSString *const kFirstNameKey = @"FirstNameKey";
NSString *const kLastNameKey  = @"LastNameKey";
NSString *const kFullNameKey  = @"FullNameKey";
NSString *const kPhoneNumberKey  = @"PhoneNumberKey";
NSString *const kContactPictureKey = @"ContactPictureKey";
@implementation ContactPerson


-(instancetype)initWithFirstName:(NSString *)firstName LastName:(NSString *)lastName andPhonNumbers:(NSMutableSet *)phoneNumbers andContactPicture:(UIImageView *)contacPic{
    
    if (self = [[ContactPerson alloc]init]) {
        
        self.firstName = firstName;
        self.lastName = lastName;
        self.name = [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
        self.phoneNumber = phoneNumbers;
        self.contactPicture = contacPic;
        
        
        return self;
    }
    
    return nil;
}


-(BOOL)isEqual:(id)object {
    
    if (self == object) {
        return true;
    }
    
    if ([object isKindOfClass:[self class]]) {
        
        ContactPerson *obj = (ContactPerson *)object;
        
        if ([self.name isEqualToString:obj.name] && [self.phoneNumber isEqualToSet:obj.phoneNumber]) {
            
            return true;
        }
    }
    
    return false;
}

-(NSUInteger)hash {
    
    NSUInteger prime = 31;
    NSUInteger result = 1;
    
    NSUInteger var = [self.phoneNumber hash] + [self.name hash];
    
    result = prime  * result + var;
    result = prime  * result + (NSUInteger) (var ^ (var >> 32));
    
    return result % 1000;
}

-(NSComparisonResult)compare:(ContactPerson *)otherObject {
    
    return [self.lastName localizedCaseInsensitiveCompare:otherObject.lastName];
}



-(NSString *)description {
    
    return [NSString stringWithFormat:@"ContactPerson: Name=%@ PhoneNumbers=%@ and contactPicture is %@", self.name, self.phoneNumber, self.contactPicture.image];
}



#pragma mark - NSCoding Protocol methods

-(void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.firstName forKey:kFirstNameKey];
    [aCoder encodeObject:self.lastName forKey:kLastNameKey];
    [aCoder encodeObject:self.name forKey:kFullNameKey];
    [aCoder encodeObject:self.phoneNumber forKey:kPhoneNumberKey];
    [aCoder encodeObject:self.contactPicture forKey:kContactPictureKey];
    
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    if (self != nil) {
       
        _firstName = [aDecoder decodeObjectForKey:kFirstNameKey];
        _lastName  = [aDecoder decodeObjectForKey:kLastNameKey];
        _name      = [aDecoder decodeObjectForKey:kFullNameKey];
      _phoneNumber = [aDecoder decodeObjectForKey:kPhoneNumberKey];
        _contactPicture = [aDecoder decodeObjectForKey:kContactPictureKey];
    }
    
    return self;
}

-(NSArray *)phoneNumberArray {
    
    NSArray *temp = [self.phoneNumber allObjects];
    NSMutableArray *numbers = [[NSMutableArray alloc]init];
    
    NSError *error = [[NSError alloc]init];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\D+" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSString* mobile=@"";
       for (int i=0; i < temp.count; i++) {
           
        mobile = [temp objectAtIndex:i];
     
           NSString *modifiedString = [regex stringByReplacingMatchesInString:mobile options:0 range:NSMakeRange(0, mobile.length) withTemplate:@""];
           
           NSLog(@"modified string is %@", modifiedString);
 
     
           NSNumber *num = [[NSNumber alloc]initWithInteger:[modifiedString integerValue]];
     // NSLog(@"Phone number as NSInteger is %ld", (long)num);
     
           [numbers addObject:num];
           
      //     NSLog(@"Phone number as NSInteger is %ld", (long)num);
     
     }
    
    return [numbers copy];
    

}





@end
