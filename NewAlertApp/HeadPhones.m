//
//  HeadPhones.m
//  AlertApp
//
//  Created by iOSDev on 11/8/14.
//  Copyright (c) 2014 iOSDev. All rights reserved.
//

#import "HeadPhones.h"


@implementation HeadPhones

+(BOOL)isHeadSetPluggedIn {
    
    AVAudioSessionRouteDescription *route = [[AVAudioSession sharedInstance]currentRoute];
    
    //check all rotues and see if headphones are plugged in
    for (AVAudioSessionPortDescription *description in [route outputs]) {
        if ([[description portType] isEqualToString:AVAudioSessionPortHeadphones]) {
            
                      return YES;
        }
    }
    
    NSLog(@"Head Phones are NOT plugged in");
    
    return NO;
}

+(BOOL)checkHeadPhoneStatus {
    

    return [self isHeadSetPluggedIn];
}

+(void)hello{
    
    NSLog(@"Hello world!");
}




@end

