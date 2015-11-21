//
//  ViewController.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 01/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ClassifyViewControllerDelegate.h"

@interface ClassifyViewController : UIViewController <ClassifyViewControllerDelegate>


- (ClassifyViewController *)init NS_DESIGNATED_INITIALIZER;
- (ClassifyViewController *)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (ClassifyViewController *)initWithCoder:(NSCoder *)aDecoder;

- (void)onClassificationFinished;

- (void)showNextSubject;

@end

