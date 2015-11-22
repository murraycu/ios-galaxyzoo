//
//  ZooniverseClassificationAnswer+CoreDataProperties.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 22/11/2015.
//  Copyright © 2015 Murray Cumming. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ZooniverseClassificationAnswer.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZooniverseClassificationAnswer (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *answerId;
@property (nullable, nonatomic, retain) ZooniverseClassificationQuestion *classificationQuestion;

@end

NS_ASSUME_NONNULL_END
