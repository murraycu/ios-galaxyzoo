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
#import "Reachability.h"
#import <RestKit/RestKit.h>

static const NSString *PARAM_PART_CLASSIFICATION = @"classification";

@interface ZooniverseClient () <NSURLSessionDownloadDelegate> {
    NSURLSession *_session;

    //Mapping task id (NSString) to ZooniverseClientImageDownloadSet.
    NSMutableDictionary *_dictDownloadTasks;

    NSMutableSet *_imageDownloadsInProgress; //Of NSString URLs.

    NSMutableSet *_classificationUploadsInProgress; //Of NSString Subject IDs.
    ZooniverseClientDoneBlock _callbackBlockUploads; //TODO: Have one per set of uploads.
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

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
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
        ConfigSubjectGroup *subjectGroup = dict[groupId];
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

    NSError *error = nil;
    [managedObjectStore addSQLitePersistentStoreAtPath:storePath
                                                                     fromSeedDatabaseAtPath:nil
                                                                          withConfiguration:nil
                                                                                    options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error];
    if (error) {
        NSLog(@"setupRestkit(): addSQLitePersistentStoreAtPath failed: %@", error);
    }


    //NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);

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
        ConfigSubjectGroup *subjectGroup = dict[groupId];
        if (subjectGroup.useForNewQueries) {
            [groupIds addObject:groupId];
        }
    }

    NSUInteger idx = arc4random_uniform((u_int32_t)groupIds.count);
    return groupIds[idx];
}

NSString * currentTimeAsIso8601(void)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.locale = enUSPOSIXLocale;
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";

    NSDate *now = [NSDate date];
    NSString *iso8601String = [dateFormatter stringFromDate:now];
    return iso8601String;
}

- (void)saveCoreDataInMainThread
{
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Could not save core data: error: %@", error.description);
        return;
    }

    //managedObjectContext is RestKit's child NSManagedObjectStore,
    //so just calling save() on it doesn't really make the parent save itself to the store.
    if(![self.managedObjectContext saveToPersistentStore:&error]) {
        NSLog(@"Could not save core data to persistent store: error: %@", error.description);
    }
}

// Runs on main thread.
- (void)onImageDownloaded:(ZooniverseSubject*)subject
        imageLocation:(ImageLocation)imageLocation
                localFile:(NSString*)localFile
{
    //localFile is only the last part of the filepath,
    //because the parent folder name can change between application launches.
    //See http://stackoverflow.com/questions/31452098/nsdocumentdirectory-files-disappear-in-ios
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

    [self saveCoreDataInMainThread];
}

- (NSString *)getTaskIdAsString:(NSURLSessionDownloadTask *)task
{
    //Note: The ID is unique only within the session,
    //so never use this with multiple sessions:
    //https://developer.apple.com/library/mac/documentation/Foundation/Reference/NSURLSessionTask_class/index.html#//apple_ref/occ/instp/NSURLSessionTask/taskIdentifier
    NSString *strTaskId = [NSString stringWithFormat:@"%lu", (unsigned long)task.taskIdentifier, nil];
    return strTaskId;
}

/* Returns a task to be resumed,
 * or nil if no download was started, for instance if it's already in progress.
 *
 * Runs in main thread.
 */
- (NSURLSessionDownloadTask*)createDownloadImageTask:(ZooniverseSubject*)subject
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

    if ([ZooniverseClient downloadedImageExistsAlready:strUrlRemote
         forImageLocation:imageLocation]) {
        //Don't bother downloading it again
        //We can assume that it has fully downloaded because it has been moved to its
        //permanent location.
        //For some reason the subject has not been marked, so do that now.
        //This can happen when the image's background download tasks completes while the
        //application is closed - when the app restarts then didFinishDownloadingToURL will
        //be called but the task will no longer be in our list of downloads in progress,
        //so we wouldn't be able to know what subject (and imageLocatino) it's for.
        NSLog(@"Found existing image download for uri: %@", strUrlRemote);

        NSURL *remoteUri = [NSURL URLWithString:strUrlRemote];
        NSString *partialPermanentPath = [ZooniverseClient partialLocalPathForRemotePath:remoteUri
                                                                        forImageLocation:imageLocation                                                                    withFallbackBasename:nil];

        switch (imageLocation) {
            case ImageLocationStandard:
                subject.locationStandard = partialPermanentPath;
                subject.locationStandardDownloaded = YES;
                break;
            case ImageLocationInverted:
                subject.locationInverted = partialPermanentPath;
                subject.locationInvertedDownloaded = YES;
                break;
            case ImageLocationThumbnail:
                subject.locationThumbnail = partialPermanentPath;
                subject.locationThumbnailDownloaded = YES;
                break;
            default:
                break;
        }

        [self saveCoreDataInMainThread];

        //TODO: Instead check its validity whenever we try to use it in a UIImageView.
        return nil;
    }

    NSURL *urlRemote = [[NSURL alloc] initWithString:strUrlRemote];
    NSURLRequest *request = [ZooniverseHttpUtils createURLRequest:urlRemote];

    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request];

    //Store details about the task, so we can get them when it's finished:
    NSString *strTaskId = [self getTaskIdAsString:task];
    _dictDownloadTasks[strTaskId] = set;

    //Remember the task details, so we can mark the files as downloaded in the task,
    //and call our callback block when all tasks are finished:
    ZooniverseClientImageDownload *download = [[ZooniverseClientImageDownload alloc] init];
    download.subject = subject;
    download.imageLocation = imageLocation;
    download.remoteUrl = strUrlRemote;
    (set.dictTasks)[strTaskId] = download;

    //Remember that we are downloading this image, to avoid trying to download it again
    //at the same time:
    [_imageDownloadsInProgress addObject:strUrlRemote];

    return task;
}

/* Returns an array of NSURLSessionDownloadTask tasks to be resumed,
 * or an empty array if no downloads were started, for instance if, for some strange reason,
 * all downloads are already in progress.
 *
 * Runs in the main thread.
 * TODO: Is RKObjectManager's getObjectsAtPath's success callback really called in the main thread?
 * The documentation doesn't say:
 *  http://cocoadocs.org/docsets/RestKit/0.20.0/Classes/RKObjectManager.html#//api/name/getObjectsAtPath:parameters:success:failure:
 */
- (NSArray*)createDownloadImagesTasks:(ZooniverseSubject*)subject
               session:(NSURLSession *)session
                   set:(ZooniverseClientImageDownloadSet *)set
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSURLSessionDownloadTask* task;

    task = [self createDownloadImageTask:subject
                 imageLocation:ImageLocationStandard
                       session:session
                           set:set];
    if (task) {
        [result addObject:task];
    }

    task = [self createDownloadImageTask:subject
                 imageLocation:ImageLocationInverted
                       session:session
                           set:set];

    if (task) {
        [result addObject:task];
    }

    task = [self createDownloadImageTask:subject
                 imageLocation:ImageLocationThumbnail
                       session:session
                           set:set];

    if (task) {
        [result addObject:task];
    }

    return result;
}

// Runs on main thread.
- (void)querySubjects:(NSUInteger)count
         withCallback:(ZooniverseClientDoneBlock)callbackBlock
{
    if(![ZooniverseClient networkIsConnected]) {
        [callbackBlock invoke];
        return;
    }

    NSString *countAsStr = [NSString stringWithFormat:@"%i", (unsigned int)count]; //TODO: Is this locale-independent?
    NSString *path = [self getQueryMoreItemsPath];
    NSDictionary *queryParams = @{@"limit" : countAsStr};

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    RKObjectManager *objectManager = appDelegate.rkObjectManager;

    [ZooniverseClient setNetworkActivityIndicatorVisibleOnMainThread:YES];
    [objectManager getObjectsAtPath:path
                          parameters:queryParams
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 [ZooniverseClient setNetworkActivityIndicatorVisibleOnMainThread:NO];

                                 NSString *iso8601String = currentTimeAsIso8601();

                                 NSArray* subjects = [mappingResult array];
                                 //NSLog(@"Loaded subjects: %@", subjects);


                                 //Store the group of tasks, so we can know when they have all completed:
                                 ZooniverseClientImageDownloadSet *set = [[ZooniverseClientImageDownloadSet alloc] init];
                                 set.callbackBlock = callbackBlock;

                                 NSMutableArray *tasks = [[NSMutableArray alloc] init];

                                 for (ZooniverseSubject *subject in subjects) {
                                     //NSLog(@"  debug: subject zooniverseId: %@", [subject zooniverseId]);

                                     //Remember when we downloaded it, so we can always look at the earliest ones first:
                                     subject.datetimeRetrieved = iso8601String;

                                     NSArray *subjectTasks = [self createDownloadImagesTasks:subject
                                                                          session:_session
                                                                              set:set];
                                     if (subjectTasks) {
                                         [tasks addObjectsFromArray:subjectTasks];
                                     }
                                 }

                                 //Save the Subjects to disk:
                                 NSError *error = nil;
                                 if(![self.managedObjectContext save:&error]) {
                                     NSLog(@"querySubjects(): save failed: %@", error);
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
                                         [ZooniverseClient setNetworkActivityIndicatorVisibleOnMainThread:YES];
                                         [task resume];
                                     }
                                 }

                             }
                             failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"A title for an error dialog.")
                                                                                 message:error.localizedDescription
                                                                                delegate:nil
                                                                cancelButtonTitle:NSLocalizedString(@"OK", @"A title for a dialog button.")
                                                                       otherButtonTitles:nil];
                                 [alert show];
                                 NSLog(@"ZooniverseClient.query_subjects: error: %@", error);

                                 [callbackBlock invoke];
                             }];
}



+ (NSString *)getAnnotationPart:(NSInteger)sequence {
    return [NSString stringWithFormat:@"%@[annotations][%ld]", PARAM_PART_CLASSIFICATION, (long)sequence];
}


// TODO: Runs on the main thread. TODO: Maybe it shouldn't.
- (void)parseUploadResponse:(NSArray *)array {
    if (array == nil) {
        NSLog(@"parseUploadResponse: array is unexpectedly nil.");
        return;
    }

    if ([array count] < 2) {
        NSLog(@"parseUploadResponse: array is unexpectedly smaller than 2.");
        return;
    }

    NSHTTPURLResponse *response = array[0];
    if (response == nil) {
        NSLog(@"parseUploadResponse: response is unexpectedly nil.");
        return;
    }

    ZooniverseSubject *subject = array[1];
    if (subject == nil) {
        NSLog(@"parseUploadResponse: subject is unexpectedly nil.");
        return;
    }

    if (response.statusCode == 201 /* Created */) {
        //TODO: Do this when we know the upload has succeeded:
        subject.uploaded = YES;

        //Save the ZooniverseClassification and the Subject to disk:
        [self saveCoreDataInMainThread];
    } else {
        NSInteger statusCode = response.statusCode;
        NSLog(@"debug: unexpected upload response for subject=%@: %ld", subject.subjectId,
              (long)statusCode);
    }

    [_classificationUploadsInProgress removeObject:subject.subjectId];

    if (_classificationUploadsInProgress.count == 0) {
        [_callbackBlockUploads invoke];
    }

}

+ (void)setNetworkActivityIndicatorVisibleOnMainThread:(BOOL)setVisible {
    //We use dispatch_async instead of performSelectorOnMainThread just because it is simpler:
    dispatch_async(dispatch_get_main_queue(), ^{
        [AppDelegate setNetworkActivityIndicatorVisible:setVisible];
    });
}

// Runs on the main thread. TODO: Maybe it shouldn't.
- (void)uploadClassificationForSubject:(ZooniverseSubject *)subject {
    NSString *subjectId = subject.subjectId;

    //If the upload for this subject is in progress then ignore it.
    if ([_classificationUploadsInProgress containsObject:subjectId]) {
        NSLog(@"uploadClassifications: classification upload already in progress: %@", subjectId);
        return;
    } else {
        [_classificationUploadsInProgress addObject:subjectId];
    }

    ZooniverseClassification *classification = subject.classification;

    //An array of ZooniverseNameValuePair:
    NSMutableArray *nameValuePairs = [[NSMutableArray alloc] init];

    NSString *subjectKey = [NSString stringWithFormat:@"%@[subject_ids][]",
                            PARAM_PART_CLASSIFICATION];;
    [ZooniverseHttpUtils addNameValuePairToArray:nameValuePairs
                                            name:subjectKey
                                           value:subjectId];

    if (subject.favorite) {
        [ZooniverseHttpUtils addNameValuePairToArray:nameValuePairs
                                                name:@"[favorite][]"
                                               value:@"true"];
    }

    //Add each answer and its checkboxes:
    NSSortDescriptor *sortNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sequence"
                                                                       ascending:YES];
    NSArray *sortDescriptors = @[sortNameDescriptor];
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
    request.HTTPMethod = @"POST";

    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

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

    [ZooniverseClient setNetworkActivityIndicatorVisibleOnMainThread:YES];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:self.uploadsQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               [ZooniverseClient setNetworkActivityIndicatorVisibleOnMainThread:NO];

                               //TODO: Should we somehow use a weak reference to Subject?
                               NSHTTPURLResponse *httpResponse;
                               if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                   httpResponse = (NSHTTPURLResponse *)response;
                               }

                               [self performSelectorOnMainThread:@selector(parseUploadResponse:)
                                                      withObject:@[(httpResponse != nil ? httpResponse : [NSNull null]), subject]
                                                   waitUntilDone:NO];
                           }];
}

// Runs on the main thread.
- (void)uploadOutstandingClassifications:(ZooniverseClientDoneBlock)callbackBlock; {
    //If a set of uploads is already in prgoress then just return,
    //because we don't track each set of uploads separately,
    //so we can't know when to invoke the callbackBlock for just this set of uploads.
    //TODO: Find a way to track a set of uploads, as we do with image downloads - but we can do that
    //for image uploads because we get the task (and its ID) when it completes.
    if (_classificationUploadsInProgress.count > 0) {
        [callbackBlock invoke];
        return;
    }

    if(![ZooniverseClient networkIsConnected]) {
        [callbackBlock invoke];
        return;
    }

    // Get the FetchRequest from our data model,
    // and use the same sort order as the ListViewController:
    // We have to copy it so we can set a sort order (sortDescriptors).
    // There doesn't seem to be a way to set the sort order in the data model GUI editor.
    NSFetchRequest *fetchRequest = [[self.managedObjectModel fetchRequestTemplateForName:@"fetchRequestDoneNotUploaded"] copy];
    [Utils fetchRequestSortByDateTimeRetrieved:fetchRequest];

    NSError *error = nil;
    NSArray *results = [self.managedObjectContext
                        executeFetchRequest:fetchRequest
                        error:&error];
    if (results == nil) {
        NSLog(@"uploadOutstandingClassifications(): executeFetchRequest failed: %@", error);
    }

    //If there are no classifications to upload then just return:
    if (results.count == 0) {
        [callbackBlock invoke];
        return;
    }

    _callbackBlockUploads = callbackBlock;

    //Note: We don't use RestKit to post, because the server doesn't use JSON to receive
    //the classifications - instead it's just a normal POST with form data.
    for (ZooniverseSubject *subject in results) {
        [self uploadClassificationForSubject:subject];
    }
}

// Runs on main thread.
- (void)downloadMinimumSubjects:(ZooniverseClientDoneBlock)callbackBlock
{
    NSInteger minCachedNotDone = [AppDelegate preferenceDownloadInAdvance];

    NSFetchRequest *fetchRequest = [[self.managedObjectModel fetchRequestTemplateForName:@"fetchRequestNotDone"] copy];
    [Utils fetchRequestSortByDateTimeRetrieved:fetchRequest];
    fetchRequest.fetchLimit = minCachedNotDone;

    //Get more items from the server if necessary:
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext
                        executeFetchRequest:fetchRequest
                        error:&error];
    if (results == nil) {
        NSLog(@"downloadMinimumSubjects(): executeFetchRequest failed: %@", error);
    }

    NSInteger count = results.count;
    if (count < minCachedNotDone) {
        [self querySubjects:(minCachedNotDone - count)
                  withCallback:callbackBlock];
    } else {
        [callbackBlock invoke];
    }
}

// Runs on main thread.
- (void)downloadMissingImages:(ZooniverseClientDoneBlock)callbackBlock
{
    if(![ZooniverseClient networkIsConnected]) {
        [callbackBlock invoke];
        return;
    }

    // Get the FetchRequest from our data model,
    // and use the same sort order as the ListViewController:
    // We have to copy it so we can set a sort order (sortDescriptors).
    // There doesn't seem to be a way to set the sort order in the data model GUI editor.
    NSFetchRequest *fetchRequest = [[self.managedObjectModel fetchRequestTemplateForName:@"fetchRequestMissingImages"] copy];
    [Utils fetchRequestSortByDateTimeRetrieved:fetchRequest];

    NSError *error = nil;
    NSArray *results = [self.managedObjectContext
                        executeFetchRequest:fetchRequest
                        error:&error];
    if (results == nil) {
        NSLog(@"downloadMissingImages(): executeFetchRequest failed: %@", error);
        [callbackBlock invoke];
        return;
    }

    if (results.count == 0) {
         //This is normal: NSLog(@"downloadMissingImages(): executeFetchRequest returned no items: %@", error);
        [callbackBlock invoke];
        return;
    }

    ZooniverseClientImageDownloadSet *set = [[ZooniverseClientImageDownloadSet alloc] init];
    set.callbackBlock = callbackBlock;
    NSMutableArray *tasks = [[NSMutableArray alloc] init];
    for (ZooniverseSubject *subject in results) {
        NSLog(@"  debug: download missing images for subject zooniverseId: %@", subject.zooniverseId);

        NSArray *subjectTasks = [self createDownloadImagesTasks:subject
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

// Runs on main thread:
- (void)onImageDownloadFinished:(NSString*)taskId
                            set:(ZooniverseClientImageDownloadSet*)set
{
    ZooniverseClientImageDownload *download = (set.dictTasks)[taskId];

    [set.dictTasks removeObjectForKey:taskId];
    [_dictDownloadTasks removeObjectForKey:taskId];

    [_imageDownloadsInProgress removeObject:download.remoteUrl];

    //TODO: Release download object?

    //Call the callbackBlock if this was the last task in the set:
    if (set.dictTasks.count == 0) {
        [set.callbackBlock invoke];
    }
}

// Runs on main thread.
- (void)onImageDownloadedAndAbandoned:(NSString*)taskId
{
    ZooniverseClientImageDownloadSet *set = _dictDownloadTasks[taskId];
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

// Runs on main thread.
- (void)onImageDownloadedAndMoved:(NSArray*)array
{
    NSString *taskId = array[0];
    NSString *partialPermanentPath = array[1];

    ZooniverseClientImageDownloadSet *set = _dictDownloadTasks[taskId];
    ZooniverseClientImageDownload *download = (set.dictTasks)[taskId];

    if (!set) {
        //Maybe this is a background task that has been resumed after the app has restarted,
        //but which we no longer have any information about, so we cannot mark the
        //relevant ZooniverseSubject as downloaded.
        //This will be used later when we detect it in the downloadImage method.
        NSLog(@"onImageDownloadedAndMoved: set is nil.");
        return;
    }

    //NSLog(@"onImageDownloadedAndMoved: imageLocation: %ld: %@", (long)download.imageLocation, permanentPath, nil);


    //TODO: Check response and error.
    [self onImageDownloaded:download.subject
              imageLocation:download.imageLocation
                  localFile:partialPermanentPath];

    [self onImageDownloadFinished:taskId
                         set:set];
}

// Runs on main thread.
+ (BOOL) downloadedImageExistsAlready:(NSString*)remoteUrlStr
                     forImageLocation:(ImageLocation)imageLocation {
    NSURL *remoteUri = [NSURL URLWithString:remoteUrlStr];
    NSString *imagesDir = [ZooniverseClient imagesDir];
    NSString * permanentPath = [ZooniverseClient fullLocalPathForRemotePath:remoteUri
                                                       forImageLocation:imageLocation
                                                              forAppDir:imagesDir];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:permanentPath];
}

+ (NSString *)imagesDir {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // Create the directory if necessary:
    NSURL *urlDocsDir = [fileManager URLsForDirectory:NSCachesDirectory
                                             inDomains:NSUserDomainMask].lastObject;

    NSString *docsDir = urlDocsDir.path;
    return [docsDir stringByAppendingPathComponent:@"/GalaxyZooImages/"];
}

+ (NSString *)prefixForImageLocation:(ImageLocation)imageLocation {
    NSString *result;
    switch(imageLocation) {
        case ImageLocationStandard:
            result = @"standard";
            break;
        case ImageLocationInverted:
            result = @"inverted";
            break;
        case ImageLocationThumbnail:
            result = @"thumbnail";
            break;
    }

    return result;
}

+ (NSString *)fullLocalPathForRemotePath:(NSURL *)remoteUrl
                    forImageLocation:(ImageLocation)imageLocation
                           forAppDir:(NSString *)appDir {
    return [ZooniverseClient fullLocalPathForRemotePath:remoteUrl
                                   forImageLocation:imageLocation
                                          forAppDir:appDir
                               withFallbackBasename:nil];
}

+ (NSString *)fullLocalPathForRemotePath:(NSURL *)remoteUrl
                    forImageLocation:(ImageLocation)imageLocation
                           forAppDir:(NSString *)appDir
                withFallbackBasename:(NSString *)fallbackBaseName {
    NSString *partial = [ZooniverseClient partialLocalPathForRemotePath:remoteUrl
                         forImageLocation:imageLocation
                                                   withFallbackBasename:fallbackBaseName];

    return [appDir stringByAppendingFormat:@"/%@", partial];
}

+ (NSString *)partialLocalPathForRemotePath:(NSURL *)remoteUrl
                    forImageLocation:(ImageLocation)imageLocation
                withFallbackBasename:(NSString *)fallbackBaseName {
    NSString *basename = remoteUrl.lastPathComponent;
    if (basename.length == 0) {
        //Fall back to the suggested name in this very unlikely case:
        NSLog(@"localPathForRemotePath: Falling back to suggested local filename.");
        basename = fallbackBaseName;
    }

    NSString *locationPrefix = [ZooniverseClient prefixForImageLocation:imageLocation];
    return [locationPrefix stringByAppendingFormat:@"_%@", basename];
}

+ (NSString *)fullLocalPath:(NSString *)partialLocalPath
                               forAppDir:(NSString *)appDir {
    return [appDir stringByAppendingFormat:@"/%@", partialLocalPath];
}

+ (NSString *)fullLocalImagePath:(NSString *)partialLocalPath {
    NSString *appDir = [ZooniverseClient imagesDir];
    return [appDir stringByAppendingFormat:@"/%@", partialLocalPath];
}


#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    [ZooniverseClient setNetworkActivityIndicatorVisibleOnMainThread:NO];

    //Normally we would do any work in the main thread via performSelectorOnMainThread(),
    //but, according to the documentation, we must first move the file to its permanent location.

    //TODO: Check response.
    NSURLResponse *response = downloadTask.response;

    NSFileManager *fileManager = [NSFileManager defaultManager];

    // Create the directory if necessary:
    NSString *appDir = [ZooniverseClient imagesDir];
    NSError *error = nil;
    //TODO: Checking ,instead of responding, allows a race condition.
    if(![fileManager fileExistsAtPath:appDir])
    {
        if(![fileManager createDirectoryAtPath:appDir
               withIntermediateDirectories:NO
                                attributes:nil
                                     error:&error]) {
            NSLog(@"  Error from createDirectoryAtPath(): %@", error.description);
        }
    }



    NSString *partialPermanentPath;
    NSString *permanentPath;
    if(!error) {
        // Build a local filepath.
        // We ignore the suggested filename in [response suggestedFilename]
        // because we want to identify the files later by their name only.
        NSString *taskId = [self getTaskIdAsString:downloadTask];
        ZooniverseClientImageDownloadSet *set = _dictDownloadTasks[taskId];
        ZooniverseClientImageDownload *download = (set.dictTasks)[taskId];

        partialPermanentPath = [ZooniverseClient partialLocalPathForRemotePath:response.URL
                                                                        forImageLocation:download.imageLocation
                                                                    withFallbackBasename:response.suggestedFilename];
        permanentPath = [ZooniverseClient fullLocalPath:partialPermanentPath
                                              forAppDir:appDir];

        // Delete the file if it already exists:
        if([fileManager fileExistsAtPath:permanentPath])
        {
            if(![fileManager removeItemAtPath:permanentPath
                                        error:&error]) {
                NSLog(@"Could not delete existing cache file: %@: error: %@", permanentPath,
                      error.description);
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
            NSLog(@"  Error: %@", error.description);
        } else {
            //NSLog(@"debug: file stored: %@", permanentPath);
        }
    }

    //The didFinishDownloadingToURL documentation tells us to move the file before the end of this function.
    //But let's not risk doing anything else outside of the main thread:
    NSString *strTaskId = [self getTaskIdAsString:downloadTask];
    if(!error) {
        [self performSelectorOnMainThread:@selector(onImageDownloadedAndMoved:)
                       withObject:@[strTaskId, partialPermanentPath]
                    waitUntilDone:NO];
    } else {
        [self performSelectorOnMainThread:@selector(onImageDownloadedAndAbandoned:)
                               withObject:strTaskId
                            waitUntilDone:NO];
    }
}

// Runs in main thread.
- (void)removeOldSubjects:(ZooniverseClientDoneBlock)callbackBlock
{
    NSInteger maxKept = [AppDelegate preferenceKeep];

    // Get the FetchRequest from our data model,
    // and use the same sort order as the ListViewController:
    // We have to copy it so we can set a sort order (sortDescriptors).
    // There doesn't seem to be a way to set the sort order in the data model GUI editor.
    NSFetchRequest *fetchRequest = [[self.managedObjectModel fetchRequestTemplateForName:@"fetchRequestUploaded"] copy];
    [Utils fetchRequestSortByDateTimeRetrieved:fetchRequest];

    NSError *error = nil;
    NSArray *results = [self.managedObjectContext
                        executeFetchRequest:fetchRequest
                        error:&error];
    if (results == nil) {
        NSLog(@"removeOldSubjects(): executeFetchRequest failed: %@", error);
    }

    NSInteger countToRemove = results.count - maxKept;
    //If there are no classifications to remove then just return:
    if (countToRemove <= 0) {
        [callbackBlock invoke];
        return;
    }

    NSInteger i = 0;
    for (ZooniverseSubject *subject in results) {
        [self abandonSubjectInMainThread:subject
                        withCoreDataSave:NO]; //We save after deleting them all.

        i++;
        if (i == countToRemove) {
            break;
        }
    }

    [self saveCoreDataInMainThread];
    [callbackBlock invoke];
}

+ (BOOL)checkSingleSubjectImageStillExists:(NSString *)partialLocalPath
                      withFileManager:(NSFileManager *)fileManager {
    NSString *fullPath = [ZooniverseClient fullLocalImagePath:partialLocalPath];
    BOOL result = [fileManager fileExistsAtPath:fullPath];
    if (!result) {
        NSLog(@"checkSingleSubjectImageStillExists(): file does not exist: %@", fullPath);
    }

    return result;
}

- (BOOL)checkSubjectImagesStillExists:(ZooniverseSubject *)subject {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![ZooniverseClient checkSingleSubjectImageStillExists:subject.locationStandard
                                              withFileManager:fileManager]) {
        return NO;
    }

    if (![ZooniverseClient checkSingleSubjectImageStillExists:subject.locationInverted
        withFileManager:fileManager]) {
        return NO;
    }

    if (![ZooniverseClient checkSingleSubjectImageStillExists:subject.locationThumbnail
                                              withFileManager:fileManager]) {
        return NO;
    }

    return YES;
}

// Runs on main thread.
- (void)checkImagesStillExist:(ZooniverseClientDoneBlock)callbackBlock
{
    NSFetchRequest *fetchRequest = [[self.managedObjectModel fetchRequestTemplateForName:@"fetchRequestDownloadsDone"] copy];
    [Utils fetchRequestSortByDateTimeRetrieved:fetchRequest];

    NSError *error = nil;
    NSArray *results = [self.managedObjectContext
                        executeFetchRequest:fetchRequest
                        error:&error];
    if (results == nil) {
        NSLog(@"checkImagesStillExist(): executeFetchRequest failed: %@", error);
    }

    BOOL somethingChanged = NO;
    for (ZooniverseSubject *subject in results) {
        if (![self checkSubjectImagesStillExists:subject]) {
            NSLog(@"checkImagesStillExist(): abandoning because checkSubjectImagesStillExists() failed.");
            [self abandonSubjectInMainThread:subject
                            withCoreDataSave:NO]; //We save after deleting them all.
            somethingChanged = YES;
        }
    }

    if (somethingChanged) {
        [self saveCoreDataInMainThread];
    }

    [callbackBlock invoke];
}

- (void)deleteImageFile:(NSString *)partialLocalPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    //We don't care whether this succeeds - we just want
    //to do our best to delete it.
    //Also, the behaviour if the file doesn't exist is not documented.
    NSString *fullLocalPath = [ZooniverseClient fullLocalImagePath:partialLocalPath];
    [fileManager removeItemAtPath:fullLocalPath
                               error:nil];
}

- (void)deleteImagesForSubject:(ZooniverseSubject *)subject
{
    //We don't care whether these succeed - we just want
    //to do our best to delete them.
    //Also, the behaviour if the file doesn't exist is not documented,
    [self performSelectorInBackground:@selector(deleteImageFile:)
                           withObject:subject.locationStandard];
    subject.locationStandard = nil;
    subject.locationStandardDownloaded = NO;

    [self performSelectorInBackground:@selector(deleteImageFile:)
                           withObject:subject.locationInverted];
    subject.locationInverted = nil;
    subject.locationInvertedDownloaded = NO;

    [self performSelectorInBackground:@selector(deleteImageFile:)
                           withObject:subject.locationThumbnail];
    subject.locationThumbnail = nil;
    subject.locationThumbnailDownloaded = NO;
}

/* This should only be called from the main thread.
 */
- (void)abandonSubjectInMainThread:(ZooniverseSubject *)subject
      withCoreDataSave:(BOOL)coreDataSave
{
    if (subject == nil) {
        NSLog(@"abandonSubject: subject is nil.");
    }

    NSLog(@"abandonSubject: Abandoning subject with subjectId: %@", subject.subjectId, nil);

    //Start asynchronous deletion of the image files.
    //We don't care when it finishes.
    [self deleteImagesForSubject:subject];

    [self.managedObjectContext deleteObject:subject];

    if (coreDataSave) {
        [self saveCoreDataInMainThread];
    }
}


/* Check that we have a suitable connection.
 * For instance, don't allow network use if we are on mobile but our setting says wifi-only.
 */
+ (BOOL)networkIsConnected {
    BOOL ignoredParameter;
    return [ZooniverseClient networkIsConnected:&ignoredParameter];
}

/* Check that we have a suitable connection.
 * For instance, don't allow network use if we are on mobile but our setting says wifi-only.
 */
+ (BOOL)networkIsConnected:(BOOL*)noWiFi {
    *noWiFi = NO;

    //We use the Reachability class from Apple's example documentation.
    //It is astonishing that there is no real API for this:
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"There IS NO internet connection");
        return NO;
    }

    BOOL wifiOnly = [AppDelegate preferenceWiFiOnly];
    if (wifiOnly && networkStatus != ReachableViaWiFi) {
        *noWiFi = YES; //Let the caller know that this is why the network shouldn't be used.
        return NO;
    }

    return YES;
}

@end
