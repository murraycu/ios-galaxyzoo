//
//  ZooniverseClient.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 01/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "ZooniverseClient.h"
#import "ZooniverseSubject.h"
#import "ZooniverseClassification.h"
#import "ZooniverseClassificationAnswer.h"
#import "Config.h"
#import "ConfigSubjectGroup.h"
#import "AppDelegate.h"
#import "Utils.h"
#import <RestKit/RestKit.h>

static NSString * BASE_URL = @"https://api.zooniverse.org/projects/galaxy_zoo/";

@interface ZooniverseClient () {
    RKObjectManager * _objectManager;
}

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@end

@implementation ZooniverseClient

- (ZooniverseClient *) init;

{
    self = [super init];

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

- (void)querySubjects:(NSUInteger)count
         withCallback:(QueryDoneBlock)callbackBlock;
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

                                 for (ZooniverseSubject *subject in subjects) {
                                     NSLog(@"  debug: subject zooniverseId: %@", [subject zooniverseId]);

                                     //Remember when we downloaded it, so we can always look at the earliest ones first:
                                     subject.datetimeRetrieved = iso8601String;
                                 }

                                 [callbackBlock invoke];
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
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    // Get the FetchRequest from our data model,
    // and use the same sort order as the ListViewController:
    // We have to copy it so we can set a sort order (sortDescriptors).
    // There doesn't seem to be a way to set the sort order in the data model GUI editor.
    NSFetchRequest *fetchRequest = [[self.managedObjectModel fetchRequestTemplateForName:@"fetchRequestDoneNotUploaded"] copy];
    [Utils fetchRequestSortByDateTimeRetrieved:fetchRequest];

    //Get more items from the server if necessary:
    NSError *error = nil; //TODO: Check this.
    NSArray *results = [[appDelegate managedObjectContext]
                        executeFetchRequest:fetchRequest
                        error:&error];
    for (ZooniverseSubject *subject in results) {
        ZooniverseClassification *classification = subject.classification;

        for (ZooniverseClassificationAnswer *answer in classification.answers) {
            //TODO: Actually upload
            NSLog(@"debug: answer: %@", answer.answerId);
        }

        subject.uploaded = YES;
    }


}

@end
