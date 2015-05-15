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
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>




#define kuser_id
#define knexmo_password
#define kNexmo_APIKEY @"https://rest.nexmo.com/sms/json?api_key=5fcd25b4&api_secret=2af3d933&from=12342491634&to=13104986862&text=Help+ME+Please"

NSString *numberUS = @"12342491634";
NSString *numberDenmark = @"45609946244083";

@interface AppDelegate () {
    
    UIBackgroundTaskIdentifier bgTask;
    BOOL isListening;
    BOOL _fileExists;
    BOOL _messageFileExists;
    NSMutableArray *numbers;
    NSString *_address;
    NSString *_country;
    NSString *_message;
}

@end

@implementation AppDelegate

-(NSString *)createCustomMessage:(NSString *)message {
    
    NSError *error = [[NSError alloc]init];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s" options:NSRegularExpressionCaseInsensitive error:&error];
    
    
    NSString *modifiedString = [regex stringByReplacingMatchesInString:message options:0 range:NSMakeRange(0, message.length) withTemplate:@"+"];
    
    return modifiedString;
    
}

-(NSString *)createAPIKeyForNumber:(NSString *)num withMessage:(NSString *)msg{
    
    NSString *kNum = nil;
    
    if ([_country isEqualToString:@"United States"]) {
        
        kNum = [NSString stringWithString:numberUS];
    } else {
        
        kNum = [NSString stringWithString:numberDenmark];
    }
    
    NSString *key = [NSString stringWithFormat:
                     @"https://rest.nexmo.com/sms/json?api_key=5fcd25b4&api_secret=2af3d933&from=%@&to=%@&text=%@", kNum, num, msg];
    return key;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Fabric with:@[CrashlyticsKit]];
    
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
    _messageFileExists = [[NSFileManager defaultManager]fileExistsAtPath:[CustomUtility messageFileLocation]];
    
    
    if (_fileExists) {
        emergencyContacts = [NSKeyedUnarchiver unarchiveObjectWithFile:[CustomUtility contactDataFileLocation]];
    } else {
        
        NSLog(@"File exists");
    }
    
    if (_messageFileExists) {
        _message = [NSKeyedUnarchiver unarchiveObjectWithFile:[CustomUtility messageFileLocation]];
        NSLog(@"Was able to load message");
    } else {
        
        _message = @"No message written";
        NSLog(@"No custom message file was found");
    }
    
  // __block NSURL *restURL = [NSURL URLWithString:kNexmo_APIKEY];
    
  //  NSURLRequest *restquest = [NSURLRequest requestWithURL:restURL];
    
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
                        
                       // NSString *currAdd = [self returnMeaningfulAddress];
                        
                        NSLog(@"Phone number is %@", phoneNumberAsString);
                        
                        NSLog(@"Custom is message is [%@]", _message);
                        
                        NSString *customMessage = [NSString stringWithFormat:@"AlertApp: Location:%@ Custom Message:%@", _address, _message];
                        
                        NSURL *qr = [NSURL URLWithString:[self createAPIKeyForNumber:phoneNumberAsString withMessage:[self createCustomMessage:customMessage]]];
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
    NSUserDefaults *boolUserDefaults = [NSUserDefaults standardUserDefaults];
    
    [boolUserDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"state"];

}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    
    if (!_currentLocation) {
        _currentLocation = [[CLLocation alloc]init];
    }
    
    if (!_myGeocoder) {
        _myGeocoder = [[CLGeocoder alloc]init];
    }
    
    
    self.currentLocation = [locations lastObject];
    NSLog(@"You are at: %f %f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    
    
    NSLog(@"My current: %@", _currentLocation);
    
  [self.myGeocoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error){
        
        NSLog(@"Hello block!!!");
        
        
        if (error == nil && placemarks.count > 0) {
            
            CLPlacemark *placemark = placemarks[0];
            
            _address = [[NSString alloc]initWithFormat:@"%@ %@ %@",placemark.name, placemark.locality, placemark.postalCode];
            
            if (!_address) {
                _address = [[NSString alloc]initWithFormat:@"%@ %@ %@",placemark.name, placemark.locality, placemark.postalCode];
                NSLog(@"Address is (inside block) %@", _address);
    
            }
            
            else {
                
                _address = [NSString stringWithFormat:@"%@ %@ %@",placemark.name, placemark.locality, placemark.postalCode];
                NSLog(@"Address is (inside block) %@", _address);
            }
            
            _country = placemark.country;
            NSLog(@"Country is %@", _country);
            
        }  else if (error == nil && placemarks.count == 0){
            NSLog(@"No results were returned.");
        }
        else if (error != nil){
            NSLog(@"An error occurred = %@", error);
        }
        
        NSLog(@"Address is (inside block) %@", _address);
        
    }];

    
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

-(void)sendEmergencyRequest {
    
    NSMutableOrderedSet *emergencyContacts = [[NSMutableOrderedSet alloc]init];
    
    _fileExists = [[NSFileManager defaultManager]fileExistsAtPath:[CustomUtility contactDataFileLocation]];
    
    if (_fileExists) {
        emergencyContacts = [NSKeyedUnarchiver unarchiveObjectWithFile:[CustomUtility contactDataFileLocation]];
    } else {
        
        NSLog(@"File exists");
    }
    
    NSOperationQueue *q = [[NSOperationQueue alloc]init];
    
    for (int i = 0; i < [emergencyContacts count]; i++){
        
        
        ContactPerson *person = [emergencyContacts objectAtIndex:i];
        
        NSArray *arrNum = [person phoneNumberArray];
        
        NSLog(@"Numbers are %@", arrNum);
        
        NSNumber *num = [arrNum objectAtIndex:0];
        
        NSString *phoneNumberAsString =  [num stringValue];
        
        // NSString *currAdd = [self returnMeaningfulAddress];
        
        NSLog(@"Phone number is %@", phoneNumberAsString);
        
        NSLog(@"Custom is message is [%@]", _message);
        
        NSString *customMessage = [NSString stringWithFormat:@"AlertApp: %@ %@", _address, _message];
        
        NSURL *qr = [NSURL URLWithString:[self createAPIKeyForNumber:phoneNumberAsString withMessage:[self createCustomMessage:customMessage]]];
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

    
}

-(NSString *)returnMeaningfulAddress {

   // __block NSString *address = @"";
    
    if (!_currentLocation) {
        _currentLocation = [[CLLocation alloc]init];
    }
    
    if (!_myGeocoder) {
        _myGeocoder = [[CLGeocoder alloc]init];
    }
   
    NSLog(@"My current: %@", _currentLocation);
    
    [self.myGeocoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error){
        
        NSLog(@"Hello block!!!");
        
        
        if (error == nil && placemarks.count > 0) {
            
            CLPlacemark *placemark = placemarks[0];
            
            _address = [[NSString alloc]initWithFormat:@"%@ %@ %@",placemark.name, placemark.locality, placemark.postalCode];
            
            if (!_address) {
                _address = [[NSString alloc]initWithFormat:@"%@ %@ %@",placemark.name, placemark.locality, placemark.postalCode];
                 NSLog(@"Address is (inside block) %@", _address);
            }
            
            else {
                
                _address = [NSString stringWithFormat:@"%@ %@ %@",placemark.name, placemark.locality, placemark.postalCode];
                 NSLog(@"Address is (inside block) %@", _address);
            }
            
           
        }  else if (error == nil && placemarks.count == 0){
            NSLog(@"No results were returned.");
        }
        else if (error != nil){
            NSLog(@"An error occurred = %@", error);
        }
        
          NSLog(@"Address is (inside block) %@", _address);
        
    }];
    
    NSLog(@"Address is %@", _address);
    return _address;
}
@end
