//
//  AppDelegate.h
//  AlertApp
//
//  Created by iOSDev on 11/8/14.
//  Copyright (c) 2014 iOSDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>



@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) CLLocationManager *myLocationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLGeocoder *myGeocoder;


-(void)sendEmergencyRequest;

@end

