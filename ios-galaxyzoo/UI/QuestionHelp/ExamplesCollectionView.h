//
//  ExamplesCollectionView.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 11/06/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../../DecisionTree/DecisionTreeQuestion.h"

@interface ExamplesCollectionView : UICollectionView <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) DecisionTreeQuestion *question;

typedef void (^ ZooniverseExamplesCollectionViewClickedBlock)(DecisionTreeQuestionAnswer *answer, NSInteger exampleIndex);

- (void)setExampleClickedCallback:(ZooniverseExamplesCollectionViewClickedBlock)callbackBlockExampleClicked;

//TODO: Move this somewhere more general:
+(NSString *) getExampleIconName:(NSString *)questionId
                     forAnswerId:(NSString *)answerId
                 forExampleIndex:(NSInteger)exampleIndex;

@end
