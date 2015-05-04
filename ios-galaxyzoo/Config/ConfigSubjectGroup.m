//
//  ConfigSubjectGroup.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "ConfigSubjectGroup.h"

@implementation ConfigSubjectGroup

- (ConfigSubjectGroup *)init:(NSString *)filename useForNewQueries:(BOOL)useForNewQueries discussQuestion:(DecisionTreeDiscussQuestion *)discussQuestion {
    self = [super init];
    
    self.filename = filename;
    self.useForNewQueries = useForNewQueries;
    self.discussQuestion = discussQuestion;
    
    return self;
}

@end
