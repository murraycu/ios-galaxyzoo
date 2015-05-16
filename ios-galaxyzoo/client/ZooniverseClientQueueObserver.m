//
//  ZooniverseClientQueueObserver.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 16/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "ZooniverseClientQueueObserver.h"

@implementation ZooniverseClientQueueObserver

- (ZooniverseClientQueueObserver *) init;
{
    self = [super init];

    return self;
}

- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    NSOperationQueue *queue = object;
    if ([keyPath isEqualToString:@"operations"]) {
        NSLog(@"operations count:%lu", (unsigned long)queue.operationCount, nil);
        if (queue.operationCount == 0) {
            // Do something here when your queue has completed
            NSLog(@"queue has completed");

            dispatch_async( dispatch_get_main_queue(),
                           self.callbackBlock);
        }
    }
    else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

@end
