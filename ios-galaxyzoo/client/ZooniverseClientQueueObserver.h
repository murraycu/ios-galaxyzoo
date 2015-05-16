//
//  ZooniverseClientQueueObserver.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 16/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZooniverseClientQueueObserver : NSObject

typedef void (^ ZooniverseClientQueueObserverQueryDoneBlock)();

- (ZooniverseClientQueueObserver *) init;

@property (nonatomic, strong) ZooniverseClientQueueObserverQueryDoneBlock callbackBlock;



@end
