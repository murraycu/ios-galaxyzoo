//
//  QuestionViewController.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 07/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "QuestionViewController.h"
#import "QuestionAnswersCollectionView.h"
#import "ClassifyViewControllerDelegate.h"
#import "AppDelegate.h"
#import "DecisionTree.h"
#import "DecisionTreeQuestionAnswer.h"
#import "../ZooniverseModel/ZooniverseClassification.h"
#import "../ZooniverseModel/ZooniverseClassificationQuestion.h"
#import "../ZooniverseModel/ZooniverseClassificationAnswer.h"
#import "../ZooniverseModel/ZooniverseClassificationCheckbox.h"
#import "../ZooniverseModel/ZooniverseSubject.h"
#import "Utils.h"
#import <UIKit/UIKit.h>

#import "Singleton.h"

@interface QuestionViewController () {
    ZooniverseClassification *_classificationInProgress;
    NSUInteger _questionSequence;

    __weak IBOutlet UISwitch *switchFavorite;
}

@property (nonatomic, copy) NSMutableSet *checkboxesSelected;

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelText;
@property (weak, nonatomic) IBOutlet QuestionAnswersCollectionView *collectionViewAnswers;


@end

@implementation QuestionViewController

- (void)initClassificationInProgress {
    //NSManagedObjects don't work (property setters don't work, for instance)
    //if they are just created with init:
    //  _classificationInProgress = [[ZooniverseClassification alloc] init];
    // and when we generate the classes, we don't have an init anyway.
    //
    //Note: This will be saved to the model, so we should remove it later if necessary:
    _classificationInProgress =
    (ZooniverseClassification *)[NSEntityDescription insertNewObjectForEntityForName:@"ZooniverseClassification"
                                                              inManagedObjectContext:[self managedObjectContext]];
    _questionSequence = 0;

    [self.checkboxesSelected removeAllObjects];
}

- (void)clearFavorite {
    //Clear the favorite switch:
    [switchFavorite setOn:NO
                 animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.collectionViewAnswers setAnswerClickedCallback:^(DecisionTreeQuestionAnswer *answer) {
        [self onAnswerClicked:answer];
    } withCheckBoxClickedCallback:^(DecisionTreeQuestionCheckbox *checkbox, BOOL selected) {
        [self onCheckboxClicked:checkbox
                       selected:selected];
    }];

    [self clearFavorite];

    [self initClassificationInProgress];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUI {
    self.labelTitle.text = _question.title;
    self.labelText.text = _question.text;

    self.collectionViewAnswers.question = self.question;
    [self.collectionViewAnswers reloadData];
}

- (void)setQuestion:(DecisionTreeQuestion *)question {
    _question = question;

    [self updateUI];
}

- (DecisionTree *)getDecisionTree {
    Singleton *singleton = [Singleton sharedSingleton];
    return [singleton getDecisionTree:self.subject.groupId];
}


-(void)onAnswerClicked:(DecisionTreeQuestionAnswer *)answer {
    [self storeAnswer:answer.answerId];

    //Handle the special Do You Want To Discuss this question:
    DecisionTree *decisionTree = [self getDecisionTree];
    if ([decisionTree isDiscussQuestion:_question.questionId] &&
        [decisionTree isDiscussQuestionYesAnswer:answer.answerId]) {
        [Utils openDiscussionPage:self.subject.zooniverseId];
    }
    
    [self showNextQuestion:_question.questionId
                  answerId:answer.answerId];
}

-(void)onCheckboxClicked:(DecisionTreeQuestionCheckbox *)checkbox
                                                selected:(BOOL)selected {
    if (selected) {
        [self.checkboxesSelected addObject:checkbox.answerId];
    } else {
        [self.checkboxesSelected removeObject:checkbox.answerId];
    }
}

- (void)showNextQuestion:(NSString *)questionId answerId:(NSString *)answerId {


    DecisionTree *decisionTree = [self getDecisionTree];
    _question =[decisionTree getNextQuestion:questionId
                                   forAnswer:answerId];
    if (_question == nil) {
        [self saveClassification];
        _question = [decisionTree getQuestion:decisionTree.firstQuestionId];

        [self clearFavorite];
    } else {
        //If the user doesn't want to see the "Do you want to discuss this?" question,
        //just skip it:
        if ([decisionTree isDiscussQuestion:_question.questionId] &&
            ![AppDelegate preferenceOfferDiscussion]) {

            //Add a No for the discussion questin without even showing the question:
            NSString *noAnswerId = [decisionTree discussQuestionNoAnswerId];
            [self storeAnswer:noAnswerId];

            [self showNextQuestion:_question.questionId
                          answerId:noAnswerId];
            return;
        }

        _questionSequence++;
    }

    [self updateUI];
}

-(void)saveAllCheckboxes:(ZooniverseClassificationQuestion *)classificationQuestion {
    for (NSString *checkboxId in self.checkboxesSelected) {
        ZooniverseClassificationCheckbox *classificationCheckbox = (ZooniverseClassificationCheckbox *)[NSEntityDescription insertNewObjectForEntityForName:@"ZooniverseClassificationCheckbox"
                                                                                                                                     inManagedObjectContext:[self managedObjectContext]];
        classificationCheckbox.checkboxId = checkboxId;

        classificationCheckbox.classificationQuestion = classificationQuestion;
    }

    [self.checkboxesSelected removeAllObjects];
}

- (void)saveClassification {
    self.subject.classification = _classificationInProgress;
    self.subject.favorite = switchFavorite.on;
    self.subject.done = YES;

    //Save the ZooniverseClassification and the Subject to disk:
    NSError *error = nil;
    [[self managedObjectContext] save:&error];  //saves the context to disk
    //TODO: Check error.


    //Tell the parent ViewController to start another subject:
    UIViewController <ClassifyViewControllerDelegate> *parent = (UIViewController <ClassifyViewControllerDelegate> *)self.parentViewController;
    [parent onClassificationFinished];

    [self initClassificationInProgress];
}

- (NSManagedObjectContext*)managedObjectContext {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
}

- (NSManagedObjectModel*)managedObjectModel {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectModel;
}

- (void)storeAnswer:(NSString *)answerId
{
    ZooniverseClassificationQuestion *classificationQuestion = (ZooniverseClassificationQuestion *)[NSEntityDescription insertNewObjectForEntityForName:@"ZooniverseClassificationQuestion"
                                                                                                                                 inManagedObjectContext:[self managedObjectContext]];
    classificationQuestion.questionId = _question.questionId;
    classificationQuestion.sequence = _questionSequence;

    ZooniverseClassificationAnswer *classificationAnswer = (ZooniverseClassificationAnswer *)[NSEntityDescription insertNewObjectForEntityForName:@"ZooniverseClassificationAnswer"
                                                                                                                           inManagedObjectContext:[self managedObjectContext]];

    // This results in an exception:
    // "'NSInvalidArgumentException', reason: '*** -[NSSet intersectsSet:]: set argument is not an NSSet'"
    // apparently because NSOrderedSet is not derived from NSSet.
    // This seems to be a well-known problem with ordered to-many relationships in Core Data.
    // See http://stackoverflow.com/questions/15993619/coredata-to-many-add-error
    // and http://stackoverflow.com/questions/7385439/exception-thrown-in-nsorderedset-generated-accessors
    //[classificationQuestion addAnswersObject:classificationAnswer];
    //This is the simple workaround:
    classificationQuestion.answer = classificationAnswer;

    classificationAnswer.answerId = answerId;

    [self saveAllCheckboxes:classificationQuestion];

    classificationQuestion.classification = _classificationInProgress;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
