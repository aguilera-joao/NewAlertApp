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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    if([CLLocationManager locationServicesEnabled]) {
        
        appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        
        //request permission
        [appDelegate.myLocationManager requestAlwaysAuthorization];
        [appDelegate.myLocationManager requestWhenInUseAuthorization];
        //[appDelegate.myLocationManager startUpdatingLocation];
    }
    
    NSLog(@"%@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);

}

-(void)viewDidAppear:(BOOL)animated {
      
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
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
       // [appDelegate.myLocationManager startUpdatingLocation];
        
    
        self.alarmStatus.textColor = [UIColor greenColor];
    } else {
        
        NSLog(@"it is off");
        isItOn = NO;
     //   [appDelegate.myLocationManager stopUpdatingLocation];
        self.alarmStatus.text = @"Alarm is off";
        self.alarmStatus.textColor = [UIColor redColor];
    }
    
    NSNumber *num = [[NSNumber alloc]initWithBool:isItOn];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"listening" object:num];
    
}




@end
