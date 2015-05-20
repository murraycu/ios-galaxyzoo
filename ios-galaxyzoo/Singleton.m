//
//  Singleton.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "Singleton.h"
#import "Config/Config.h"
#import "Config/ConfigSubjectGroup.h"

@interface Singleton () {

    NSMutableDictionary *_decisionTrees; //Group ID to DecisionTree;

}

@end


@implementation Singleton

static Singleton *sharedSingleton = nil;    // static instance variable

- (Singleton *)init {
    self = [super init];

    _decisionTrees = [[NSMutableDictionary alloc] init];

    NSDictionary *dict = [Config subjectGroups];
    for (NSString *groupId in dict) {
        //Apparently it's (now) OK to do this extra lookup due to some optimization:
        //See http://stackoverflow.com/a/12454766/1123654
        ConfigSubjectGroup *subjectGroup = [dict objectForKey:groupId];

        NSURL *url = [[NSBundle mainBundle] URLForResource:[subjectGroup filename]
                                             withExtension:nil];
        if (!url) {
            continue;
        }

        DecisionTree *tree = [[DecisionTree alloc] init:url
                              withDiscussQuestion:subjectGroup.discussQuestion];
        [_decisionTrees setObject:tree
                           forKey:groupId];
    }

    return self;
}


+ (Singleton *) sharedSingleton {
    if (sharedSingleton == nil) {
        sharedSingleton = [[Singleton alloc] init];
    }

    return sharedSingleton;
}

- (DecisionTree *) getDecisionTree:(NSString *)groupId {
    return [_decisionTrees objectForKey:groupId];
}

@end
