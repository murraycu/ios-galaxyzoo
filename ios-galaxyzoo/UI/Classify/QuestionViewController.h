//
//  QuestionViewController.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 07/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../../ZooniverseModel/ZooniverseSubject.h"
#import "../../DecisionTree/DecisionTreeQuestion.h"

@interface QuestionViewController : UIViewController

@property (nonatomic, strong) ZooniverseSubject *subject;
@property (nonatomic, strong) DecisionTreeQuestion *question;
@property (nonatomic) BOOL favorite;

- (void) revertClassification;

@end
