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
+(NSString *)messageFileLocation;
+(void)sortContactList:(NSMutableOrderedSet *)list;
+(BOOL)checkHeadPhoneStatus;
+(void) displayMessage:(NSString *)paramMessage titleName:(NSString *)title;
@end
