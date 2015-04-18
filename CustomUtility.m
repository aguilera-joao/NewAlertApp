//
//  CustomUtility.m
//  AlertApp
//
//  Created by iosDev on 3/25/15.
//  Copyright (c) 2015 iOSDev. All rights reserved.
//

#import "CustomUtility.h"
#import <AVFoundation/AVFoundation.h>

@implementation CustomUtility

+(NSString *)contactDataFileLocation{
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *contactData = [documentsPath stringByAppendingPathComponent:@"Contact.data"];
    
    NSLog(@"Path is %@", contactData);
    
    return contactData;
}

+(void)sortContactList:(NSMutableOrderedSet *)list {
    
    [list sortUsingComparator:^NSComparisonResult(id per1, id per2) {
        
        ContactPerson *firstPerson = (ContactPerson *)per1;
        ContactPerson *secondPerson = (ContactPerson *)per2;
        
        return [firstPerson.lastName localizedCaseInsensitiveCompare:secondPerson.lastName];
    }];
}

+(BOOL)isHeadSetPluggedIn {
    
    AVAudioSessionRouteDescription *route = [[AVAudioSession sharedInstance]currentRoute];
    
    //check all rotues and see if headphones are plugged in
    for (AVAudioSessionPortDescription *description in [route outputs]) {
        if ([[description portType] isEqualToString:AVAudioSessionPortHeadphones]) {
            
            return YES;
        }
    }
    
    return NO;
}

+(BOOL)checkHeadPhoneStatus {
    
    return [self isHeadSetPluggedIn];
}

@end
