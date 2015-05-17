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
#import "Utils.h"
#import <RestKit/RestKit.h>

@interface ListViewController () {
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionViewSubjects;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSMutableArray *sectionChanges;
@property (nonatomic, strong) NSMutableArray *itemChanges;

@end

@implementation ListViewController

- (void) setup {
    UINib *cellNib = [UINib nibWithNibName:@"ListCollectionViewCellView" bundle:nil];
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

- (NSFetchedResultsController *)fetchedResultsController {

    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }

    // Get the FetchRequest from our data model.
    // We have to copy it so we can set a sort order (sortDescriptors).
    // There doesn't seem to be a way to set the sort order in the data model GUI editor.
    NSFetchRequest *fetchRequest = [[[self managedObjectModel] fetchRequestTemplateForName:@"fetchRequestSubjects"] copy];

    [Utils fetchRequestSortByDateTimeRetrieved:fetchRequest];

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

#pragma mark - NSFetchedResultsControllerDelegate:

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    self.sectionChanges = [[NSMutableArray alloc] init];
    self.itemChanges = [[NSMutableArray alloc] init];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type {
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    change[@(type)] = @(sectionIndex);
    [self.sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_itemChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView performBatchUpdates:^{
        for (NSDictionary *change in self.sectionChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch(type) {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
                    //TODO?: case NSFetchedResultsChangeUpdate:
                    //TODO?: case NSFetchedResultsChangeMove:
                }
            }];
        }

        for (NSDictionary *change in _itemChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch(type) {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeUpdate:
                        [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeMove:
                        [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                        break;
                }
            }];
        }
    } completion:^(BOOL finished) {
        self.sectionChanges = nil;
        self.itemChanges = nil;
    }];
}

#pragma mark - UICollectionViewDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfSectionsInCollectionView:(NSInteger)section {
    return 1;
}

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
    NSURL *url = [[NSURL alloc] initWithString:subject.locationThumbnailRemote];
    [cell.imageView setImageWithURL:url];

    cell.imageStatusDone.hidden = !subject.done;
    cell.imagestatusUploaded.hidden = !subject.uploaded;
    cell.imageStatusFavorite.hidden = !subject.favorite;

    BOOL complete = subject.locationStandardDownloaded && subject.locationInvertedDownloaded && subject.locationThumbnailDownloaded;
    cell.spinner.hidden = complete;

    return cell;
}

@end
