//
//  QuestionsCollectionView.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 11/06/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../../DecisionTree/DecisionTreeQuestion.h"
#import "../../DecisionTree/DecisionTreeQuestionAnswer.h"
#import "../../DecisionTree/DecisionTreeQuestionCheckbox.h"


@interface QuestionAnswersCollectionView : UICollectionView <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) DecisionTreeQuestion *question;

typedef void (^ ZooniverseQuestionAnswersCollectionViewAnswerClickedBlock)(DecisionTreeQuestionAnswer *answer);
typedef void (^ ZooniverseQuestionAnswersCollectionViewCheckboxClickedBlock)(DecisionTreeQuestionCheckbox *checkbox, BOOL selected);

- (void)setAnswerClickedCallback:(ZooniverseQuestionAnswersCollectionViewAnswerClickedBlock)callbackBlockAnswerClicked
     withCheckBoxClickedCallback:(ZooniverseQuestionAnswersCollectionViewCheckboxClickedBlock)callbackBlockCheckboxClicked;

@end
