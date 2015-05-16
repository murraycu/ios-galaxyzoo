//
//  SubjectViewController.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 13/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <UIKit/UIKit.h>
//TODO: Why is this extra import necessary - shouldnt UIKit.h get this?
#import "UIImageView+AFNetworking.h"
#import "SubjectViewController.h"
#import "AppDelegate.h"



@interface SubjectViewController()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation SubjectViewController

- (void) setSubject:(ZooniverseSubject *)subject {
    NSString *path = subject.locationStandard;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        NSLog(@"Local file no longer exists: %@", path, nil);

        subject.locationStandard = nil;
        subject.locationStandardDownloaded = NO;

        //Save the subject's changes to disk:
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
        NSError *error = nil;
        [managedObjectContext save:&error];
        //TODO: Check error

    }


    UIImage *image = [UIImage imageWithContentsOfFile:path];
    [self.imageView setImage:image];
}

@end
