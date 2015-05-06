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
    //TODO: Make this readonly:
    @property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

- (ZooniverseClient *) init;
- (void)querySubjects;

@end


