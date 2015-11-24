//
//  DecisionTreeQuestion.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "DecisionTreeQuestionAnswer.h"
#import "DecisionTreeQuestionCheckbox.h"
#import <Foundation/Foundation.h>

@interface DecisionTreeQuestion : NSObject

@property (nonatomic, copy) NSString *questionId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *help;
@property (nonatomic, copy) NSArray *answers; //of DecisionTreeAnswer
@property (nonatomic, copy) NSArray *checkboxes; //of DecisionTreeCheckbox

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithDetails:(NSString *)questionId
                         title:(NSString *)title
                          text:(NSString *)text
                          help:(NSString *)help
                       answers:(NSArray *)answers
                    checkboxes:(NSArray *)checkboxes;

- (DecisionTreeQuestionAnswer*) answerForId:(NSString *)answerId;
- (DecisionTreeQuestionCheckbox*) checkboxForId:(NSString *)answerId;



@end
