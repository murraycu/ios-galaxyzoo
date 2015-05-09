//
//  ZooniverseClassification.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 09/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ZooniverseClassificationAnswer, ZooniverseSubject;

@interface ZooniverseClassification : NSManagedObject

@property (nonatomic) BOOL favorite;
@property (nonatomic, retain) ZooniverseSubject *subject;
@property (nonatomic, retain) NSOrderedSet *answers;
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
@end
