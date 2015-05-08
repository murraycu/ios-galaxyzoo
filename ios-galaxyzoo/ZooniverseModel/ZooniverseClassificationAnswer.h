//
//  ZooniverseClassificationAnswer.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 07/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ZooniverseClassificationAnswer : NSManagedObject

// The question that was answered.
@property (nonatomic, copy) NSString *questionId;

// The Answer that was chosen.
@property (nonatomic, copy) NSString *answerId;

// Any checkboxes that were selected before the answer (usually "Done") was chosen.
@property (nonatomic, copy) NSArray *checkboxIds; //TODO: Represent this in the Core Data model.

- (ZooniverseClassificationAnswer *)init:(NSString *)questionId
                                answerId:(NSString *)answerId
                             checkboxIds:(NSArray *)checkboxIds;

@end
