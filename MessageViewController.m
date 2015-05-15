//
//  MessageViewController.m
//  AlertApp
//
//  Created by iosDev on 3/25/15.
//  Copyright (c) 2015 iOSDev. All rights reserved.
//

#import "MessageViewController.h"
#import "CustomUtility.h"

@interface MessageViewController () <UITextFieldDelegate>

@property(weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property(weak, nonatomic) IBOutlet UITextField *textfield;
@property(weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _textfield.delegate = self;
    
    BOOL fileExists = [[NSFileManager defaultManager]fileExistsAtPath:[CustomUtility messageFileLocation]];
    
    if (fileExists) {
        
        NSString *message = [NSKeyedUnarchiver unarchiveObjectWithFile:[CustomUtility messageFileLocation]];
        
        _textfield.text = [message copy];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [center addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)handleKeyboardWillShow:(NSNotification *)paramNotification {
    
    NSDictionary *userInfo = paramNotification.userInfo;
    
    
    NSValue *animationDurationObject = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    
    NSValue *keyboardEndRectObject = userInfo[UIKeyboardFrameEndUserInfoKey];
    
    double animationDuration = 0.0f;
    CGRect keyboardEndRect = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
    
    
    [animationDurationObject getValue:&animationDuration];
    [keyboardEndRectObject getValue:&keyboardEndRect];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    keyboardEndRect = [self.view convertRect:keyboardEndRect fromView:window];
    
    CGRect intersectionOfKeyboardRectAndWindowRect= CGRectIntersection(self.view.frame, keyboardEndRect);
    
    [UIView animateWithDuration:animationDuration animations:^{
        
        self.scrollview.contentInset =
        UIEdgeInsetsMake(0.0f,
                         0.0f,
                         intersectionOfKeyboardRectAndWindowRect.size.height,
                         0.0f);
    }];
    
    
}



-(void)handleKeyboardWillHide:(NSNotification *)paramSender {
    
    NSDictionary *userInfo = [paramSender userInfo];
    
    NSValue *animationDurationObject = [userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    double animationDuration = 0.0f;
    
    [animationDurationObject getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration animations:^{
        
        self.scrollview.contentInset = UIEdgeInsetsZero;
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    NSString *messageFile = [CustomUtility messageFileLocation];
    
    NSLog(@"Text data is [%@]", textField.text);
    
    BOOL success = [NSKeyedArchiver archiveRootObject:textField.text toFile:messageFile];
    
    if (success) {
        NSLog(@"Was able to save message");
    } else {
        
        NSLog(@"was able to save message");
    }
    
    return YES;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
