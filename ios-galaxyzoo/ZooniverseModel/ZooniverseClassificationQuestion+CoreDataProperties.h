//
//  ZooniverseClassificationQuestion+CoreDataProperties.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 22/11/2015.
//  Copyright © 2015 Murray Cumming. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ZooniverseClassificationQuestion.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZooniverseClassificationQuestion (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *questionId;
@property (nonatomic) int16_t sequence;
@property (nullable, nonatomic, retain) ZooniverseClassificationAnswer *answer;
@property (nullable, nonatomic, retain) NSSet<ZooniverseClassificationCheckbox *> *checkboxes;
@property (nullable, nonatomic, retain) ZooniverseClassification *classification;

@end

@interface ZooniverseClassificationQuestion (CoreDataGeneratedAccessors)

- (void)addCheckboxesObject:(ZooniverseClassificationCheckbox *)value;
- (void)removeCheckboxesObject:(ZooniverseClassificationCheckbox *)value;
- (void)addCheckboxes:(NSSet<ZooniverseClassificationCheckbox *> *)values;
- (void)removeCheckboxes:(NSSet<ZooniverseClassificationCheckbox *> *)values;

@end

NS_ASSUME_NONNULL_END
