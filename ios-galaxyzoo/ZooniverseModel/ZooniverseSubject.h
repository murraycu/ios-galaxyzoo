//
//  ZooniverseRkSubject.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 01/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ZooniverseSubject : NSManagedObject

//From the server, via the JSON REST response:
@property (nonatomic, copy) NSString *subjectId;
@property (nonatomic, copy) NSString *zooniverseId;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *locationStandardRemote;
@property (nonatomic, copy) NSString *locationInvertedRemote;
@property (nonatomic, copy) NSString *locationThumbnailRemote;

//Others:
@property (nonatomic) BOOL done;
@property (nonatomic) BOOL uploaded;
@property (nonatomic) BOOL favorite;
@property (nonatomic, copy) NSString *datetimeDone;

@end
