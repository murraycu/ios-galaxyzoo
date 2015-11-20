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

- (IBAction)onButtonClick:(id)sender {
    self.inverted = !self.inverted;
}

+ (NSString *)getImagePath:(ZooniverseSubject *)subject
               forInverted:(BOOL)inverted {
    NSString *partialPath = nil;
    if (inverted) {
        partialPath = subject.locationInverted;
    } else {
        partialPath = subject.locationStandard;
    }

    return [ZooniverseClient fullLocalImagePath:partialPath];
}

- (BOOL) setSubjectWithCheck:(ZooniverseSubject *)subject
                 forInverted:(BOOL)inverted {
    //We take both subject and inverted at the same time,
    //to avoid multiple image loads triggered by each individual change:
    _subject = subject;
    _inverted = inverted;

    return [self showSubjectWithCheck];
}

- (BOOL) showSubjectWithCheck {

    NSString *path = [SubjectViewController getImagePath:self.subject
                            forInverted:self.inverted];
    //TODO: Avoid reloading it if it's already using this path:
    UIImage *image = [UIImage imageWithContentsOfFile:path];

    if (path && !image) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:path]) {
            NSLog(@"showSubjectWithCheck: Local file no longer exists: %@", path, nil);

            //The parent ClassifyViewController will respond to the Core Data deletion,
            //and show a different subject:
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [[appDelegate zooniverseClient] abandonSubject:self.subject
                                          withCoreDataSave:YES];
        }
    }

    [self.imageView setImage:image];

    return (image != nil);
}

- (void)setSubject:(ZooniverseSubject *)subject {
    _subject = subject;

    [self showSubjectWithCheck];
}

- (void)setInverted:(BOOL)inverted {
    _inverted = inverted;

    [self showSubjectWithCheck];
}

@end
