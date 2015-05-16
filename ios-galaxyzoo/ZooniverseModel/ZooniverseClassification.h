//
//  ZooniverseClassification.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 16/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ZooniverseClassificationAnswer, ZooniverseClassificationCheckbox, ZooniverseSubject;

@interface ZooniverseClassification : NSManagedObject

@property (nonatomic) BOOL favorite;
@property (nonatomic, retain) NSOrderedSet *answers;
@property (nonatomic, retain) ZooniverseSubject *subject;
@property (nonatomic, retain) NSOrderedSet *checkboxes;
@end

@interface ZooniverseClassification (CoreDataGeneratedAccessors)

- (void)insertObject:(ZooniverseClassificationAnswer *)value inAnswersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAnswersAtIndex:(NSUInteger)idx;
- (void)insertAnswers:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAnswersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAnswersAtIndex:(NSUInteger)idx withObject:(ZooniverseClassificationAnswer *)value;
- (void)replaceAnswersAtIndexes:(NSIndexSet *)indexes withAnswers:(NSArray *)values;
- (void)addAnswersObject:(ZooniverseClassificationAnswer *)value;
- (void)removeAnswersObject:(ZooniverseClassificationAnswer *)value;
- (void)addAnswers:(NSOrderedSet *)values;
- (void)removeAnswers:(NSOrderedSet *)values;
- (void)insertObject:(ZooniverseClassificationCheckbox *)value inCheckboxesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCheckboxesAtIndex:(NSUInteger)idx;
- (void)insertCheckboxes:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCheckboxesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCheckboxesAtIndex:(NSUInteger)idx withObject:(ZooniverseClassificationCheckbox *)value;
- (void)replaceCheckboxesAtIndexes:(NSIndexSet *)indexes withCheckboxes:(NSArray *)values;
- (void)addCheckboxesObject:(ZooniverseClassificationCheckbox *)value;
- (void)removeCheckboxesObject:(ZooniverseClassificationCheckbox *)value;
- (void)addCheckboxes:(NSOrderedSet *)values;
- (void)removeCheckboxes:(NSOrderedSet *)values;
@end
