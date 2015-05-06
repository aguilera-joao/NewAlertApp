//
//  AppDelegate.m
//  AlertApp
//
//  Created by iOSDev on 11/8/14.
//  Copyright (c) 2014 iOSDev. All rights reserved.
//

#import "AppDelegate.h"
#import "HeadPhones.h"
#import "CustomUtility.h"
#import "ContactPerson.h"




#define kuser_id
#define knexmo_password
#define kNexmo_APIKEY @"https://rest.nexmo.com/sms/json?api_key=5fcd25b4&api_secret=2af3d933&from=12342491634&to=13104986862&text=Help+ME+Please"


@interface AppDelegate () {
    
    UIBackgroundTaskIdentifier bgTask;
    BOOL isListening;
    BOOL _fileExists;
    NSMutableArray *numbers;
    
}

@end

@implementation AppDelegate

-(NSString *)createAPIKeyForNumber:(NSString *)num withMessage:(NSString *)msg{
    
    NSString *key = [NSString stringWithFormat:
                     @"https://rest.nexmo.com/sms/json?api_key=5fcd25b4&api_secret=2af3d933&from=45609946244083&to=%@&text=Help+ME+Please", num];
    return key;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSNotificationCenter *alert = [NSNotificationCenter defaultCenter];
    [alert addObserver:self selector:@selector(appIsListening:) name:@"listening" object:nil];
    
    if([CLLocationManager locationServicesEnabled]) {
        
        self.currentLocation = [[CLLocation alloc] init];
        
        self.myLocationManager = [[CLLocationManager alloc] init];

        self.myLocationManager.delegate = self;
    }
 
  //  numbers = [[NSMutableArray alloc]initWithObjects:@"13104986862", @"18054608210", nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSMutableOrderedSet *emergencyContacts = [[NSMutableOrderedSet alloc]init];
    
    _fileExists = [[NSFileManager defaultManager]fileExistsAtPath:[CustomUtility contactDataFileLocation]];
    
    if (_fileExists) {
        emergencyContacts = [NSKeyedUnarchiver unarchiveObjectWithFile:[CustomUtility contactDataFileLocation]];
    } else {
        
        NSLog(@"File exists");
    }
    
   __block NSURL *restURL = [NSURL URLWithString:kNexmo_APIKEY];
    
    NSURLRequest *restquest = [NSURLRequest requestWithURL:restURL];
    
    // NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:restquest delegate:self];
   // NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:restquest delegate:self startImmediately:NO];
    NSOperationQueue *q = [[NSOperationQueue alloc]init];

    
    NSLog(@"Enter background");
    __block BOOL status = YES;
    
    bgTask = [application beginBackgroundTaskWithName:nil expirationHandler:^{
        
        bgTask = UIBackgroundTaskInvalid;
    }];
    
   /* NSOperationQueue *backgroundTask = [[NSOperationQueue alloc]init];
    
    [backgroundTask addOperationWithBlock: ^{
        
        NSLog(@"In Background");
        [HeadPhones checkHeadPhoneStatus];
        
    }];
    */
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
        
        if (isListening == YES) {
            
            status = [HeadPhones checkHeadPhoneStatus];
        
            while (status == YES) {
            
                status = [HeadPhones checkHeadPhoneStatus];
            
                if (status == NO) {
                
                    // [self sendTxt];
                    // [connection start];
                    
                    for (int i = 0; i < [emergencyContacts count]; i++){
                    
                        
                        ContactPerson *person = [emergencyContacts objectAtIndex:i];
                        
                        NSArray *arrNum = [person phoneNumberArray];
                        
                        NSLog(@"Numbers are %@", arrNum);
                        
                        NSNumber *num = [arrNum objectAtIndex:0];
                        
                        NSString *phoneNumberAsString =  [num stringValue];
                        
                        NSLog(@"Phone number is %@", phoneNumberAsString);
                        
                        NSURL *qr = [NSURL URLWithString:[self createAPIKeyForNumber:phoneNumberAsString withMessage:nil]];
                        NSURLRequest *myRequest = [NSURLRequest requestWithURL:qr];
                        
                        NSLog(@"URL is %@", myRequest);
                
                    [NSURLConnection sendAsynchronousRequest:myRequest queue:q completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                        
                        //NSLog(@"Hello asnch");
                        //more code goes here
                        NSLog(@"%@",response.description);
                        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    
                        NSLog(@"%@",jsonObject);
                    }
                 
                 ];
                        //so the nexmo api doesn't complain
                        
                        [NSThread sleepForTimeInterval:7];
                    }
             
                //break out of while loop
                break;
                
                }
                
            
            }
        }
        
    });
    
    BOOL copy = status;
    NSLog(@"bool value is %i", copy);
    
  //  if (!copy){
   //
    //    NSLog(@"inside if statement bool value is %i", copy);
        
//[connection start];
    

    
    


    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    self.currentLocation = [locations lastObject];
    NSLog(@"You are at: %f %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
}


-(void)appIsListening:(NSNotification *)note {
    
    id poster = [note object];
    NSString *name = [note name];
    NSLog(@"Poster: %@",poster);
    NSLog(@"Name: %@",name);
    
    isListening = [poster boolValue];
    NSString *bl =[poster stringValue];
    
    NSLog(@"is device listening? : %i", isListening);
    NSLog(@"Country name: %@", bl);
    
    
}

-(void)sendTxt{
   
    NSString *callString = @"";
    
    NSURL *restURL = [NSURL URLWithString:kNexmo_APIKEY];
    
    NSURLRequest *restquest = [NSURLRequest requestWithURL:restURL];
    
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:restquest delegate:self];

}








@end
