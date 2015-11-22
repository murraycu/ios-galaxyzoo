//
//  ListViewController.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 11/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "ListViewController.h"
#import "ListCollectionViewCell.h"
#import "SubjectViewerViewController.h"
#import "AppDelegate.h"
#import "../../ZooniverseModel/ZooniverseSubject.h"
#import "Utils.h"
#import <RestKit/RestKit.h>

@interface ListViewController () {
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionViewSubjects;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSMutableArray *sectionChanges;
@property (nonatomic, strong) NSMutableArray *itemChanges;

@property (nonatomic, strong) ZooniverseSubject *subjectToShow;

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
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return appDelegate.managedObjectContext;
}

- (NSManagedObjectModel*)managedObjectModel {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
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

    //Make sure that the Done subjects are always at the top,
    //though that should happen anyway, because we should always choose the earliest subjects
    //to classify first.
    [Utils fetchRequestSortByDoneAndDateTimeRetrieved:fetchRequest];

    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[self managedObjectContext]
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    self.fetchedResultsController.delegate = self;

    NSError *error = nil;
    if(![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"fetchedResultsController(): performFetch failed: %@", error);
    }

    //NSLog(@"%@", [self.fetchedResultsController fetchedObjects]);

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
                NSInteger index = [obj unsignedIntegerValue];
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
                switch(type) {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertSections:indexSet];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteSections:indexSet];
                        break;
                    case NSFetchedResultsChangeUpdate:
                        //This might be particularly inefficient, if we get many
                        //updates one after the other.
                        [self.collectionView reloadSections:indexSet];
                        break;
                    //TODO?: case NSFetchedResultsChangeMove:
                }
            }];
        }

        for (NSDictionary *change in _itemChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                NSArray *indexPaths = @[obj];
                switch(type) {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertItemsAtIndexPaths:indexPaths];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteItemsAtIndexPaths:indexPaths];
                        break;
                    case NSFetchedResultsChangeUpdate:
                        [self.collectionView reloadItemsAtIndexPaths:indexPaths];
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
    NSArray *sections = (self.fetchedResultsController).sections;
    id<NSFetchedResultsSectionInfo> sectionInfo = sections[section];

    return sectionInfo.numberOfObjects;
}

-(void)onSubjectButtonClick:(UIView*)clickedButton
{
    ListCollectionViewCellButton *button = (ListCollectionViewCellButton *)clickedButton;

    self.subjectToShow = button.subject;;
    [self performSegueWithIdentifier:@"subjectViewerShow"
                              sender:self];
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

    //Start/Stop the spinner:
    BOOL complete = subject.locationStandardDownloaded && subject.locationInvertedDownloaded && subject.locationThumbnailDownloaded;
    if (complete) {
        [cell.spinner stopAnimating];
    } else {
        [cell.spinner startAnimating];
    }
    cell.spinner.hidden = YES;

    //Let the user click on already-classified subjects to view them:
    if (subject.done) {
        cell.button.hidden = NO;
        cell.button.subject = subject; //So we know which button was clicked.
        [cell.button addTarget:self
                   action:@selector(onSubjectButtonClick:)
         forControlEvents:UIControlEventTouchUpInside];
    } else {
        //Don't let the user click on non-yet-done subjects:
        cell.button.hidden = YES;
    }


    return cell;
}

#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueName = segue.identifier;
    if ([segueName isEqualToString:@"subjectViewerShow"]) {
        SubjectViewerViewController *viewController = segue.destinationViewController;
        viewController.subject = self.subjectToShow;
    }
}


@end
