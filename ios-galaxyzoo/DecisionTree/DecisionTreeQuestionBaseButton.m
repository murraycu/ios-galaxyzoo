//
//  DecisionTreeBaseButton.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecisionTreeQuestionBaseButton.h"

@implementation DecisionTreeQuestionBaseButton

- (instancetype)init {
    return [super init];
}

- (instancetype)initWithDetails:(NSString *)answerId
                                    icon:(NSString *)icon
                           examplesCount:(NSUInteger)examplesCount
                                    text:(NSString *)text {
    self = [super init];
    self.answerId = answerId;
    self.icon = icon;
    self.examplesCount = examplesCount;
    self.text = text;
    return self;
}

@end
