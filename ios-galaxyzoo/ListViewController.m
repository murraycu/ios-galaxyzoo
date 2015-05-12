//
//  ListViewController.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 11/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "ListViewController.h"
#import "ListCollectionViewCell.h"
#import "AppDelegate.h"
#import "ZooniverseModel/ZooniverseSubject.h"
#import <RestKit/RestKit.h>

@interface ListViewController () {
}
@property (strong, nonatomic) IBOutlet UICollectionView *collectionViewSubjects;


@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ListViewController

- (void) setup {
    UINib *cellNib = [UINib nibWithNibName:@"ListCellView" bundle:nil];
    [self.collectionViewSubjects registerNib:cellNib forCellWithReuseIdentifier:@"subjectCell"];
    //self.collectionViewSubjects.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    //self.collectionViewSubjects.dataSource = self;
    //[self.collectionViewSubjects reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
}

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.collectionViewSubjects.delegate = self;
        self.collectionViewSubjects.dataSource = self;
    }
    return self;
}
*/

- (NSManagedObjectContext*)managedObjectContext {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}

- (NSManagedObjectModel*)managedObjectModel {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectModel;
}

+ (void)fetchRequestSortByDateTimeRetrieved:(NSFetchRequest *)fetchRequest {
    //TODO: Move this to somewhere reusable for ClassifyViewController?
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"datetimeRetrieved" ascending:YES]];
}

- (NSFetchedResultsController *)fetchedResultsController {

    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }

    // Get the FetchRequest from our data model.
    // We have to copy it so we can set a sort order (sortDescriptors).
    // There doesn't seem to be a way to set the sort order in the data model GUI editor.
    NSFetchRequest *fetchRequest = [[[self managedObjectModel] fetchRequestTemplateForName:@"fetchRequestSubjects"] copy];

    [ListViewController fetchRequestSortByDateTimeRetrieved:fetchRequest];

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[self managedObjectContext]
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    self.fetchedResultsController.delegate = self;

    NSError *error; //TODO: Check this.
    [self.fetchedResultsController performFetch:&error];

    NSLog(@"%@", [self.fetchedResultsController fetchedObjects]);

    NSAssert(!error, @"Error performing fetch request: %@", error);

    return _fetchedResultsController;
}

#pragma mark - UICollectionView

/*
 - (NSInteger)numberOfSectionsForItems:(NSInteger)itemsCount
 forItemsPerSection:(NSInteger)itemsPerSection {
 return (itemsCount + itemsPerSection + 1) / itemsPerSection;
 }
 */

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];

    return [sectionInfo numberOfObjects];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"subjectCell";

    UICollectionViewCell *cellBase = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    ListCollectionViewCell *cell = (ListCollectionViewCell *)cellBase;

    NSManagedObject *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    ZooniverseSubject *subject = (ZooniverseSubject *)record; //TODO: Check the cast.

    // Update Cell
    NSURL *url = [[NSURL alloc] initWithString:subject.locationStandardRemote];
    [cell.imageView setImageWithURL:url];

    NSString *doneStr = subject.done ? @"Done" : @"Not Done";
    [cell.labelDone setText:doneStr];

    return cell;
}

@end
