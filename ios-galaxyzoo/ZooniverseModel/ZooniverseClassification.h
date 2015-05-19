//
//  ZooniverseClassification.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 19/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ZooniverseClassificationQuestion, ZooniverseSubject;

@interface ZooniverseClassification : NSManagedObject

@property (nonatomic) BOOL favorite;
@property (nonatomic, retain) NSSet *classificationQuestions;
@property (nonatomic, retain) ZooniverseSubject *subject;
@end

@interface ZooniverseClassification (CoreDataGeneratedAccessors)

- (void)addClassificationQuestionsObject:(ZooniverseClassificationQuestion *)value;
- (void)removeClassificationQuestionsObject:(ZooniverseClassificationQuestion *)value;
- (void)addClassificationQuestions:(NSSet *)values;
- (void)removeClassificationQuestions:(NSSet *)values;

@end
