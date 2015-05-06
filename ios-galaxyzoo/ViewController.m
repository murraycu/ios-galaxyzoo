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


@interface ViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ViewController
- (IBAction)buttonAction:(id)sender {
    Singleton *singleton = [Singleton sharedSingleton];
    DecisionTree *DecisionTree = [singleton getDecisionTree:@"TODO"];

    //Get more subjects from the server, putting them in CoreData:
    ZooniverseClient *client = [[ZooniverseClient alloc] init];
    [client querySubjects];
    
    // Get the subjects from CoreData:
    for (id <NSFetchedResultsSectionInfo> sectionInfo in [self.fetchedResultsController sections]) {
        
        for (ZooniverseSubject *subject in [sectionInfo objects]) {
            NSLog(@"debugFromCoreData: subjectId=%@, groupId=%@, locationStandard=%@",
                  subject.subjectId, subject.groupId, subject.locationStandard);
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
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([ZooniverseSubject class])];
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
