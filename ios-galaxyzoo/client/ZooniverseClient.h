//
//  ZooniverseClient.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 01/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "ZooniverseSubject.h"

@class ZooniverseClientImageDownload;
@class ZooniverseClientImageDownloadSet;


@interface ZooniverseClient : NSObject

- (instancetype) init NS_DESIGNATED_INITIALIZER;

typedef void (^ZooniverseClientDoneBlock)(void);

//This gets new subjects from the server asynchronously,
//calling callbackBlock when it has finished.
- (void)querySubjects:(NSUInteger)count
         withCallback:(ZooniverseClientDoneBlock)callbackBlock;

- (void)downloadMinimumSubjects:(ZooniverseClientDoneBlock)callbackBlock;

/* Download any images that have previously failed to download. */
- (void)downloadMissingImages:(ZooniverseClientDoneBlock)callbackBlock;
- (void)uploadOutstandingClassifications:(ZooniverseClientDoneBlock)callbackBlock;
- (void)removeOldSubjects:(ZooniverseClientDoneBlock)callbackBlock;

/* Abandon any subjects whose images have been deleted from the cache by the system. */
- (void)checkImagesStillExist:(ZooniverseClientDoneBlock)callbackBlock;

- (void)abandonSubjectInMainThread:(ZooniverseSubject *)subject
      withCoreDataSave:(BOOL)coreDataSave;

+ (NSString *)fullLocalImagePath:(NSString *)partialLocalPath;

+ (BOOL)networkIsConnected;
+ (BOOL)networkIsConnected:(BOOL*)noWiFi;

//The array should contain:
//(NSString *)strTaskId
//permanentPath:(NSString *)permanentPath
- (void)onImageDownloadedAndMoved:(NSArray*)array;

@end


