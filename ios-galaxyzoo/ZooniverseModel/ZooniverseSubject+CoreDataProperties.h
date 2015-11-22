//
//  ZooniverseSubject+CoreDataProperties.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 22/11/2015.
//  Copyright © 2015 Murray Cumming. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ZooniverseSubject.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZooniverseSubject (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *datetimeDone;
@property (nullable, nonatomic, retain) NSString *datetimeRetrieved;
@property (nonatomic) BOOL done;
@property (nonatomic) BOOL favorite;
@property (nullable, nonatomic, retain) NSString *groupId;
@property (nullable, nonatomic, retain) NSString *locationInverted;
@property (nonatomic) BOOL locationInvertedDownloaded;
@property (nullable, nonatomic, retain) NSString *locationInvertedRemote;
@property (nullable, nonatomic, retain) NSString *locationStandard;
@property (nonatomic) BOOL locationStandardDownloaded;
@property (nullable, nonatomic, retain) NSString *locationStandardRemote;
@property (nullable, nonatomic, retain) NSString *locationThumbnail;
@property (nonatomic) BOOL locationThumbnailDownloaded;
@property (nullable, nonatomic, retain) NSString *locationThumbnailRemote;
@property (nullable, nonatomic, retain) NSString *subjectId;
@property (nonatomic) BOOL uploaded;
@property (nullable, nonatomic, retain) NSString *zooniverseId;
@property (nullable, nonatomic, retain) ZooniverseClassification *classification;

@end

NS_ASSUME_NONNULL_END
