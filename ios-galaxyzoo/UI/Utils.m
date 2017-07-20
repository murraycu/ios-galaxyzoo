//
//  Utils.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 12/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "Utils.h"
#import "Config.h"
#import <UIKit/UIKit.h>
@import SafariServices;

@implementation Utils

+ (void)fetchRequestSortByDateTimeRetrieved:(NSFetchRequest *)fetchRequest {
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"datetimeRetrieved" ascending:YES]];
}

+ (void)fetchRequestSortByDoneAndDateTimeRetrieved:(NSFetchRequest *)fetchRequest {
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"uploaded" ascending:NO],
                                     [NSSortDescriptor sortDescriptorWithKey:@"done" ascending:NO],
                                     [NSSortDescriptor sortDescriptorWithKey:@"datetimeRetrieved" ascending:YES]];
}

+ (void)openUrlInBrowser:(UIViewController *)viewController
                     url:(NSString *)strUrl {
    NSURL *url = [NSURL URLWithString:strUrl];

    SFSafariViewController *sf = [[SFSafariViewController alloc]initWithURL:url
                                                          entersReaderIfAvailable:NO];
    //sf.delegate(self);
    [viewController presentViewController:sf animated:NO completion:nil];

    /*
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"openUrlInBrowser: Failed to open url: %@", url.description);
    }
    */
}

+ (void)openDiscussionPage:(UIViewController *)viewController
              zooniverseId:(NSString *)zooniverseId {
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",
                        [Config talkUri],
                        zooniverseId];
    [Utils openUrlInBrowser:viewController
                        url:strUrl];
}

+ (NSString *)filenameForIconName:(NSString *)iconName {
    return [NSString stringWithFormat:@"icon_%@", iconName, nil];
}

+ (void)showErrorDialog:(UIViewController *)viewController
                  title:(NSString *)title
                message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *button = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"A title for a dialog button.")
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
    [alert addAction:button];
    [viewController presentViewController:alert
                                 animated:YES
                               completion:nil];
}

@end
