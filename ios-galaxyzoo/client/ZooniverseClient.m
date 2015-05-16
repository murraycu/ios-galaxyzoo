//
//  ZooniverseClient.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 01/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "ZooniverseClient.h"
#import "ZooniverseClientImageDownload.h"
#import "ZooniverseClientImageDownloadSet.h"
#import "ZooniverseSubject.h"
#import "ZooniverseClassification.h"
#import "ZooniverseClassificationAnswer.h"
#import "Config.h"
#import "ConfigSubjectGroup.h"
#import "AppDelegate.h"
#import "Utils.h"
#import <RestKit/RestKit.h>

static NSString * BASE_URL = @"https://api.zooniverse.org/projects/galaxy_zoo/";

@interface ZooniverseClient () <NSURLSessionDownloadDelegate> {
    RKObjectManager * _objectManager;

    //Mapping task id (NSString) to ZooniverseClientImageDownloadSet.
    NSMutableDictionary *_dictDownloadTasks;
}

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


//Only used to generate an ID:
@property (nonatomic) NSUInteger sessionCount;

@end

@implementation ZooniverseClient

- (ZooniverseClient *) init;

{
    self = [super init];

    _dictDownloadTasks = [[NSMutableDictionary alloc] init];


    [self setupRestkit];

    return self;
}



- (void)setupRestkit {
    //Some RestKit logging is on (RKLogLevelTrace, I think) by default,
    //which is annoying:
    //However, it still seems to log stuff in debug builds, though apparently not in production builds.
    //
    //RKLogConfigureByName("RestKit", RKLogLevelWarning);
    //RKLogConfigureByName("RestKit/Network*", RKLogLevelWarning);
    //RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelWarning);
    RKLogConfigureByName("*", RKLogLevelOff);


    //let AFNetworking manage the activity indicator
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    // Initialize HTTPClient
    NSURL *baseURL = [NSURL URLWithString:BASE_URL];
    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];

    // Set User-Agent:
    [client setDefaultHeader:@"User-Agent"
                       value:[Config userAgent]];


    //we want to work with JSON-Data
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];

    // Initialize RestKit
    _objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];


    // Connect the RestKit object manager to our Core Data model:

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.managedObjectModel = appDelegate.managedObjectModel;
    self.managedObjectContext = appDelegate.managedObjectContext;
    RKManagedObjectStore *managedObjectStore = appDelegate.rkManagedObjectStore;
    _objectManager.managedObjectStore = managedObjectStore;

    NSDictionary *parentObjectMapping = @{
                                          @"id":   @"subjectId",
                                          @"zooniverse_id":   @"zooniverseId",
                                          @"group_id":     @"groupId",
                                          @"location.standard":   @"locationStandardRemote",
                                          @"location.inverted":   @"locationInvertedRemote",
                                          @"location.thumbnail":   @"locationThumbnailRemote",
                                          };

    RKEntityMapping *subjectMapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass([ZooniverseSubject class])
                                                          inManagedObjectStore:managedObjectStore];
    subjectMapping.identificationAttributes = @[ @"subjectId" ];

    [subjectMapping addAttributeMappingsFromDictionary:parentObjectMapping];

    // Register our mappings with the provider using response descriptors:
    NSDictionary *dict = [Config subjectGroups];
    for (NSString *groupId in dict) {
        //Apparently it's (now) OK to do this extra lookup due to some optimization:
        //See http://stackoverflow.com/a/12454766/1123654
        ConfigSubjectGroup *subjectGroup = [dict objectForKey:groupId];
        if (!subjectGroup.useForNewQueries) {
            continue;
        }

        NSString *path = [self getQueryMoreItemsPathForGroupId:groupId];
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:subjectMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:path
                                                                                           keyPath:nil
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]];
        //TODO: statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)] ?
        [_objectManager addResponseDescriptor:responseDescriptor];
    }


    //Create the SQLite file on disk and create the managed object context:
    [managedObjectStore createPersistentStoreCoordinator];

    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"Zooniverse.sqlite"];

    NSError *error;
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath
                                                                     fromSeedDatabaseAtPath:nil
                                                                          withConfiguration:nil
                                                                                    options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error];

    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);

    [managedObjectStore createManagedObjectContexts];

    // Configure a managed object cache to ensure we do not create duplicate objects
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
}

- (NSString *)getQueryMoreItemsPath {
    return [self getQueryMoreItemsPathForGroupId:[self getGroupIdForNextQuery]];
}

- (NSString *)getQueryMoreItemsPathForGroupId:(NSString *)groupId {
    return [NSString stringWithFormat:@"groups/%@/subjects", groupId];
}

- (NSString *)getGroupIdForNextQuery {
    NSMutableArray *groupIds = [[NSMutableArray alloc] init];
    NSDictionary *dict = [Config subjectGroups];
    for (NSString *groupId in dict) {
        //Apparently it's (now) OK to do this extra lookup due to some optimization:
        //See http://stackoverflow.com/a/12454766/1123654
        ConfigSubjectGroup *subjectGroup = [dict objectForKey:groupId];
        if (subjectGroup.useForNewQueries) {
            [groupIds addObject:groupId];
        }
    }

    NSUInteger idx = arc4random_uniform((u_int32_t)[groupIds count]);
    return [groupIds objectAtIndex:idx];
}

NSString * currentTimeAsIso8601(void)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];

    NSDate *now = [NSDate date];
    NSString *iso8601String = [dateFormatter stringFromDate:now];
    return iso8601String;
}

- (void)onImageDownloaded:(ZooniverseSubject*)subject
        imageLocation:(ImageLocation)imageLocation
                localFile:(NSString*)localFile
{
    switch (imageLocation) {
        case ImageLocationStandard:
            subject.locationStandard = localFile;
            subject.locationStandardDownloaded = YES;
            break;
        case ImageLocationInverted:
            subject.locationInverted = localFile;
            subject.locationInvertedDownloaded = YES;

            break;
        case ImageLocationThumbnail:
            subject.locationThumbnail = localFile;
            subject.locationThumbnailDownloaded = YES;

            break;
        default:
            break;
    }
}

- (NSString *)getTaskIdAsString:(NSURLSessionDownloadTask *)task
{
    NSString *strTaskId = [NSString stringWithFormat:@"%lu", (unsigned long)[task taskIdentifier], nil];
    return strTaskId;
}

- (void)downloadImage:(ZooniverseSubject*)subject
             imageLocation:(ImageLocation)imageLocation
              session:(NSURLSession *)session
                  set:(ZooniverseClientImageDownloadSet *)set
{
    NSString *strUrlRemote = nil;
    switch (imageLocation) {
        case ImageLocationStandard:
            strUrlRemote = subject.locationStandardRemote;
            break;
        case ImageLocationInverted:
            strUrlRemote = subject.locationInvertedRemote;
            break;
        case ImageLocationThumbnail:
            strUrlRemote = subject.locationThumbnailRemote;
            break;
        default:
            break;
    }

    NSURL *urlRemote = [[NSURL alloc] initWithString:strUrlRemote];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlRemote];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request];

    //Store details about the task, so we can get them when it's finished:
    NSString *strTaskId = [self getTaskIdAsString:task];
    [_dictDownloadTasks setObject:set
                           forKey:strTaskId];

    ZooniverseClientImageDownload *download = [[ZooniverseClientImageDownload alloc] init];
    download.subject = subject;
    download.imageLocation = imageLocation;
    [set.dictTasks setObject:download
                      forKey:strTaskId];

    [task resume];
}

- (void)downloadImages:(ZooniverseSubject*)subject
               session:(NSURLSession *)session
                   set:(ZooniverseClientImageDownloadSet *)set
{
    [self downloadImage:subject
          imageLocation:ImageLocationStandard
                session:session
                    set:set];
    [self downloadImage:subject
          imageLocation:ImageLocationInverted
                session:session
                    set:set];
    [self downloadImage:subject
          imageLocation:ImageLocationThumbnail
                session:session
                    set:set];
}

- (void)querySubjects:(NSUInteger)count
         withCallback:(ZooniverseClientQueryDoneBlock)callbackBlock
{
    NSString *countAsStr = [NSString stringWithFormat:@"%i", (unsigned int)count]; //TODO: Is this locale-independent?
    NSString *path = [self getQueryMoreItemsPath];
    NSDictionary *queryParams = @{@"limit" : countAsStr};
    [_objectManager getObjectsAtPath:path
                          parameters:queryParams
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {

                                 NSString *iso8601String = currentTimeAsIso8601();

                                 NSArray* subjects = [mappingResult array];
                                 //NSLog(@"Loaded subjects: %@", subjects);

                                 NSOperationQueue *queue = [[NSOperationQueue alloc] init];
                                 queue.maxConcurrentOperationCount = 3;

                                 // Apparently we need one NSURLSessionConfiguration per NSURLSession,
                                 // instead of creating multiple sessions from one configuration.
                                 // Otherwise we see a runtime warning such as this:
                                 // "
                                 //   A background URLSession with identifier downloadImages already exists!
                                 // "
                                 NSString *strId = [NSString stringWithFormat:@"downloadImages-%lu", (unsigned long)self.sessionCount];
                                 self.sessionCount++;
                                 NSURLSessionConfiguration *configuration =
                                     [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:strId];
                                 NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                                          delegate:self
                                                                     delegateQueue:queue];

                                 //Store the group of tasks, so we can know when they have all completed:
                                 ZooniverseClientImageDownloadSet *set = [[ZooniverseClientImageDownloadSet alloc] init];
                                 set.callbackBlock = callbackBlock;

                                 for (ZooniverseSubject *subject in subjects) {
                                     NSLog(@"  debug: subject zooniverseId: %@", [subject zooniverseId]);

                                     //Remember when we downloaded it, so we can always look at the earliest ones first:
                                     subject.datetimeRetrieved = iso8601String;

                                     [self downloadImages:subject
                                                  session:session
                                                      set:set];
                                 }

                             }
                             failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                 message:[error localizedDescription]
                                                                                delegate:nil
                                                                       cancelButtonTitle:@"OK"
                                                                       otherButtonTitles:nil];
                                 [alert show];
                                 NSLog(@"ZooniverseClient.query_subjects: error: %@", error);

                                 [callbackBlock invoke];
                             }];
}

- (void)uploadClassifications {
    // Get the FetchRequest from our data model,
    // and use the same sort order as the ListViewController:
    // We have to copy it so we can set a sort order (sortDescriptors).
    // There doesn't seem to be a way to set the sort order in the data model GUI editor.
    NSFetchRequest *fetchRequest = [[self.managedObjectModel fetchRequestTemplateForName:@"fetchRequestDoneNotUploaded"] copy];
    [Utils fetchRequestSortByDateTimeRetrieved:fetchRequest];

    //Get more items from the server if necessary:
    NSError *error = nil; //TODO: Check this.
    NSArray *results = [self.managedObjectContext
                        executeFetchRequest:fetchRequest
                        error:&error];
    for (ZooniverseSubject *subject in results) {
        ZooniverseClassification *classification = subject.classification;

        for (ZooniverseClassificationAnswer *answer in classification.answers) {
            //TODO: Actually upload
            NSLog(@"debug: answer: %@", answer.answerId);
        }

        subject.uploaded = YES;

        //Save the ZooniverseClassification and the Subject to disk:
        NSError *error = nil;
        [self.managedObjectContext save:&error];
        //TODO: Check error.
    }


}

- (void)onImageDownloadedAndMoved:(NSArray*)array
{
    NSString *strTaskId = [array objectAtIndex:0];
    NSString *permanentPath = [array objectAtIndex:1];
    NSLog(@"onImageDownloadedAndMoved: %@", permanentPath, nil);

    ZooniverseClientImageDownloadSet *set = [_dictDownloadTasks  objectForKey:strTaskId];
    ZooniverseClientImageDownload *download = [set.dictTasks objectForKey:strTaskId];

    //TODO: Check response and error.
    [self onImageDownloaded:download.subject
              imageLocation:download.imageLocation
                  localFile:permanentPath];

    [set.dictTasks removeObjectForKey:strTaskId];
    [_dictDownloadTasks removeObjectForKey:strTaskId];

    //TODO: Release download object?

    //Call the callbackBlock if this was the last task in the set:
    if (set.dictTasks.count == 0) {
        self.sessionCount++;
        [set.callbackBlock invoke];
    }

}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSURLResponse *response = [downloadTask response];
    //TODO: Check response.
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // Create the directory if necessary:
    NSArray * tempArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [tempArray objectAtIndex:0];
    NSString *appDir = [docsDir stringByAppendingPathComponent:@"/GalaxyZooImages/"]; //TODO
    NSError *error;
    if(![fileManager fileExistsAtPath:appDir])
    {
        [fileManager createDirectoryAtPath:appDir
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:&error];
        //TODO: Check error.
    }

    // Build a local filepath based on the suggestion in the response:
    NSString *suggestedFilename = [response suggestedFilename];
    NSString *permanentPath = [appDir stringByAppendingFormat:@"/%@", suggestedFilename];

    // Delete the file if it already exists:
    if([fileManager fileExistsAtPath:permanentPath])
    {
        NSLog([fileManager removeItemAtPath:appDir error:&error]?@"deleted":@"not deleted");
    }

    // Move the temporary file to the permanent location:
    BOOL fileCopied = [fileManager moveItemAtPath:location.path
                                           toPath:permanentPath
                                            error:&error];
    if (!fileCopied) {
        NSLog(@"Couldn't copy file: %@", location.path, nil);
        return;
    }

    //The didFinishDownloadingToURL documentation tells us to move the file before the end of this function.
    //But let's not risk doing anything else outside of the main thread:
    NSString *strTaskId = [self getTaskIdAsString:downloadTask];
    [self performSelectorOnMainThread:@selector(onImageDownloadedAndMoved:)
                           withObject:@[strTaskId, permanentPath]
                        waitUntilDone:NO];
}

- (void)abandonSubject:(ZooniverseSubject *)subject
{
    NSLog(@"Abandoning subject with subjectId: %@", subject.subjectId, nil);

    //Save the subject's changes to disk:
    [self.managedObjectContext deleteObject:subject];

    NSError *error = nil;
    [self.managedObjectContext save:&error];
    //TODO: Check error
}

@end
