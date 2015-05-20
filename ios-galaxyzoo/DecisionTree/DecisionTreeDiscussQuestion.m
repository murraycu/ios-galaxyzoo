//
//  DecisionTreeDiscussQuestion.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "DecisionTreeDiscussQuestion.h"

@implementation DecisionTreeDiscussQuestion

- (DecisionTreeDiscussQuestion *)init:(NSString *)questionId yesAnswerId:(NSString *)yesAnswerId noAnswerId:(NSString *)noAnswerId {
    self = [super init];

    self.questionId = questionId;
    self.yesAnswerId = yesAnswerId;
    self.noAnswerId = noAnswerId;

    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    DecisionTreeDiscussQuestion *copy = [[[self class] allocWithZone: zone] init];
    copy.questionId = self.questionId;
    copy.yesAnswerId = self.yesAnswerId;
    copy.noAnswerId = self.noAnswerId;

    return copy;
}

@end
