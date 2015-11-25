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

- (void) resetQuestionToFirst;

- (void) revertClassification;

/** This is a hacky workaround, to call reloadData,
 * to avoid truncation of the text in the buttons when they are first shown.
 * See https://github.com/murraycu/ios-galaxyzoo/issues/19
 *
 * This might be relevant:
 * See http://stackoverflow.com/questions/32060037/uitableviewcell-needs-reloaddata-to-resize-to-correct-height
 */
- (void) useCorrectHeight;

@end
