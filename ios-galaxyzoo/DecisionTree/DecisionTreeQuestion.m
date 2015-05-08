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
    self.questionId = questionId;
    self.title = title;
    self.text = text;
    self.help = help;
    self.answers = answers;
    self.checkboxes = checkboxes;
    return self;
}

@end
