//
//  ViewController.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 01/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "ClassifyViewController.h"
#import "QuestionViewController.h"
#import "HelpViewController.h"
#import "ListViewController.h"
#import "AppDelegate.h"
#import "Singleton.h"
#import "DecisionTree/DecisionTree.h"
#import "client/ZooniverseClient.h"
#import "ZooniverseModel/ZooniverseSubject.h"
#import "Utils.h"
#import <RestKit/RestKit.h>

static const NSUInteger MIN_CACHED_NOT_DONE = 5;

@interface ClassifyViewController () {
    ZooniverseClient *_client;
    __weak IBOutlet UIImageView *imageView;

    QuestionViewController *_questionViewController;
}

@end

@implementation ClassifyViewController

- (void)setup {
    _client = [[ZooniverseClient alloc] init];
}

- (ClassifyViewController *)init {
    self = [super init];
    [self setup];
    return self;
}

- (ClassifyViewController *)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil
                bundle:nibBundleOrNil];
    [self setup];
    return self;
}

- (ClassifyViewController *)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}

- (void)showNextSubject {
    Singleton *singleton = [Singleton sharedSingleton];

    //Get more subjects from the server, putting them in CoreData:

    // Get the subjects from CoreData:

    // Get the FetchRequest from our data model,
    // and use the same sort order as the ListViewController:
    // We have to copy it so we can set a sort order (sortDescriptors).
    // There doesn't seem to be a way to set the sort order in the data model GUI editor.
    NSFetchRequest *fetchRequest = [[self.managedObjectModel fetchRequestTemplateForName:@"fetchRequestNotDone"] copy];
    [Utils fetchRequestSortByDateTimeRetrieved:fetchRequest];

    //Get more items from the server if necessary:
    NSError *error = nil; //TODO: Check this.
    NSArray *results = [[self managedObjectContext]
                        executeFetchRequest:fetchRequest
                        error:&error];

    NSUInteger count = [results count];
    if (count < MIN_CACHED_NOT_DONE) {
        [_client querySubjects:(MIN_CACHED_NOT_DONE - count)];
    }

    if (count == 0) {
        //TODO: Wait/Retry/Tell the user.
        NSLog(@"No Subjects Found.");
        return;
    }

    ZooniverseSubject *subject = (ZooniverseSubject *)[results objectAtIndex:0];

    //Show the subject's image:
    NSURL *urlStandard = [NSURL URLWithString:subject.locationStandardRemote];
    [imageView setImageWithURL:urlStandard];

    //Show the current question for the subject:
    NSString *groupId = subject.groupId;
    DecisionTree *decisionTree = [singleton getDecisionTree:groupId];
    NSString *questionId = decisionTree.firstQuestionId;
    DecisionTreeQuestion *question = [decisionTree getQuestion:questionId];
    _questionViewController.subjectId = subject.subjectId; //So it can get the Subject itself.
    _questionViewController.groupId = groupId; //So it can get the DecisionTree itself.
    _questionViewController.question = question;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self showNextSubject];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSManagedObjectModel*)managedObjectModel {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectModel;
}

- (NSManagedObjectContext*)managedObjectContext {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueName = segue.identifier;
    if ([segueName isEqualToString:@"questionViewEmbed"]) {
        _questionViewController = [segue destinationViewController];
    } else if ([segueName isEqualToString:@"helpShowEmbed"]) {
        HelpViewController *viewController = [segue destinationViewController];
        viewController.question = _questionViewController.question;
    }

}

- (void)onClassificationFinished {
    [self showNextSubject];
}

@end
