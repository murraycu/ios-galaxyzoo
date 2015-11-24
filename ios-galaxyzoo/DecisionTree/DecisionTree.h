//
//  DecisionTree.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DecisionTreeQuestion.h"
#import "DecisionTreeDiscussQuestion.h"

//TODO: Separate the parser?
@interface DecisionTree : NSObject

- (instancetype)init NS_DESIGNATED_INITIALIZER;

/*!
 * @param url The XMl file containing the decision tree.
 * @param translationUrl A JSON file containing translations of the question and answers,
 *                       such as https://github.com/zooniverse/Galaxy-Zoo/blob/master/public/locales/es.json
 * @param discussQuestion The question that ask the user whether they want to discuss the subject with other people.
 */
- (instancetype)initWithUrl:(NSURL *)url
         withTranslationUrl:(NSURL *)translationUrl
   withDiscussQuestion:(DecisionTreeDiscussQuestion *)discussQuestion;

@property (nonatomic, copy, readonly) NSString *firstQuestionId;
@property (nonatomic, copy, readonly) DecisionTreeDiscussQuestion *discussQuestion;



//TODO: Create a read-only property instead?
@property (NS_NONATOMIC_IOSONLY, getter=getAllQuestions, readonly, copy) NSArray *allQuestions;

- (DecisionTreeQuestion *) getQuestion:(NSString *)questionId;

- (DecisionTreeQuestion *) getNextQuestion:(NSString *)questionId forAnswer:(NSString *)answerId;

- (void)addQuestion:(DecisionTreeQuestion *)question;

- (BOOL)isDiscussQuestion:(NSString *)questionId;
- (BOOL)isDiscussQuestionYesAnswer:(NSString *)answerId;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *discussQuestionNoAnswerId;

@end
