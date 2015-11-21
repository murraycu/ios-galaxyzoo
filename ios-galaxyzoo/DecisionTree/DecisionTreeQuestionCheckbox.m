//
//  DecisionTreeCheckbox.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "DecisionTreeQuestionCheckbox.h"

@implementation DecisionTreeQuestionCheckbox

- (instancetype )init {
    return [super init];
}

- (instancetype )initWithDetails:(NSString *)answerId
                                  icon:(NSString *)icon
                         examplesCount:(NSUInteger)examplesCount
                                  text:(NSString *)text {
    self = [super initWithDetails:answerId
                  icon:icon
         examplesCount:examplesCount
                  text:text];
    return self;
}

@end
