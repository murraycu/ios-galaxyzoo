//
//  LoginViewController.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 18/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "LoginViewController.h"
#import "Config.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textfieldUsername;
@property (weak, nonatomic) IBOutlet UITextField *textfieldPassword;
@property (weak, nonatomic) IBOutlet UIButton *buttonForgot;
@property (weak, nonatomic) IBOutlet UIButton *buttonRegister;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onForgotPasswordButton:(id)sender {
    NSURL *url = [NSURL URLWithString:[Config forgotPasswordUri]];

    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
}

- (IBAction)onRegisterButton:(id)sender {
    NSURL *url = [NSURL URLWithString:[Config registerUri]];

    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
    }
}

- (IBAction)onLoginButton:(id)sender {
}

@end
