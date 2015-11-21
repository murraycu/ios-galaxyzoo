//
//  DecisionTreeQuestionAnswer.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "DecisionTreeQuestionAnswer.h"

@implementation DecisionTreeQuestionAnswer

- (instancetype)init {
    return [super init];
}


- (instancetype)initWithDetails:(NSString *)answerId
                           icon:(NSString *)icon
                  examplesCount:(NSUInteger)examplesCount
                           text:(NSString *)text {
    return [super initWithDetails:answerId
                             icon:icon
                    examplesCount:examplesCount
                             text:text];
}

- (instancetype)initWithDetails:(NSString *)answerId
                                icon:(NSString *)icon
                       examplesCount:(NSUInteger)examplesCount
                                text:(NSString *)text
                   leadsToQuestionId:(NSString *)leadsToQuestionId {
    self = [self initWithDetails:answerId
                  icon:icon
         examplesCount:examplesCount
                  text:text];
    self.leadsToQuestionId = leadsToQuestionId;

    return self;
}

@end
