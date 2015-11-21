//
//  Singleton.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "DecisionTree/DecisionTree.h"

@interface Singleton : NSObject

//TODO: Make this private?
- (instancetype) init;

+ (Singleton *) sharedSingleton;

- (DecisionTree *) getDecisionTree:(NSString *)groupId;

@end
