//
//  ViewController.m
//  AlertApp
//
//  Created by iOSDev on 11/8/14.
//  Copyright (c) 2014 iOSDev. All rights reserved.
//

#import "ViewController.h"
#import "HeadPhones.h"
#import "AppDelegate.h"
#import "CustomUtility.h"


@interface ViewController () {
    
   AppDelegate *appDelegate;
}
@property (weak, nonatomic) IBOutlet UISwitch *switchState;
@property (strong, nonatomic) CLGeocoder *myGeocoder;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSDictionary *info;
@property (strong, nonatomic) NSNotificationCenter *country;


@end

@implementation ViewController

- (void)viewDidLoad {
   
    [super viewDidLoad];

    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    NSLog(@"Authorization status %d", status);
    
    if([CLLocationManager locationServicesEnabled]) {
        
        appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        
        //request permission
        [appDelegate.myLocationManager requestAlwaysAuthorization];
        // [appDelegate.myLocationManager requestWhenInUseAuthorization];
        //[appDelegate.myLocationManager startUpdatingLocation];
    } else if (![CLLocationManager locationServicesEnabled]) {
        
        
        [CustomUtility displayMessage:@"Location Services Disabled. Please activate location services to use the app"
                            titleName:nil];
    }
    
    if (!([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)) {
        
        
        NSLog(@"Permission Denied");
        
        //appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        //request permission
        //[appDelegate.myLocationManager requestAlwaysAuthorization];
     //   [appDelegate.myLocationManager requestWhenInUseAuthorization];
      NSString  *title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView show];

    }
    
    NSLog(@"%@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    
    [self lazyInits];
    
    // NSUserDefaults *boolUserDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL currentState = [[NSUserDefaults standardUserDefaults] boolForKey:@"state"];
    
    NSLog(@"Current state is %i", currentState);
    
  
    [_switchState setOn:currentState];
    
    if (currentState == YES) {
        self.alarmStatus.text = @"Alarm is on";
        self.alarmStatus.textColor = [UIColor greenColor];
        
    } else {
        
        self.alarmStatus.text = @"Alarm is off";
        self.alarmStatus.textColor = [UIColor redColor];
    }
    

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}


/*! Intitlize all lazy inits that will load in viewDidLoad */
-(void)lazyInits {
    
    if (!_myGeocoder) {
        _myGeocoder = [[CLGeocoder alloc]init];
    }
    if (!_location) {
        _location = [[CLLocation alloc]init];
    }
    
    if (!_info) {
        _info = [[NSDictionary alloc]init];
    }
    
    if (!_country) {
        _country = [NSNotificationCenter defaultCenter];
        [_country addObserver:self selector:@selector(residingInCountry:) name:@"country" object:nil];
    }
    
}

-(void)residingInCountry:(NSNotification *)note {
    
    //id poster = [note object];
    //NSString *name = [note name];
   // NSLog(@"Poster (VC): %@", poster);
    
}

-(NSString *)countryInWhichUserResidesIn {

    return nil;
}

-(void)viewDidAppear:(BOOL)animated {
      
    /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        while (true) {

            runOnMainQueueWithoutDeadlocking(^ {
            
                BOOL status = [CustomUtility checkHeadPhoneStatus];
            
                if (status == NO) {
                    _switchState.enabled = NO;
                }  else {
                
                    _switchState.enabled = YES;
                }
        
            });
        }
    
    });
     */
    
    updateInterfaceThatNeedsConstantUpdatingCheckingWithoutDeadLocking(^{
        
        BOOL status = [CustomUtility checkHeadPhoneStatus];
        
        if (status == NO) {
            _switchState.enabled = NO;
        }  else {
            
            _switchState.enabled = YES;
        }
        
    });
    
}

void updateInterfaceThatNeedsConstantUpdatingCheckingWithoutDeadLocking(void (^block)(void)){
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        while (true) {
            
            runOnMainQueueWithoutDeadlocking(^ {
                
                block();
            });
        }
    });
}

void runOnMainQueueWithoutDeadlocking(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)alarm:(UISwitch *)sender {
    
    BOOL isItOn;
    
    if (sender.isOn) {
        NSLog(@"it is on");
        isItOn = YES;
        self.alarmStatus.text = @"Alarm is on";
        
        [appDelegate.myLocationManager startUpdatingLocation];
        self.alarmStatus.textColor = [UIColor greenColor];
        
    } else {
        
        NSLog(@"it is off");
        isItOn = NO;
        [appDelegate.myLocationManager stopUpdatingLocation];
        self.alarmStatus.text = @"Alarm is off";
        self.alarmStatus.textColor = [UIColor redColor];
        //appDelegate.myLocationManager = nil;
        
        [appDelegate.myLocationManager stopUpdatingLocation];
        [appDelegate.myLocationManager stopMonitoringSignificantLocationChanges];
        [appDelegate.myLocationManager stopUpdatingHeading];
    }
    
    NSUserDefaults *boolUserDefaults = [NSUserDefaults standardUserDefaults];
    
    [boolUserDefaults setObject:[NSNumber numberWithBool:isItOn] forKey:@"state"];
    
    NSNumber *num = [[NSNumber alloc]initWithBool:isItOn];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"listening" object:num];
    
    //[nc postNotificationName:@"listening" object:@"US"];
    
}




@end
