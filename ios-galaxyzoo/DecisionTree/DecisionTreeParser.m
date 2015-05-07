//
//  DecisionTreeParser.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 05/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "DecisionTreeParser.h"
#import "DecisionTreeQuestionAnswer.h"
#import "DecisionTreeQuestionCheckbox.h"

static NSString *TAG_QUESTION = @"question";
static NSString *TAG_ANSWER = @"answer";
static NSString *TAG_CHECKBOX = @"checkbox";
static NSString *TAG_TITLE = @"title";
static NSString *TAG_HELP = @"help";
static NSString *TAG_TEXT = @"text";


@interface DecisionTreeParser () {
    
    DecisionTree *_decisionTree;
    
    NSMutableArray *_answersInProgress; //Of DecisionTreeQuestionAnswer
    NSMutableArray *_checkboxesInProgress; //Of DecisionTreeQuestionCheckbox
    
    NSString *_questionIdInProgress;
    NSString *_questionTitleInProgress;
    NSString *_questionTextInProgress;
    NSString *_questionHelpInProgress;
    
    NSString *_answerIdInProgress;
    NSString *_answerIconInProgress;
    NSUInteger _answerExamplesCountInProgress;
    NSString *_answerLeadsToQuestionIdInProgress;
    NSString *_answerTextInProgress;
    
    NSMutableString *_titleInProgress;
    NSMutableString *_helpInProgress;
    NSMutableString *_textInProgress;
}

- (void)clearQuestionInProgress;
- (void)clearAnswerInProgress;
- (void)parseBaseButton:(NSDictionary *)attributeDict;
- (void)clearChildTextInProgress;

@end

@implementation DecisionTreeParser

- (DecisionTreeParser *)init:(NSURL *)url intoTree:(DecisionTree *)intoTree {
    
    self = [super initWithContentsOfURL:url];
    
    _decisionTree = intoTree;
    _answersInProgress = [[NSMutableArray alloc] init];
    _checkboxesInProgress = [[NSMutableArray alloc] init];

    [self setDelegate:self];
    
    return self;
}

- (void)clearQuestionInProgress {
    _questionIdInProgress = nil;
    _questionTitleInProgress = nil;
    _questionTextInProgress = nil;
    _questionHelpInProgress = nil;
    [_answersInProgress removeAllObjects];
    [_checkboxesInProgress removeAllObjects];
}

- (void)clearAnswerInProgress {
    _answerIdInProgress = nil;
    _answerIconInProgress = nil;
    _answerExamplesCountInProgress = 0;
    _answerLeadsToQuestionIdInProgress = nil;
    _answerTextInProgress = nil;
}

- (void)clearChildTextInProgress {
    _titleInProgress = nil;
    _textInProgress = nil;
    _helpInProgress = nil;
}

- (void)parseBaseButton:(NSDictionary *)attributeDict {
    _answerIdInProgress = [attributeDict objectForKey:@"id"];
    _answerIconInProgress = [attributeDict objectForKey:@"icon"];
    
    NSString *strCount = [attributeDict objectForKey:@"examplesCount"];
    _answerExamplesCountInProgress = [strCount integerValue];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    //NSLog(@"Did start element");
    if ( [elementName isEqualToString:TAG_QUESTION]) {
        [self clearQuestionInProgress];
        _questionIdInProgress = [attributeDict objectForKey:@"id"];
    } else if ( [elementName isEqualToString:TAG_ANSWER]) {
        [self clearAnswerInProgress];
        [self parseBaseButton:attributeDict];
        _answerLeadsToQuestionIdInProgress = [attributeDict objectForKey:@"leadsTo"];
    } else if ( [elementName isEqualToString:TAG_CHECKBOX]) {
        [self clearAnswerInProgress];
        [self parseBaseButton:attributeDict];
    } else if ( [elementName isEqualToString:TAG_TITLE]) {
        [self clearChildTextInProgress];
        _titleInProgress = [[NSMutableString alloc] init];
    }  else if ( [elementName isEqualToString:TAG_HELP]) {
        [self clearChildTextInProgress];
        _helpInProgress = [[NSMutableString alloc] init];
    } else if ( [elementName isEqualToString:TAG_TEXT]) {
        [self clearChildTextInProgress];
        _textInProgress = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ( [elementName isEqualToString:TAG_QUESTION]) {
        DecisionTreeQuestion *question = ([[DecisionTreeQuestion alloc] init:_questionIdInProgress
                                                                       title:_questionTitleInProgress
                                                                        text:_questionTextInProgress
                                                                        help:_questionHelpInProgress
                                                                     answers:_answersInProgress
                                                                  checkboxes:_checkboxesInProgress]);
        [_decisionTree addQuestion:question];
        [self clearQuestionInProgress];
    } else if ( [elementName isEqualToString:TAG_ANSWER]) {
        DecisionTreeQuestionAnswer *answer = [[DecisionTreeQuestionAnswer alloc] init:_answerIdInProgress
                                                                                 icon:_answerIconInProgress
                                                                        examplesCount:_answerExamplesCountInProgress
                                                                                 text:_answerTextInProgress
                                                                    leadsToQuestionId:_answerLeadsToQuestionIdInProgress];
        [_answersInProgress addObject:answer];
        [self clearAnswerInProgress];
    } else if ( [elementName isEqualToString:TAG_CHECKBOX]) {
        DecisionTreeQuestionCheckbox *checkbox = [[DecisionTreeQuestionCheckbox alloc] init:_answerIdInProgress
                                                                                       icon:_answerIconInProgress
                                                                              examplesCount:_answerExamplesCountInProgress
                                                                                       text:_answerTextInProgress];
        [_checkboxesInProgress addObject:checkbox];
        [self clearAnswerInProgress];
    } else if ( [elementName isEqualToString:TAG_TITLE]) {
        //Only the questions have titles:
        _questionTitleInProgress = _titleInProgress;

        [self clearChildTextInProgress];
    } else if ( [elementName isEqualToString:TAG_HELP]) {
        //Only the questions have help:
        _questionHelpInProgress = _helpInProgress;
        
        [self clearChildTextInProgress];
    } else if ( [elementName isEqualToString:TAG_TEXT]) {
        // Use _textInProgress for a child answer,
        // or the parent question, depending on whether
        // we are currently parsing an answer:
        if (_answerIdInProgress) {
            _answerTextInProgress = _textInProgress;
        } else if(_questionIdInProgress) {
            _questionTextInProgress = _textInProgress;
        }

        [self clearChildTextInProgress];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (_titleInProgress) {
        [_titleInProgress appendString:string];
    } else if(_textInProgress) {
        [_textInProgress appendString:string];
    } else if(_helpInProgress) {
        [_helpInProgress appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"Value %@", [parseError userInfo]);
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError {
    NSLog(@"Value %@", [validError userInfo]);
}

@end
