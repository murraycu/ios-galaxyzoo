//
//  DecisionTree.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "DecisionTree.h"
#import "DecisionTreeParser.h"
#import <Foundation/Foundation.h>

@interface DecisionTree () {
    NSMutableDictionary *_questions;

    //Make this writable, so we can change it in our implementation:
}

//We redeclare these properties here, without readonly,
//so we can set them at least once;
@property (nonatomic, copy) NSString *firstQuestionId;
@property (nonatomic, copy) DecisionTreeDiscussQuestion *discussQuestion;

@end

@implementation DecisionTree

- (instancetype)init
{
    return [super init];
}


- (void)readJsonAnswers:(DecisionTreeQuestion *)question
            withAnswers:(NSDictionary *)jsonAnswers
{
    for (NSString *answerId in jsonAnswers) {
        NSString *value = [jsonAnswers objectForKey:answerId];

        DecisionTreeQuestionAnswer *answer = [question answerForId:answerId];
        answer.text = value;
    }
}

- (void)readJsonCheckboxes:(DecisionTreeQuestion *)question
               withAnswers:(NSDictionary *)jsonCheckboxes
{
    for (NSString *answerId in jsonCheckboxes) {
        NSString *value = [jsonCheckboxes objectForKey:answerId];

        DecisionTreeQuestionCheckbox *checkbox = [question checkboxForId:answerId];
        checkbox.text = value;
    }
}

- (void)readJsonQuestion:(DecisionTreeQuestion *)question
              withValues:(NSDictionary *)jsonQuestion
{
    for (NSString *name in jsonQuestion) {
        if ([name isEqualToString:@"text"]) {
            NSString *value = [jsonQuestion objectForKey:name];
            [question setText:value];
        } else if ([name isEqualToString:@"title"]) {
            NSString *value = [jsonQuestion objectForKey:name];
            [question setTitle:value];
        } else if ([name isEqualToString:@"help"]) {
            NSString *value = [jsonQuestion objectForKey:name];
            [question setHelp:value];
        } else if ([name isEqualToString:@"answers"]) {
            NSDictionary *jsonAnswers = [jsonQuestion objectForKey:name];
            [self readJsonAnswers:question
                      withAnswers:jsonAnswers];
        } else if ([name isEqualToString:@"checkboxes"]) {
            NSDictionary *jsonCheckboxes = [jsonQuestion objectForKey:name];
            [self readJsonCheckboxes:question
                      withAnswers:jsonCheckboxes];
        }
    }

}

- (BOOL)readJsonQuestions:(NSDictionary *)jsonQuestions
{
    for (NSString *questionId in jsonQuestions) {
        DecisionTreeQuestion *question = [self getQuestion:questionId];
        if (question == nil) {
            continue;
        }

        [self readJsonQuestion:question
                    withValues:[jsonQuestions objectForKey:questionId]];
    }

    return YES;
}

- (BOOL)loadTranslation:(NSURL *)translationUrl
{
    NSInputStream *inputStreamTranslations = [NSInputStream inputStreamWithURL:translationUrl];
    if (inputStreamTranslations == nil) {
        NSLog(@"DecisionTree:initWithUrl(): Could not open an input stream for the translation URL.");
        return NO;
    }

    [inputStreamTranslations open];
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithStream:inputStreamTranslations
                                                               options:0
                                                                 error:&error];
    [inputStreamTranslations close];
    if (error) {
        NSLog(@"DecisionTree:initWithUrl(): NSJSONSerialization failed: %@", error);
        return NO;
    }

    //We ignore the "zooniverse" and "quiz_questions" objects.
    NSDictionary *jsonQuestions = [jsonDict objectForKey:@"questions"];
    return [self readJsonQuestions:jsonQuestions];
}

- (instancetype)initWithUrl:(NSURL *)url
         withTranslationUrl:(NSURL *)translationUrl
   withDiscussQuestion:(DecisionTreeDiscussQuestion *)discussQuestion;
{
    self = [self init];

    _questions = [[NSMutableDictionary alloc] init];

    //TODO: Use filename.
    //NSString *fullPath = @"Assets/DecisionTrees";
    //fullPath = [fullPath stringByAppendingString:filename];

    DecisionTreeParser *parser = [[DecisionTreeParser alloc]initWithUrlIntoTree:url
                                                        intoTree:self];
    if (![parser parse]) {
        NSLog(@"DecisionTree:initWithUrl(): DecisionTreeParser.parse() failed: %@", parser.parserError);
        return nil;
    }

    if (![self loadTranslation:translationUrl]) {
        NSLog(@"DecisionTree:initWithUrl(): Could not load decision tree translations: %@", translationUrl);
        //Continue, because this should not be a fatal error.
    }

    self.discussQuestion = discussQuestion;

    return self;
}

- (NSArray *)getAllQuestions {

    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:_questions.count];

    for (NSString *questionId in _questions) {
        //Apparently it's (now) OK to do this extra lookup due to some optimization:
        //See http://stackoverflow.com/a/12454766/1123654
        DecisionTreeQuestion *question = _questions[questionId];
        [result addObject:question];
    }

    return result;
}

- (DecisionTreeQuestion *) getQuestion:(NSString *)questionId {
    return _questions[questionId];
}

- (DecisionTreeQuestion *) getNextQuestion:(NSString *)questionId forAnswer:(NSString *)answerId {
    DecisionTreeQuestion *current = [self getQuestion:questionId];
    for (DecisionTreeQuestionAnswer *answer in current.answers) {
        if ([answer.answerId isEqualToString:answerId]) {
            NSString *leadsToQuestionId = answer.leadsToQuestionId;
            return [self getQuestion:leadsToQuestionId];
        }
    }

    return nil;
}

- (void)addQuestion:(DecisionTreeQuestion *)question {
    _questions[question.questionId] = question;

    if (!self.firstQuestionId) {
        self.firstQuestionId = question.questionId;
    }
}


- (BOOL)isDiscussQuestion:(NSString *)questionId {
    return [self.discussQuestion.questionId isEqualToString:questionId];
}

- (BOOL)isDiscussQuestionYesAnswer:(NSString *)answerId {
    return [self.discussQuestion.yesAnswerId isEqualToString:answerId];
}

- (NSString *)discussQuestionNoAnswerId {
    return self.discussQuestion.noAnswerId;
}

@end
