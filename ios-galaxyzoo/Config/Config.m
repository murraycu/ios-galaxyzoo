//
//  Config.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "Config.h"
#import "ConfigSubjectGroup.h"

static NSDictionary *_subjectGroups; //Of Group ID to ConfigSubjectGroup.

@implementation Config

+ (void)initialize {

    if (self != [Config self]) {
        return;
    }
    
    _subjectGroups = [[NSDictionary alloc] initWithObjectsAndKeys:
                      [[ConfigSubjectGroup alloc] init:@"candels_tree.xml"
                                      useForNewQueries:YES
                                       discussQuestion:[[DecisionTreeDiscussQuestion alloc] init:@"candels-17"
                                                                                     yesAnswerId:@"a-0"
                                                                                      noAnswerId:@"a-1"]], @"551456e02f0eef2535000001",
                      [[ConfigSubjectGroup alloc] init:@"goods_full_tree.xml"
                                      useForNewQueries:YES
                                       discussQuestion:[[DecisionTreeDiscussQuestion alloc] init:@"goods_full-16"
                                                                                     yesAnswerId:@"a-0"
                                                                                      noAnswerId:@"a-1"]], @"551453e12f0eef21f2000001",
                      nil];
}

- (Config *)init {
    self = [super init];
    
    return self;
}

+ (NSDictionary *)subjectGroups {
    return _subjectGroups;
}

@end
