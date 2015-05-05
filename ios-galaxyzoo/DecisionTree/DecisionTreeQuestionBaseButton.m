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

- (DecisionTreeQuestionBaseButton *)init:(NSString *)answerId
                                    icon:(NSString *)icon
                           examplesCount:(NSUInteger)examplesCount
                                    text:(NSString *)text {
    self = [super init];
    _answerId = answerId;
     _icon = icon;
     _examplesCount = examplesCount;
     _text = text;
    return self;
}

@end
