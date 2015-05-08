//
//  DecisionTreeQuestionAnswer.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "DecisionTreeQuestionAnswer.h"

@implementation DecisionTreeQuestionAnswer

- (DecisionTreeQuestionAnswer *)init:(NSString *)answerId
                                icon:(NSString *)icon
                       examplesCount:(NSUInteger)examplesCount
                                text:(NSString *)text
                   leadsToQuestionId:(NSString *)leadsToQuestionId {
    self = [super init:answerId
                  icon:icon
         examplesCount:examplesCount
                  text:text];
    self.leadsToQuestionId = leadsToQuestionId;
    
    return self;
}

@end
