//
//  DecisionTreeQuestion.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "DecisionTreeQuestion.h"

@implementation DecisionTreeQuestion

- (DecisionTreeQuestion *)init:(NSString *)questionId
                         title:(NSString *)title
                          text:(NSString *)text
                          help:(NSString *)help
                       answers:(NSArray *)answers
                    checkboxes:(NSArray *)checkboxes {
    self = [super init];
    _questionId = questionId;
    _title = title;
    _text = text;
    _help = help;
    _answers = answers;
    _checkboxes = checkboxes;
    return self;
}

@end
