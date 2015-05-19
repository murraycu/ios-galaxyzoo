//
//  ZooniverseClassificationCheckbox.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 19/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ZooniverseClassificationQuestion;

@interface ZooniverseClassificationCheckbox : NSManagedObject

@property (nonatomic, retain) NSString * checkboxId;
@property (nonatomic, retain) ZooniverseClassificationQuestion *classificationQuestion;

@end
