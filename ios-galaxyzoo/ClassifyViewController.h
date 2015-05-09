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

@interface ClassifyViewController : UIViewController <NSFetchedResultsControllerDelegate, ClassifyViewControllerDelegate>


- (ClassifyViewController *)init;
- (ClassifyViewController *)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (ClassifyViewController *)initWithCoder:(NSCoder *)aDecoder;

- (void)onClassificationFinished;

@end

