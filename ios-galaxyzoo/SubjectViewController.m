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



@interface SubjectViewController()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation SubjectViewController

- (void) setSubject:(ZooniverseSubject *)subject {
    NSURL *urlStandard = [NSURL URLWithString:subject.locationStandardRemote];
    [self.imageView setImageWithURL:urlStandard];
}

@end
