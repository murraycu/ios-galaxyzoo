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
#import "ZooniverseNameValuePair.h"
#import "ZooniverseSubject.h"
#import "ZooniverseClassification.h"
#import "ZooniverseClassificationQuestion.h"
#import "ZooniverseClassificationAnswer.h"
#import "ZooniverseClassificationCheckbox.h"
#import "ZooniverseHttpUtils.h"
#import "Config.h"
#import "ConfigSubjectGroup.h"
#import "AppDelegate.h"
#import "Utils.h"
#import <RestKit/RestKit.h>

static const NSUInteger MIN_CACHED_NOT_DONE = 5;

@interface ZooniverseClient () <NSURLSessionDownloadDelegate> {
    NSURLSession *_session;

    //Mapping task id (NSString) to ZooniverseClientImageDownloadSet.
    NSMutableDictionary *_dictDownloadTasks;

    NSMutableSet *_imageDownloadsInProgress; //Of NSString URLs.
    NSMutableSet *_classificationUploadsInProgress; //Of NSString Subject IDs.

}

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSOperationQueue *uploadsQueue;



@end

@implementation ZooniverseClient

- (ZooniverseClient *) init;

{
    self = [super init];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 3;

    NSURLSessionConfiguration *configuration =
    [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"downloadImages"];
    _session = [NSURLSession sessionWithConfiguration:configuration
                                                          delegate:self
                                                     delegateQueue:queue];

    _dictDownloadTasks = [[NSMutableDictionary alloc] init];
    _imageDownloadsInProgress = [[NSMutableSet alloc] init];

    self.uploadsQueue = [[NSOperationQueue alloc] init];
    _classificationUploadsInProgress = [[NSMutableSet alloc] init];


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

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    RKObjectManager *objectManager = appDelegate.rkObjectManager;
    RKManagedObjectStore *managedObjectStore = appDelegate.rkManagedObjectStore;

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
        [objectManager addResponseDescriptor:responseDescriptor];
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

    self.managedObjectModel = appDelegate.managedObjectModel;
    self.managedObjectContext = appDelegate.managedObjectContext;
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

    NSError *error = nil;
    [self.managedObjectContext save:&error];
    //TODO: Check error
}

- (NSString *)getTaskIdAsString:(NSURLSessionDownloadTask *)task
{
    //Note: The ID is unique only within the session,
    //so never use this with multiple sessions:
    //https://developer.apple.com/library/mac/documentation/Foundation/Reference/NSURLSessionTask_class/index.html#//apple_ref/occ/instp/NSURLSessionTask/taskIdentifier
    NSString *strTaskId = [NSString stringWithFormat:@"%lu", (unsigned long)[task taskIdentifier], nil];
    return strTaskId;
}

/* Returns a task to be resumed,
 * or nil if no download was started, for instance if it's already in progress.
 */
- (NSURLSessionDownloadTask*)downloadImage:(ZooniverseSubject*)subject
             imageLocation:(ImageLocation)imageLocation
              session:(NSURLSession *)session
                  set:(ZooniverseClientImageDownloadSet *)set
{
    NSString *strUrlRemote = nil;
    BOOL alreadyDownloaded = NO;
    switch (imageLocation) {
        case ImageLocationStandard:
            strUrlRemote = subject.locationStandardRemote;
            alreadyDownloaded = subject.locationStandardDownloaded;
            break;
        case ImageLocationInverted:
            strUrlRemote = subject.locationInvertedRemote;
            alreadyDownloaded = subject.locationInvertedDownloaded;
            break;
        case ImageLocationThumbnail:
            strUrlRemote = subject.locationThumbnailRemote;
            alreadyDownloaded = subject.locationThumbnailDownloaded;
            break;
        default:
            break;
    }

    if (alreadyDownloaded) {
        return nil;
    }

    if ([_imageDownloadsInProgress containsObject:strUrlRemote]) {
        NSLog(@"downloadImage: image download already in progress: %@", strUrlRemote);
        return nil;
    }

    NSURL *urlRemote = [[NSURL alloc] initWithString:strUrlRemote];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlRemote];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request];

    //Store details about the task, so we can get them when it's finished:
    NSString *strTaskId = [self getTaskIdAsString:task];
    [_dictDownloadTasks setObject:set
                           forKey:strTaskId];

    //Remember the task details, so we can mark the files as downloaded in the task,
    //and call our callback block when all tasks are finished:
    ZooniverseClientImageDownload *download = [[ZooniverseClientImageDownload alloc] init];
    download.subject = subject;
    download.imageLocation = imageLocation;
    download.remoteUrl = strUrlRemote;
    [set.dictTasks setObject:download
                      forKey:strTaskId];

    //Remember that we are downloading this image, to avoid trying to download it again
    //at the same time:
    [_imageDownloadsInProgress addObject:strUrlRemote];

    return task;
}

/* Returns an array of NSURLSessionDownloadTask tasks to be resumed,
 * or an empty array if no downloads were started, for instance if, for some strange reason,
 * all downloads are already in progress.
 */
- (NSArray*)downloadImages:(ZooniverseSubject*)subject
               session:(NSURLSession *)session
                   set:(ZooniverseClientImageDownloadSet *)set
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSURLSessionDownloadTask* task;

    task = [self downloadImage:subject
                 imageLocation:ImageLocationStandard
                       session:session
                           set:set];
    if (task) {
        [result addObject:task];
    }

    task = [self downloadImage:subject
                 imageLocation:ImageLocationInverted
                       session:session
                           set:set];
    if (task) {
        [result addObject:task];
    }

    task = [self downloadImage:subject
                 imageLocation:ImageLocationThumbnail
                       session:session
                           set:set];
    if (task) {
        [result addObject:task];
    }

    return result;
}

- (void)querySubjects:(NSUInteger)count
         withCallback:(ZooniverseClientDoneBlock)callbackBlock
{
    NSString *countAsStr = [NSString stringWithFormat:@"%i", (unsigned int)count]; //TODO: Is this locale-independent?
    NSString *path = [self getQueryMoreItemsPath];
    NSDictionary *queryParams = @{@"limit" : countAsStr};

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    RKObjectManager *objectManager = appDelegate.rkObjectManager;
    [objectManager getObjectsAtPath:path
                          parameters:queryParams
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {

                                 NSString *iso8601String = currentTimeAsIso8601();

                                 NSArray* subjects = [mappingResult array];
                                 //NSLog(@"Loaded subjects: %@", subjects);


                                 //Store the group of tasks, so we can know when they have all completed:
                                 ZooniverseClientImageDownloadSet *set = [[ZooniverseClientImageDownloadSet alloc] init];
                                 set.callbackBlock = callbackBlock;

                                 NSMutableArray *tasks = [[NSMutableArray alloc] init];

                                 for (ZooniverseSubject *subject in subjects) {
                                     NSLog(@"  debug: subject zooniverseId: %@", [subject zooniverseId]);

                                     //Remember when we downloaded it, so we can always look at the earliest ones first:
                                     subject.datetimeRetrieved = iso8601String;

                                     NSArray *subjectTasks = [self downloadImages:subject
                                                                          session:_session
                                                                              set:set];
                                     if (subjectTasks) {
                                         [tasks addObjectsFromArray:subjectTasks];
                                     }
                                 }

                                 if (tasks.count == 0) {
                                     //Call the callback, just to stop it waiting for ever.
                                     //However, the subjects won't really be ready until the other
                                     //downloads have finished.
                                     NSLog(@"ZooniverseClient.query_subjects: all image downloads are already in progress.");

                                     [callbackBlock invoke];
                                 } else {
                                     //We resume all the tasks at once,
                                     //after we have stored all the task details to track,
                                     //so we don't mistakenly think we have finished all tasks
                                     //before we have finished adding the task details.
                                     for (NSURLSessionDownloadTask *task in tasks) {
                                         [task resume];
                                     }
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



+ (NSString *)getAnnotationPart:(NSInteger)sequence {
    return [NSString stringWithFormat:@"classification[annotations][%ld]", (long)sequence];
}



- (void)parseUploadResponse:(NSArray *)array {
    NSHTTPURLResponse *response = array[0];
    ZooniverseSubject *subject = array[1];

    if (response.statusCode == 201 /* Created */) {
        //TODO: Do this when we know the upload has succeeded:
        subject.uploaded = YES;

        //Save the ZooniverseClassification and the Subject to disk:
        NSError *error = nil;
        [self.managedObjectContext save:&error];
        //TODO: Check error.
    } else {
        NSInteger statusCode = response.statusCode;
        NSLog(@"debug: unexpected upload response for subject=%@: %ld", subject.subjectId,
              (long)statusCode);
    }

    [_classificationUploadsInProgress removeObject:subject.subjectId];

}

- (void)uploadClassifications {
    // Get the FetchRequest from our data model,
    // and use the same sort order as the ListViewController:
    // We have to copy it so we can set a sort order (sortDescriptors).
    // There doesn't seem to be a way to set the sort order in the data model GUI editor.
    NSFetchRequest *fetchRequest = [[self.managedObjectModel fetchRequestTemplateForName:@"fetchRequestDoneNotUploaded"] copy];
    [Utils fetchRequestSortByDateTimeRetrieved:fetchRequest];

    NSError *error = nil; //TODO: Check this.
    NSArray *results = [self.managedObjectContext
                        executeFetchRequest:fetchRequest
                        error:&error];

    //Note: We don't use RestKit to post, because the server doesn't use JSON to receive
    //the classifications - instead it's just a normal POST with form data.
    for (ZooniverseSubject *subject in results) {

        NSString *subjectId = subject.subjectId;

        //If the upload for this subject is in progress then ignore it.
        if ([_imageDownloadsInProgress containsObject:subjectId]) {
            NSLog(@"uploadClassifications: classification upload already in progress: %@", subjectId);
            continue;
        } else {
            [_imageDownloadsInProgress addObject:subjectId];
        }

        ZooniverseClassification *classification = subject.classification;

        //An array of ZooniverseNameValuePair:
        NSMutableArray *nameValuePairs = [[NSMutableArray alloc] init];

        [ZooniverseHttpUtils addNameValuePairToArray:nameValuePairs
                                      name:@"[subject_ids][]"
                                     value:subjectId];

        if (subject.favorite) {
            [ZooniverseHttpUtils addNameValuePairToArray:nameValuePairs
                              name:@"[favorite][]"
                             value:@"true"];
        }

        //Add each answer and its checkboxes:
        NSSortDescriptor *sortNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sequence"
                                                                            ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortNameDescriptor, nil];
        NSArray *sortedClassificationQuestions = [classification.classificationQuestions sortedArrayUsingDescriptors:sortDescriptors];



        NSInteger maxSequence = 0;
        for (ZooniverseClassificationQuestion *classificationQuestion in sortedClassificationQuestions) {
            NSInteger sequence = classificationQuestion.sequence;
            if (sequence > maxSequence) {
                maxSequence = sequence;
            }

            //The answer:
            ZooniverseClassificationAnswer *answer = classificationQuestion.answer;
            NSLog(@"debug: answer: %@", answer.answerId);
            NSString *questionKey = [NSString stringWithFormat:@"%@[%@]",
                              [ZooniverseClient getAnnotationPart:sequence],
                              classificationQuestion.questionId];
            [ZooniverseHttpUtils addNameValuePairToArray:nameValuePairs
                                          name:questionKey
                                         value:answer.answerId];

            //Add any checkboxes that were selected with the answer:
            for (ZooniverseClassificationCheckbox *checkbox in classificationQuestion.checkboxes) {
                [ZooniverseHttpUtils addNameValuePairToArray:nameValuePairs
                                              name:questionKey
                                             value:checkbox.checkboxId];
            }

            sequence++;
        }

        NSString *userAgentKey = [NSString stringWithFormat:@"%@[%@]",
                                 [ZooniverseClient getAnnotationPart:(maxSequence + 1)],
                                 @"user_agent"];
        [ZooniverseHttpUtils addNameValuePairToArray:nameValuePairs
                                      name:userAgentKey
                                     value:[Config userAgent]];

        NSString *content = [ZooniverseHttpUtils generateContentForNameValuePairs:nameValuePairs];

        NSString *postUploadUriStr =
        [NSString stringWithFormat:@"%@workflows/%@/classifications",
         [Config baseUrl],
         subject.groupId, nil];
        NSURL *postUploadUri = [NSURL URLWithString:postUploadUriStr];


        NSMutableURLRequest *request = [ZooniverseHttpUtils createURLRequest:postUploadUri];
        [request setHTTPMethod:@"POST"];

        //Note: I've also tried "application/x-www-form-urlencoded; charset=utf-8"
        //and ""application/x-www-form-urlencoded"
        [request setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];

        [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
        [request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];



        NSString *authName = [AppDelegate loginUsername];
        NSString *authApiKey = [AppDelegate loginApiKey];
        if (authName && authApiKey) {
            NSString *authHeader = [ZooniverseHttpUtils generateAuthorizationHeader:authName
                                                                      authApiKey:authApiKey];
            [request setValue:authHeader
           forHTTPHeaderField:@"Authorization"];
        }

        [ZooniverseHttpUtils setRequestContent:content
                                    forRequest:request];

        //NSDictionary *debugHeaderFields = request.allHTTPHeaderFields;

        [NSURLConnection sendAsynchronousRequest:request
                                           queue:self.uploadsQueue
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   //TODO: Should we somehow use a weak reference to Subject?
                                   NSHTTPURLResponse *httpResponse;
                                   if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                       httpResponse = (NSHTTPURLResponse *)response;
                                   }

                                   [self performSelectorOnMainThread:@selector(parseUploadResponse:)
                                                          withObject:@[httpResponse, subject]
                                                       waitUntilDone:NO];
                               }];

    }


}

- (void)downloadEnoughSubjects:(ZooniverseClientDoneBlock)callbackBlock
{
    NSFetchRequest *fetchRequest = [[self.managedObjectModel fetchRequestTemplateForName:@"fetchRequestNotDone"] copy];
    [Utils fetchRequestSortByDateTimeRetrieved:fetchRequest];
    fetchRequest.fetchLimit = MIN_CACHED_NOT_DONE;

    //Get more items from the server if necessary:
    NSError *error = nil; //TODO: Check this.
    NSArray *results = [[self managedObjectContext]
                        executeFetchRequest:fetchRequest
                        error:&error];
    NSInteger count = results.count;
    if (count < MIN_CACHED_NOT_DONE) {
        [self querySubjects:(MIN_CACHED_NOT_DONE - count)
                  withCallback:callbackBlock];
    } else {
        [callbackBlock invoke];
    }
}

- (void)downloadMissingImages:(ZooniverseClientDoneBlock)callbackBlock
{
    // Get the FetchRequest from our data model,
    // and use the same sort order as the ListViewController:
    // We have to copy it so we can set a sort order (sortDescriptors).
    // There doesn't seem to be a way to set the sort order in the data model GUI editor.
    NSFetchRequest *fetchRequest = [[self.managedObjectModel fetchRequestTemplateForName:@"fetchRequestMissingImages"] copy];
    [Utils fetchRequestSortByDateTimeRetrieved:fetchRequest];

    NSError *error = nil; //TODO: Check this.
    NSArray *results = [self.managedObjectContext
                        executeFetchRequest:fetchRequest
                        error:&error];
    if (results.count == 0) {
        [callbackBlock invoke];
        return;
    }

    ZooniverseClientImageDownloadSet *set = [[ZooniverseClientImageDownloadSet alloc] init];
    set.callbackBlock = callbackBlock;
    NSMutableArray *tasks = [[NSMutableArray alloc] init];
    for (ZooniverseSubject *subject in results) {
        NSLog(@"  debug: download missing images for subject zooniverseId: %@", [subject zooniverseId]);

        NSArray *subjectTasks = [self downloadImages:subject
                     session:_session
                         set:set];
        if (subjectTasks) {
            [tasks addObjectsFromArray:subjectTasks];
        }
    }

    if (tasks.count == 0) {
        [callbackBlock invoke];
        return;
    }

    for (NSURLSessionDownloadTask *task in tasks) {
        [task resume];
    }
}

- (void)onImageDownloadFinished:(NSString*)taskId
                            set:(ZooniverseClientImageDownloadSet*)set
{
    ZooniverseClientImageDownload *download = [set.dictTasks objectForKey:taskId];

    [set.dictTasks removeObjectForKey:taskId];
    [_dictDownloadTasks removeObjectForKey:taskId];

    [_imageDownloadsInProgress removeObject:download.remoteUrl];

    //TODO: Release download object?

    //Call the callbackBlock if this was the last task in the set:
    if (set.dictTasks.count == 0) {
        [set.callbackBlock invoke];
    }
}

- (void)onImageDownloadedAndAbandoned:(NSString*)taskId
{
    ZooniverseClientImageDownloadSet *set = [_dictDownloadTasks objectForKey:taskId];
    if (!set) {
        //Maybe this is a background task that has been resumed after the app has restarted,
        //but which we no longer have any information about, but we don't care because
        //nothing is still waiting for a callback
        NSLog(@"onImageDownloadedAndAbandoned: set is nil.");
        return;
    }

    [self onImageDownloadFinished:taskId
                         set:set];
}

- (void)onImageDownloadedAndMoved:(NSArray*)array
{
    NSString *taskId = [array objectAtIndex:0];
    NSString *permanentPath = [array objectAtIndex:1];

    ZooniverseClientImageDownloadSet *set = [_dictDownloadTasks  objectForKey:taskId];
    ZooniverseClientImageDownload *download = [set.dictTasks objectForKey:taskId];

    if (!set) {
        //Maybe this is a background task that has been resumed after the app has restarted,
        //but which we no longer have any information about, so we cannot mark the
        //relevant ZooniverseSubject as downloaded.
        //TODO: Find a way to use these downloaded files.
        NSLog(@"onImageDownloadedAndMoved: set is nil.");
        return;
    }

    NSLog(@"onImageDownloadedAndMoved: imageLocation: %ld: %@", (long)download.imageLocation, permanentPath, nil);


    //TODO: Check response and error.
    [self onImageDownloaded:download.subject
              imageLocation:download.imageLocation
                  localFile:permanentPath];

    [self onImageDownloadFinished:taskId
                         set:set];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSURLResponse *response = [downloadTask response];
    //TODO: Check response.
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // Create the directory if necessary:
    NSURL *urlDocsDir = [[fileManager URLsForDirectory:NSCachesDirectory
                                            inDomains:NSUserDomainMask] lastObject];

    NSString *docsDir = urlDocsDir.path;
    NSString *appDir = [docsDir stringByAppendingPathComponent:@"/GalaxyZooImages/"]; //TODO
    NSError *error = nil;
    if(![fileManager fileExistsAtPath:appDir])
    {
        if(![fileManager createDirectoryAtPath:appDir
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:&error]) {
            NSLog(@"  Error from createDirectoryAtPath(): %@", [error description]);
        }
    }

    NSString *permanentPath;
    if(!error) {
        // Build a local filepath based on the suggestion in the response:
        NSString *suggestedFilename = [response suggestedFilename];
        permanentPath = [appDir stringByAppendingFormat:@"/%@", suggestedFilename];

        // Delete the file if it already exists:
        if([fileManager fileExistsAtPath:permanentPath])
        {
            if(![fileManager removeItemAtPath:appDir
                                        error:&error]) {
                NSLog(@"Could not delete existing cache file: %@: error: %@", permanentPath,
                      [error description]);
            }
        }
    }

    if(!error) {
        // Move the temporary file to the permanent location:
        BOOL fileCopied = [fileManager moveItemAtPath:location.path
                                               toPath:permanentPath
                                                error:&error];
        if (!fileCopied) {
            NSLog(@"Couldn't copy file: %@", location.path, nil);
            NSLog(@"  Error: %@", [error description]);
        } else {
            NSLog(@"debug: file stored: %@", permanentPath);
        }
    }

    //The didFinishDownloadingToURL documentation tells us to move the file before the end of this function.
    //But let's not risk doing anything else outside of the main thread:
    NSString *strTaskId = [self getTaskIdAsString:downloadTask];
    if(!error) {
        [self performSelectorOnMainThread:@selector(onImageDownloadedAndMoved:)
                       withObject:@[strTaskId, permanentPath]
                    waitUntilDone:NO];
    } else {
        [self performSelectorOnMainThread:@selector(onImageDownloadedAndAbandoned:)
                               withObject:strTaskId
                            waitUntilDone:NO];
    }
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
