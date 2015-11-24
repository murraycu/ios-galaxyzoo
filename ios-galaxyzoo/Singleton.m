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

    NSString *translationFilename;

    //[NSLocale preferredLanguages] would give the system's preferred language, but we actually
    //want the language used by the app, which depends on whether we have provided a
    //localization, thus avoiding using a translated decision tree if we have not translated
    //the app's UI itself. This also seems to give us the actual localization locale, such as
    //"de", instead of the specific desired locale, such as "de_DE".
    [[NSBundle mainBundle] preferredLocalizations];
    NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];

    if (language != nil) {
        translationFilename = [NSString stringWithFormat:@"%@.json", language];
    }

    NSURL *urlTranslation = [[NSBundle mainBundle] URLForResource:translationFilename
                                                    withExtension:nil];

    NSDictionary *dict = [Config subjectGroups];
    for (NSString *groupId in dict) {
        //Apparently it's (now) OK to do this extra lookup due to some optimization:
        //See http://stackoverflow.com/a/12454766/1123654
        ConfigSubjectGroup *subjectGroup = dict[groupId];

        NSURL *url = [[NSBundle mainBundle] URLForResource:subjectGroup.filename
                                             withExtension:nil];
        if (!url) {
            NSLog(@"Singleton: Could not find decision tree XML file in assets: %@",
                  subjectGroup.filename);
            continue;
        }

        DecisionTree *tree = [[DecisionTree alloc] initWithUrl:url
                                                withTranslationUrl:urlTranslation
                              withDiscussQuestion:subjectGroup.discussQuestion];
        _decisionTrees[groupId] = tree;
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
    return _decisionTrees[groupId];
}

@end
