//
//  ConfigSubjectGroup.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecisionTreeDiscussQuestion.h"

@interface ConfigSubjectGroup : NSObject

@property (nonatomic, copy) NSString *filename;
@property (nonatomic) BOOL useForNewQueries;
@property (nonatomic, copy) DecisionTreeDiscussQuestion *discussQuestion;

- (ConfigSubjectGroup *)init:(NSString *)filename useForNewQueries:(BOOL)useForNewQueries discussQuestion:(DecisionTreeDiscussQuestion *)discussQuestion;

@end
