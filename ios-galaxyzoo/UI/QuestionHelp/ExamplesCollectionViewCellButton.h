//
//  ExamplesCollectionViewCellButton.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 15/06/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DecisionTreeQuestionAnswer.h"

@interface ExamplesCollectionViewCellButton : UIButton


@property (nonatomic, strong) DecisionTreeQuestionAnswer *answer;
@property (nonatomic) NSInteger exampleIndex;

@end
