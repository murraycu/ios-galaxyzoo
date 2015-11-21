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

    UIImage *_imageIconFavoriteSelected;
    UIImage *_imageIconFavoriteUnselected;
    __weak IBOutlet UIBarButtonItem *barButtonItemLogin;
}

@property(nonatomic, strong)ZooniverseSubject *subject;

@property(nonatomic, strong)UIActivityIndicatorView *activityIndicator;

@property(nonatomic)NSUInteger classificationsDoneInSession;
@property (weak, nonatomic) IBOutlet UIView *containerViewSubject;
@property (weak, nonatomic) IBOutlet UIView *containerViewQuestion;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonFavorite;

@end


@implementation ClassifyViewController

- (void) objectChangedNotificationReceived: (NSNotification *) notification
{
    //NSArray* insertedObjects = [[notification userInfo]
    //                            objectForKey:NSInsertedObjectsKey] ;
    NSArray* deletedObjects = notification.userInfo[NSDeletedObjectsKey] ;
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
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    _client = appDelegate.zooniverseClient;

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(objectChangedNotificationReceived:)
                                                 name: NSManagedObjectContextObjectsDidChangeNotification
                                               object: [self managedObjectContext]];

    _imageIconFavoriteSelected = [UIImage imageNamed:@"imageIconFavoriteSelected"];
    _imageIconFavoriteUnselected = [UIImage imageNamed:@"imageIconFavoriteUnselected"];
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

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"favorite"]) {
        [self updateIsFavoriteUI];
    }
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

- (void)showLoginScreen {
    [self performSegueWithIdentifier:@"loginShowEmbed"
                              sender:self];

}

- (void)onBarButtonItemHelp {
    [self performSegueWithIdentifier:@"helpShowEmbed"
                              sender:self];
}

- (IBAction)onButtonRevertClicked:(UIBarButtonItem *)sender {
    [_questionViewController revertClassification];
    _subjectViewController.inverted = false;
}

- (IBAction)onButtonFavoriteClicked:(UIBarButtonItem *)sender {
    _questionViewController.favorite = !(_questionViewController.favorite);
    //observeValueForKeyPath() will respond to the property change and update the toolbar icon.
}

- (IBAction)onButtonLoginClicked:(UIBarButtonItem *)sender {
    if([AppDelegate isLoggedIn]) {
        [AppDelegate clearLogin];
        [self updateIsLoggedInUI];
    } else {
        [self showLoginScreen];
    }
}

- (void)updateIsFavoriteUI {
    if (_questionViewController.favorite) {
        self.buttonFavorite.image = _imageIconFavoriteSelected;
    } else {
        self.buttonFavorite.image = _imageIconFavoriteUnselected;
    }
}

- (void)updateIsLoggedInUI {
    if ([AppDelegate isLoggedIn]) {
        barButtonItemLogin.title = @"Log Out";
    } else {
        barButtonItemLogin.title = @"Log In";
    }
}

- (void)showNextSubject {
    [self setSpinnerVisible:YES];

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
    NSError *error = nil;
    NSArray *results = [[self managedObjectContext]
                        executeFetchRequest:fetchRequest
                        error:&error];
    if (results == nil) {
        NSLog(@"showNextSubject(): executeFetchRequest failed: %@", error);
        [self setSpinnerVisible:NO];
        return;
    }

    NSUInteger count = results.count;

    //We need at least one not-done subject to show anything:
    if (count == 0) {
        BOOL noNetworkBecauseNoWiFi = NO;
        if ([ZooniverseClient networkIsConnected:&noNetworkBecauseNoWiFi]) {
            //TODO: Handle failure:
            [self setSpinnerVisible:NO];

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

    //Offer the login screen after a certain number of anonymous classifications,
    //like the web UI does.
    if(self.classificationsDoneInSession == 3) {
        if(![AppDelegate isLoggedIn]) {
            [self showLoginScreen];
        }
    }

    self.classificationsDoneInSession++;

    self.subject = (ZooniverseSubject *)results[0];

    //Show the subject's image:
    if(![_subjectViewController setSubjectWithCheck:self.subject
                                        forInverted:NO]) {
        //If setSubjectWithCheck failed then it would trigger a new showNextSubject call already.
        [self setSpinnerVisible:NO];
        return;
    }

    //Show the current question for the subject:
    _questionViewController.subject = self.subject;
    [_questionViewController resetQuestionToFirst];

    [self setSpinnerVisible:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self showNextSubject];

    NSMutableArray *arrayItems = [[NSMutableArray alloc] init];

    UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self
             action:@selector(onBarButtonItemHelp)
   forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    [arrayItems addObject:item];

    self.navigationItem.rightBarButtonItems = arrayItems;

    [self addChildViewControllerConstraints:_subjectViewController
                            toContainerView:self.containerViewSubject];
    [self addChildViewControllerConstraints:_questionViewController
                            toContainerView:self.containerViewQuestion];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self updateIsLoggedInUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSManagedObjectModel*)managedObjectModel {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return appDelegate.managedObjectModel;
}

- (NSManagedObjectContext*)managedObjectContext {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return appDelegate.managedObjectContext;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueName = segue.identifier;
    if ([segueName isEqualToString:@"subjectViewEmbed"]) {
        _subjectViewController = segue.destinationViewController;

    } else if ([segueName isEqualToString:@"questionViewEmbed"]) {
        _questionViewController = segue.destinationViewController;

        [self updateIsFavoriteUI];

        // Respond to changes to the child view controller's "favorite" property:
        [_questionViewController addObserver:self forKeyPath:@"favorite" options:0 context:nil];
    } else if ([segueName isEqualToString:@"helpShowEmbed"]) {
        QuestionHelpViewController *viewController = segue.destinationViewController;
        viewController.question = _questionViewController.question;
    }
}

- (void) addChildViewControllerConstraints:(UIViewController *)childController
                           toContainerView:(UIView *)containerView {
    childController.view.frame = containerView.bounds;

    UIView *subView = childController.view;
    UIView *parent = containerView;

    if (subView.superview != parent) {
        NSLog(@"GalaxyZoo: addChildViewControllerConstraints: Cannot set constraints until the subView is in the parent view: parent=%p, subview.superview=%p", parent, subView.superview);
    }

    //add constraints
    subView.translatesAutoresizingMaskIntoConstraints = NO;

    NSLayoutConstraint *width = [NSLayoutConstraint
                                 constraintWithItem:subView
                                 attribute:NSLayoutAttributeWidth
                                 relatedBy:0
                                 toItem:parent
                                 attribute:NSLayoutAttributeWidth
                                 multiplier:1.0
                                 constant:0];
    NSLayoutConstraint *height = [NSLayoutConstraint
                                  constraintWithItem:subView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:0
                                  toItem:parent
                                  attribute:NSLayoutAttributeHeight
                                  multiplier:1.0
                                  constant:0];
    NSLayoutConstraint *top = [NSLayoutConstraint
                               constraintWithItem:subView
                               attribute:NSLayoutAttributeTop
                               relatedBy:NSLayoutRelationEqual
                               toItem:parent
                               attribute:NSLayoutAttributeTop
                               multiplier:1.0f
                               constant:0.f];

    NSLayoutConstraint *leading = [NSLayoutConstraint
                                   constraintWithItem:subView
                                   attribute:NSLayoutAttributeLeading
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:parent
                                   attribute:NSLayoutAttributeLeading
                                   multiplier:1.0f
                                   constant:0.f];
    [parent addConstraint:width];
    [parent addConstraint:height];
    [parent addConstraint:top];
    [parent addConstraint:leading];
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
