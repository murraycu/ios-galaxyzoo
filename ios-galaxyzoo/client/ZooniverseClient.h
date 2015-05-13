//
//  ZooniverseClient.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 01/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@interface ZooniverseClient : NSObject

- (ZooniverseClient *) init;

typedef void (^ QueryDoneBlock)();

//This gets new subjects from the server asynchronously,
//calling callbackBlock when it has finished.
- (void)querySubjects:(NSUInteger)count
         withCallback:(QueryDoneBlock)callbackBlock;

- (void)uploadClassifications;

@end


