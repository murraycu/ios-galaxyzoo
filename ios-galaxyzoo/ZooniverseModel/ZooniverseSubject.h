//
//  ZooniverseSubject.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 17/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ZooniverseClassification;

@interface ZooniverseSubject : NSManagedObject

@property (nonatomic, retain) NSString * datetimeDone;
@property (nonatomic, retain) NSString * datetimeRetrieved;
@property (nonatomic) BOOL done;
@property (nonatomic) BOOL favorite;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * locationInverted;
@property (nonatomic) BOOL locationInvertedDownloaded;
@property (nonatomic, retain) NSString * locationInvertedRemote;
@property (nonatomic, retain) NSString * locationStandard;
@property (nonatomic) BOOL locationStandardDownloaded;
@property (nonatomic, retain) NSString * locationStandardRemote;
@property (nonatomic, retain) NSString * locationThumbnail;
@property (nonatomic) BOOL locationThumbnailDownloaded;
@property (nonatomic, retain) NSString * locationThumbnailRemote;
@property (nonatomic, retain) NSString * subjectId;
@property (nonatomic) BOOL uploaded;
@property (nonatomic, retain) NSString * zooniverseId;
@property (nonatomic, retain) ZooniverseClassification *classification;

@end
