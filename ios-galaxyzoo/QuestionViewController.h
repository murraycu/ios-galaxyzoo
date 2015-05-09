//
//  QuestionViewController.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 07/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DecisionTree/DecisionTreeQuestion.h"

@interface QuestionViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, copy) NSString *groupId;

//TODO: Use copy instead of retain?
//See http://stackoverflow.com/questions/387959/nsstring-property-copy-or-retain
@property (nonatomic, retain) DecisionTreeQuestion *question;

@end
