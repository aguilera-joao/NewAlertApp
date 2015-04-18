//
//  CustomUtility.h
//  AlertApp
//
//  Created by iosDev on 3/25/15.
//  Copyright (c) 2015 iOSDev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactPerson.h"

@interface CustomUtility : NSObject

+(NSString *)contactDataFileLocation;
+(void)sortContactList:(NSMutableOrderedSet *)list;
+(BOOL)checkHeadPhoneStatus;
@end
