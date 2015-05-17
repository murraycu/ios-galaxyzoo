//
//  ZooniverseClassificationQuestion.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 17/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ZooniverseClassification, ZooniverseClassificationAnswer, ZooniverseClassificationCheckbox;

@interface ZooniverseClassificationQuestion : NSManagedObject

@property (nonatomic, retain) ZooniverseClassificationAnswer *answer;
@property (nonatomic, retain) NSSet *checkboxes;
@property (nonatomic, retain) ZooniverseClassification *classification;
@end

@interface ZooniverseClassificationQuestion (CoreDataGeneratedAccessors)

- (void)addCheckboxesObject:(ZooniverseClassificationCheckbox *)value;
- (void)removeCheckboxesObject:(ZooniverseClassificationCheckbox *)value;
- (void)addCheckboxes:(NSSet *)values;
- (void)removeCheckboxes:(NSSet *)values;

@end
