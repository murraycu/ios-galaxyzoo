//
//  ViewController.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 01/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "ClassifyViewController.h"
#import "SubjectViewController.h"
#import "QuestionViewController.h"
#import "QuestionHelpViewController.h"
#import "ListViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "Singleton.h"
#import "../../DecisionTree/DecisionTree.h"
#import "../../client/ZooniverseClient.h"
#import "../../ZooniverseModel/ZooniverseSubject.h"
#import "Utils.h"
#import <RestKit/RestKit.h>

@interface ClassifyViewController () {
    ZooniverseClient *_client;

    QuestionViewController *_questionViewController;
    SubjectViewController *_subjectViewController;
}

@property(nonatomic, strong)ZooniverseSubject *subject;

@property(nonatomic, strong)UIActivityIndicatorView *activityIndicator;

@property(nonatomic)NSUInteger classificationsDoneInSession;

@end


@implementation ClassifyViewController

- (void) objectChangedNotificationReceived: (NSNotification *) notification
{
    //NSArray* insertedObjects = [[notification userInfo]
    //                            objectForKey:NSInsertedObjectsKey] ;
    NSArray* deletedObjects = [[notification userInfo]
                               objectForKey:NSDeletedObjectsKey] ;
    //NSArray* updatedObjects = [[notification userInfo]
    //                           objectForKey:NSUpdatedObjectsKey] ;
    //NSLog(@"insertObjects: %@", [insertedObjects description]);
    //NSLog(@"deletedObjects: %@", [deletedObjects description]);
    //NSLog(@"updatedObjects: %@", [updatedObjects description]);

    for (NSManagedObject *obj in deletedObjects) {
        if ([obj isKindOfClass:[ZooniverseSubject class]]) {
            ZooniverseSubject *subject = (ZooniverseSubject *)obj;
            if (subject == self.subject) {
                //Show another subject instead:
                //This can happen if we abandon a subject, for instance because a cached image
                //no longer exists.
                [self showNextSubject];
                return;
            }
        }
    }
}

- (void)setup {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _client = appDelegate.zooniverseClient;

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(objectChangedNotificationReceived:)
                                                 name: NSManagedObjectContextObjectsDidChangeNotification
                                               object: [self managedObjectContext]];
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

- (void)getOneSubjectAndShow {
    //Show the spinner until we have at least one subject,
    //then try again:
    [self setSpinnerVisible:YES];
    [_client querySubjects:1
              withCallback:^ {
                  [self performSelectorOnMainThread:@selector(showNextSubject)
                                         withObject:nil
                                      waitUntilDone:NO];
              }];
}

- (void)checkForLogin {
    [self performSegueWithIdentifier:@"loginShowEmbed"
                              sender:self];

}

- (void)showNextSubject {
    //Start with the spinner off,
    //and only show it when we know we are doing an async query and waiting or it.
    [self setSpinnerVisible:NO];

    Singleton *singleton = [Singleton sharedSingleton];

    //Get more subjects from the server, putting them in CoreData:

    // Get the subjects from CoreData:

    // Get the FetchRequest from our data model,
    // and use the same sort order as the ListViewController:
    // We have to copy it so we can set a sort order (sortDescriptors).
    // There doesn't seem to be a way to set the sort order in the data model GUI editor.
    NSFetchRequest *fetchRequest = [[self.managedObjectModel fetchRequestTemplateForName:@"fetchRequestNotDone"] copy];
    [Utils fetchRequestSortByDateTimeRetrieved:fetchRequest];
    fetchRequest.fetchLimit = 1;

    //Get more items from the server if necessary:
    NSError *error = nil; //TODO: Check this.
    NSArray *results = [[self managedObjectContext]
                        executeFetchRequest:fetchRequest
                        error:&error];

    NSUInteger count = [results count];

    //We need at least one not-done subject to show anything:
    if (count == 0) {
        BOOL noNetworkBecauseNoWiFi = NO;
        if ([ZooniverseClient networkIsConnected:&noNetworkBecauseNoWiFi]) {
            //TODO: Handle failure:
            [self getOneSubjectAndShow];
            return;
        } else {
            NSString *errorTitle;
            if (noNetworkBecauseNoWiFi) {
                errorTitle = @"No Wi-Fi network connection.";
            } else {
                errorTitle = @"No network connection.";
            }

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorTitle
                                                            message:@"Cannot download new subjects to classify without a network connection."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }

    if(self.classificationsDoneInSession == 1) {
        [self checkForLogin];
    }

    self.classificationsDoneInSession++;

    self.subject = (ZooniverseSubject *)[results objectAtIndex:0];

    //Show the subject's image:
    _subjectViewController.subject = self.subject;
    
    //Show the current question for the subject:
    NSString *groupId = self.subject.groupId;
    DecisionTree *decisionTree = [singleton getDecisionTree:groupId];
    NSString *questionId = decisionTree.firstQuestionId;
    DecisionTreeQuestion *question = [decisionTree getQuestion:questionId];
    _questionViewController.subject = self.subject;
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
    if ([segueName isEqualToString:@"subjectViewEmbed"]) {
        _subjectViewController = [segue destinationViewController];
    } else if ([segueName isEqualToString:@"questionViewEmbed"]) {
        _questionViewController = [segue destinationViewController];
    } else if ([segueName isEqualToString:@"helpShowEmbed"]) {
        QuestionHelpViewController *viewController = [segue destinationViewController];
        viewController.question = _questionViewController.question;
    }
}

- (void)onClassificationFinished {
    [self showNextSubject];
}

- (void)setSpinnerVisible:(BOOL)visible {
    if (visible) {
        if (!self.activityIndicator) {
            self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            self.activityIndicator.center = self.view.center;
            self.activityIndicator.hidesWhenStopped = YES; //Just in case.
            [self.view addSubview:self.activityIndicator];

            _subjectViewController.view.hidden = YES;
            _questionViewController.view.hidden = YES;
        }

        [self.activityIndicator startAnimating];
    } else if (self.activityIndicator) {
        [self.activityIndicator stopAnimating];

        self.activityIndicator = nil;

        _subjectViewController.view.hidden = NO;
        _questionViewController.view.hidden = NO;
    }
}

@end
