//
//  HeadPhones.h
//  AlertApp
//
//  Created by iOSDev on 11/8/14.
//  Copyright (c) 2014 iOSDev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface HeadPhones : NSObject

@property (atomic, assign) BOOL isPlugged;


+(BOOL)checkHeadPhoneStatus;

@end
