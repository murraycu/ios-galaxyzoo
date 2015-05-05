//
//  DecisionTreeCheckbox.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "DecisionTreeQuestionCheckbox.h"

@implementation DecisionTreeQuestionCheckbox

- (DecisionTreeQuestionCheckbox *)init:(NSString *)answerId
                                  icon:(NSString *)icon
                         examplesCount:(NSUInteger)examplesCount
                                  text:(NSString *)text {
    self = [super init:answerId
                  icon:icon
         examplesCount:examplesCount
                  text:text];
    return self;
}

@end
