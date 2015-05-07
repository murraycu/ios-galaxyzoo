//
//  ZooniverseClassificationAnswer.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 07/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "ZooniverseClassificationAnswer.h"

@implementation ZooniverseClassificationAnswer

@dynamic questionId;
@dynamic answerId;
@dynamic checkboxIds;

- (ZooniverseClassificationAnswer *)init:(NSString *)questionId
                                answerId:(NSString *)answerId
                             checkboxIds:(NSArray *)checkboxIds {
    self = [super init];
    
    self.questionId = questionId;
    self.answerId = answerId;
    self.checkboxIds = checkboxIds;
    
    return self;
}

@end
