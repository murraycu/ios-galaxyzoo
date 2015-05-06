//
//  ViewController.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 01/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "ViewController.h"
#import "Singleton.h"
#import "DecisionTree/DecisionTree.h"
#import "client/ZooniverseClient.h"
#import "ZooniverseModel/ZooniverseSubject.h"
#import <RestKit/RestKit.h>


@interface ViewController () {
    ZooniverseClient *_client;
}

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ViewController

- (void)setup {
    _client = [[ZooniverseClient alloc] init];
}

- (ViewController *)init {
    self = [super init];
    [self setup];
    return self;
}

- (ViewController *)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil
                bundle:nibBundleOrNil];
    [self setup];
    return self;
}

- (ViewController *)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self setup];
    return self;
}

- (IBAction)buttonAction:(id)sender {
    Singleton *singleton = [Singleton sharedSingleton];
    DecisionTree *DecisionTree = [singleton getDecisionTree:@"TODO"];

    //Get more subjects from the server, putting them in CoreData:
    
    [_client querySubjects];
    
    // Get the subjects from CoreData:
    for (id <NSFetchedResultsSectionInfo> sectionInfo in [self.fetchedResultsController sections]) {
        
        for (ZooniverseSubject *subject in [sectionInfo objects]) {
            NSLog(@"debugFromCoreData: subjectId=%@, groupId=%@, locationStandardRemote=%@",
                  subject.subjectId, subject.groupId, subject.locationStandardRemote);
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    // Get the FetchRequest from our data model.
    // We have to copy it so we can set a sort order (sortDescriptors).
    // There doesn't seem to be a way to set the sort order in the data model GUI editor.
    NSFetchRequest *fetchRequest = [[_client.managedObjectModel fetchRequestTemplateForName:@"fetchRequestNotDone"] copy];
 
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"subjectId" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext sectionNameKeyPath:nil cacheName:@"ZooniverseSubject"];
    self.fetchedResultsController.delegate = self;
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    
    NSLog(@"%@",[self.fetchedResultsController fetchedObjects]);
    
    NSAssert(!error, @"Error performing fetch request: %@", error);
    
    return _fetchedResultsController;
}

@end
