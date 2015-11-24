//
//  LoginViewController.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 18/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "../client/ZooniverseNameValuePair.h"
#import "../client/ZooniverseHttpUtils.h"
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
        NSLog(@"Failed to open url: %@", url.description);
    }
}

- (IBAction)onRegisterButton:(id)sender {
    NSURL *url = [NSURL URLWithString:[Config registerUri]];

    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"Failed to open url: %@", url.description);
    }
}

- (void)parseLoginResponseData:(NSData*)data
{
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:&error];
    if (error) {
        NSLog(@"Error parsing JSON: %@", error.description);
        return;
    }

    BOOL success = [jsonDict[@"success"] boolValue];
    NSString *message = jsonDict[@"message"];
    NSString *name = jsonDict[@"name"];
    NSString *apiKey = jsonDict[@"api_key"];

    if (!success) {
        NSLog(@"Login failed with message:%@", message);

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login Failed", @"An error dialog title.")
                                                        message:NSLocalizedString(@"The server did not accept that username and password.", @"Text for an error dialog.")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"A title for a dialog button.")
                                              otherButtonTitles:nil];
        [alert show];

        return;
    }

    //Store it for later use:
    [AppDelegate setLogin:name
                   apiKey:apiKey];

    [self.navigationController popViewControllerAnimated:YES];
}


+ (void)setNetworkActivityIndicatorVisibleOnMainThread:(BOOL)setVisible {
    //We use dispatch_async instead of performSelectorOnMainThread just because it is simpler:
    dispatch_async(dispatch_get_main_queue(), ^{
        [AppDelegate setNetworkActivityIndicatorVisible:setVisible];
    });
}

- (void)doLogin {

    NSString *postLoginUriStr =
    [NSString stringWithFormat:@"%@login",
     [Config baseUrl], nil];
    NSURL *postLoginUri = [NSURL URLWithString:postLoginUriStr];

    //An array of ZooniverseNameValuePair:
    NSMutableArray *nameValuePairs = [[NSMutableArray alloc] init];

    [ZooniverseHttpUtils addNameValuePairToArray:nameValuePairs
                                  name:@"username"
                                 value:self.textfieldUsername.text];
    [ZooniverseHttpUtils addNameValuePairToArray:nameValuePairs
                                  name:@"password"
                                 value:self.textfieldPassword.text];

    NSString *content = [ZooniverseHttpUtils generateContentForNameValuePairs:nameValuePairs];

    NSMutableURLRequest *request = [ZooniverseHttpUtils createURLRequest:postLoginUri];
    request.HTTPMethod = @"POST";

    //This breaks things, so the server doesn't accept our username and password:
    //[request setValue:@"application/x-www-form-urlencoded charset=utf-8"
    //forHTTPHeaderField:@"Content-Type"];

    [ZooniverseHttpUtils setRequestContent:content
                                forRequest:request];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [LoginViewController setNetworkActivityIndicatorVisibleOnMainThread:YES];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               [LoginViewController setNetworkActivityIndicatorVisibleOnMainThread:NO];

                               //TODO: Should we somehow use a weak reference to Subject?
                               NSHTTPURLResponse *httpResponse;
                               if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                   httpResponse = (NSHTTPURLResponse *)response;
                               }

                               if (httpResponse.statusCode == 200 /* HTTP_OK */) {
                                   [self performSelectorOnMainThread:@selector(parseLoginResponseData:)
                                                          withObject:data
                                                       waitUntilDone:NO];
                               } else {
                                   NSLog(@"debug: unexpected login response: %ld",
                                         (long)httpResponse.statusCode);
                               }
                           }];

}

- (IBAction)onLoginButton:(id)sender {
    [self doLogin];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    [self doLogin];

    return YES;
}

@end
