//
//  ZooniverseSubject.h
//
//
//  Created by Murray Cumming on 11/05/2015.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ZooniverseClassification;

@interface ZooniverseSubject : NSManagedObject

@property (nonatomic, retain) NSString * datetimeDone;
@property (nonatomic) BOOL done;
@property (nonatomic) BOOL favorite;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * locationInvertedRemote;
@property (nonatomic, retain) NSString * locationStandardRemote;
@property (nonatomic, retain) NSString * locationThumbnailRemote;
@property (nonatomic, retain) NSString * subjectId;
@property (nonatomic) BOOL uploaded;
@property (nonatomic, retain) NSString * zooniverseId;
@property (nonatomic, retain) NSString * datetimeRetrieved;
@property (nonatomic, retain) ZooniverseClassification *classification;

@end
