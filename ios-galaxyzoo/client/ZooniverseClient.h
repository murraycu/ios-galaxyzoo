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

- (ZooniverseClient *) init;

typedef void (^ ZooniverseClientQueryDoneBlock)();

//This gets new subjects from the server asynchronously,
//calling callbackBlock when it has finished.
- (void)querySubjects:(NSUInteger)count
         withCallback:(ZooniverseClientQueryDoneBlock)callbackBlock;

- (void)uploadClassifications;

- (void)abandonSubject:(ZooniverseSubject *)subject;


//The array should contain:
//(NSString *)strTaskId
//permanentPath:(NSString *)permanentPath
- (void)onImageDownloadedAndMoved:(NSArray*)array;

@end


