//
//  DecisionTreeCheckbox.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "DecisionTreeQuestionBaseButton.h"

@interface DecisionTreeQuestionCheckbox : DecisionTreeQuestionBaseButton

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithDetails:(NSString *)answerId
                                  icon:(NSString *)icon
                         examplesCount:(NSUInteger)examplesCount
                                  text:(NSString *)text NS_DESIGNATED_INITIALIZER;

@end
