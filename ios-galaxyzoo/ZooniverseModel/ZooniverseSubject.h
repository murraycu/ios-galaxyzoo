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

@property (nonatomic, copy) NSString *subjectId;
@property (nonatomic, copy) NSString *zooniverseId;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *locationStandard;
@property (nonatomic, copy) NSString *locationInverted;
@property (nonatomic, copy) NSString *locationThumbnail;



@end
