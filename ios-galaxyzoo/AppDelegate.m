//
//  AppDelegate.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 01/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "AppDelegate.h"
#import "Config.h"
#import <SSKeychain.h>

@interface AppDelegate ()

@property(nonatomic)BOOL regularWorkInProgress;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    // Register the preference defaults early:
    [self registerDefaultsFromSettingsBundle];

    //Regularly sync with with server:
    [NSTimer scheduledTimerWithTimeInterval:10.0
                                     target:self
                                   selector:@selector(doRegularWork)
                                   userInfo:nil
                                    repeats:YES];

    return YES;
}

- (void)registerDefaultsFromSettingsBundle {
    //Get the default values from the .plist file and tell the app to use them.
    //See http://stackoverflow.com/a/510329/1123654
    //TODO: Surely there's a simpler way?
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }

    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];

    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if (key) {
            NSObject *object = [prefSpecification objectForKey:@"DefaultValue"];
            if (object) {
                [defaultsToRegister setObject:object
                                       forKey:key];
            }
        }
    }

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Core Data stack

//TODO: Remove these? They shouldn't be necessary now.
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
//@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize rkObjectManager = _rkObjectManager;
@synthesize rkManagedObjectStore = _rkManagedObjectStore;

@synthesize zooniverseClient = _zooniverseClient;

- (ZooniverseClient*)zooniverseClient {
    if (_zooniverseClient != nil) {
        return _zooniverseClient;
    }

    _zooniverseClient = [[ZooniverseClient alloc] init];
    return _zooniverseClient;
}


- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.murrayc.Model" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }

    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    //NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ZooniverseModel" withExtension:@"momd"];
    //_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

/*
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    // Create the coordinator and store

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ZooniverseModel.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStoreCoordinator;
}
*/

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    /*
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;

    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    */

    _managedObjectContext = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    return _managedObjectContext;
}

- (RKManagedObjectStore *)rkManagedObjectStore {
    if (_rkManagedObjectStore != nil) {
        return _rkManagedObjectStore;
    }

    _rkManagedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:self.managedObjectModel];
    return _rkManagedObjectStore;
}

- (RKObjectManager *)rkObjectManager {
    if (_rkObjectManager != nil) {
        return _rkObjectManager;
    }

    // Initialize HTTPClient
    NSURL *baseURL = [NSURL URLWithString:[Config baseUrl]];
    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];

    // Set User-Agent:
    [client setDefaultHeader:@"User-Agent"
                       value:[Config userAgent]];


    //we want to work with JSON-Data
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];

    // Initialize RestKit
    _rkObjectManager = [[RKObjectManager alloc] initWithHTTPClient:client];

    // Connect the RestKit object manager to our Core Data model:
    _rkObjectManager.managedObjectStore = [self rkManagedObjectStore];

    return _rkObjectManager;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)onDownloadEnoughSubjectsDone {
    self.regularWorkInProgress = NO;
}

- (void)onDownloadMissingImagesDone {
    ZooniverseClient *client = self.zooniverseClient;
    [client downloadEnoughSubjects:^ {
        [self onDownloadEnoughSubjectsDone];
    }];

}

- (void)doRegularWork {
    //Don't start more tasks if they are already in progress:
    if (self.regularWorkInProgress) {
        return;
    }

    self.regularWorkInProgress = YES;

    ZooniverseClient *client = self.zooniverseClient;
    [client uploadClassifications];

    //Download any subjects' missing image,
    //and only then download extra subjects:
    [client downloadMissingImages:^ {
        [self onDownloadMissingImagesDone];
    }];
}

static NSString *const kKeyChainServiceName = @"zooniverse";
static NSString *const kKeyChainKeyName = @"name";
static NSString *const kKeyChainKeyApiKey = @"api_key";


+ (void)removAllSSKeychainAccounts {
    NSArray *accounts = [SSKeychain accountsForService:kKeyChainServiceName];

    for (NSDictionary *dict in accounts) {
        NSString *accountName = [dict objectForKey:kSSKeychainAccountKey];

        //This actually deletes the account, which we can check by
        //calling accountsForService again.
        [SSKeychain deletePasswordForService:kKeyChainServiceName
                                     account:accountName];
    }

    //accounts = [SSKeychain accountsForService:kKeyChainServiceName];
    //NSLog(@"debug: accounts count:%lu", (unsigned long)accounts.count);
}

+ (void)setLogin:(NSString *)username
          apiKey:(NSString *)apiKey {
    [AppDelegate removAllSSKeychainAccounts];

    [SSKeychain setPassword:apiKey
                 forService:kKeyChainServiceName
                    account:username];
}

+ (NSString *)loginUsername {
    NSArray *accounts = [SSKeychain accountsForService:kKeyChainServiceName];
    if (!accounts || accounts.count == 0) {
        return nil;
    }

    NSDictionary *dict = accounts[0];
    return [dict objectForKey:kSSKeychainAccountKey];
}

+ (NSString *)loginApiKey {
    NSString *username = [AppDelegate loginUsername];
    if (!username) {
        return nil;
    }

    return [SSKeychain passwordForService:kKeyChainServiceName
                                  account:username];
}

+ (NSInteger) preferenceDownloadInAdvance {
    return[[NSUserDefaults standardUserDefaults] integerForKey:@"preferenceDownloadInAdvance"];
}

+ (NSInteger) preferenceKeep {
    return[[NSUserDefaults standardUserDefaults] integerForKey:@"preferenceKeep"];
}

+ (BOOL) preferenceOfferDiscussion {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"preferenceOfferDiscussion"];
}

+ (BOOL) preferenceWiFiOnly {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"preferenceWiFiOnly"];
}

@end
