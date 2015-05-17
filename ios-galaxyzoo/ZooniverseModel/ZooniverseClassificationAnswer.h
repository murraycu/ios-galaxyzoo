//
//  ZooniverseClassificationAnswer.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 17/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ZooniverseClassificationQuestion;

@interface ZooniverseClassificationAnswer : NSManagedObject

@property (nonatomic, retain) NSString * answerId;
@property (nonatomic, retain) ZooniverseClassificationQuestion *classificationQuestion;

@end
