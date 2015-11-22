//
//  ZooniverseClassification+CoreDataProperties.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 22/11/2015.
//  Copyright © 2015 Murray Cumming. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ZooniverseClassification.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZooniverseClassification (CoreDataProperties)

@property (nonatomic) BOOL favorite;
@property (nullable, nonatomic, retain) NSOrderedSet<ZooniverseClassificationQuestion *> *classificationQuestions;
@property (nullable, nonatomic, retain) ZooniverseSubject *subject;

@end

@interface ZooniverseClassification (CoreDataGeneratedAccessors)

- (void)insertObject:(ZooniverseClassificationQuestion *)value inClassificationQuestionsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromClassificationQuestionsAtIndex:(NSUInteger)idx;
- (void)insertClassificationQuestions:(NSArray<ZooniverseClassificationQuestion *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeClassificationQuestionsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInClassificationQuestionsAtIndex:(NSUInteger)idx withObject:(ZooniverseClassificationQuestion *)value;
- (void)replaceClassificationQuestionsAtIndexes:(NSIndexSet *)indexes withClassificationQuestions:(NSArray<ZooniverseClassificationQuestion *> *)values;
- (void)addClassificationQuestionsObject:(ZooniverseClassificationQuestion *)value;
- (void)removeClassificationQuestionsObject:(ZooniverseClassificationQuestion *)value;
- (void)addClassificationQuestions:(NSOrderedSet<ZooniverseClassificationQuestion *> *)values;
- (void)removeClassificationQuestions:(NSOrderedSet<ZooniverseClassificationQuestion *> *)values;

@end

NS_ASSUME_NONNULL_END
