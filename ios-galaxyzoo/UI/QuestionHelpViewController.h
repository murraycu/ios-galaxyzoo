//
//  HelpViewController.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 12/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "../DecisionTree/DecisionTreeQuestion.h"
#import <UIKit/UIKit.h>

@interface QuestionHelpViewController : UIViewController

//TODO: Use copy instead of retain?
//See http://stackoverflow.com/questions/387959/nsstring-property-copy-or-retain
@property (nonatomic, retain) DecisionTreeQuestion *question;

@end
