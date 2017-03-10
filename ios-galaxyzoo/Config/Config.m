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
static NSString *USER_AGENT = @"murrayc.com-ios-galaxyzoo";

@implementation Config

+ (void)initialize {

    if (self != [Config self]) {
        return;
    }

    _subjectGroups =
                        //Ferengi 2:
                        @{@"58417dcb9afc3a007d000001": [[ConfigSubjectGroup alloc] initWithFilename:@"ferengi_tree.xml"
                                                                                   useForNewQueries:YES
                                                                                    discussQuestion:[[DecisionTreeDiscussQuestion alloc]
                                                                                        initWithIDs:@"ferengi-16"
                                                                                     yesAnswerId:@"a-0"
                                                                                      noAnswerId:@"a-1"]],
                        //SDSS Lost Set:
                        @"56f2b5ed5925d9004200c775": [[ConfigSubjectGroup alloc] initWithFilename:@"sloan_tree.xml"
                                                                                   useForNewQueries:YES
                                                                                    discussQuestion:[[DecisionTreeDiscussQuestion alloc] initWithIDs:@"sloan-11"
                                                                                      yesAnswerId:@"a-0"
                                                                                       noAnswerId:@"a-1"]],
                        //Decals DR2:
                        @"56f3d4645925d95984000001": [[ConfigSubjectGroup alloc] initWithFilename:@"decals_tree.xml"
                                                                                useForNewQueries:YES
                                                                                 discussQuestion:[[DecisionTreeDiscussQuestion alloc] initWithIDs:@"decals-11"
                                                                                    yesAnswerId:@"a-0"
                                                                                    noAnswerId:@"a-1"]],


                        //Gama 09:
                        @"5853fa7b95ad361930000001": [[ConfigSubjectGroup alloc] initWithFilename:@"gama_tree.xml"
                                                                                   useForNewQueries:YES
                                                                                    discussQuestion:[[DecisionTreeDiscussQuestion alloc] initWithIDs:@"gama-11"
                                                                                                                                         yesAnswerId:@"a-0"
                                                                                                                                          noAnswerId:@"a-1"]],

                       //We don't request items for all these groups any more, but we still want to load the
                       //trees so we can ask questions about items that have already been downloaded and stored in
                       //the cache.
                       //At some point we can remove some when we are sure they are unnecessary.

                        /*
                       //Decals:
                       @"55db7cf01766276e7b000001": [[ConfigSubjectGroup alloc] initWithFilename:@"decals_tree.xml"
                                                                                useForNewQueries:NO
                                                                                 discussQuestion:[[DecisionTreeDiscussQuestion alloc] initWithIDs:@"decals-11"
                                                                                    yesAnswerId:@"a-0"
                                                                                    noAnswerId:@"a-1"]],
                       //Sloan singleband:
                       @"5514521e2f0eef2012000001": [[ConfigSubjectGroup alloc] initWithFilename:@"sloan_singleband_tree.xml"
                                                                                useForNewQueries:NO
                                                                                 discussQuestion:[[DecisionTreeDiscussQuestion alloc] initWithIDs:@"sloan_singleband-11"
                                                                                    yesAnswerId:@"a-0"
                                                                                    noAnswerId:@"a-1"]],
                       //Sloan:
                       @"50251c3b516bcb6ecb000002": [[ConfigSubjectGroup alloc] initWithFilename:@"sloan_tree.xml"
                                                                                useForNewQueries:NO
                                                                                 discussQuestion:[[DecisionTreeDiscussQuestion alloc] initWithIDs:@"sloan-11"
                                                                                    yesAnswerId:@"a-0"
                                                                                    noAnswerId:@"a-1"]]
                         */};
}

- (Config *)init {
    self = [super init];

    return self;
}

+ (NSDictionary *)subjectGroups {
    return _subjectGroups;
}

+ (NSString *)userAgent {
    NSDictionary *infoDictionary = [NSBundle mainBundle].infoDictionary;
    NSString *version = infoDictionary[(NSString*)@"CFBundleShortVersionString"]; //kCFBundleVersionKey is the build version.

    return [NSString stringWithFormat:@"%@/%@", USER_AGENT, version];
}

+ (NSString *)baseUrl {
    return @"https://www.galaxyzoo.org/_ouroboros_api/projects/galaxy_zoo/";
}

+ (NSString *)fullExampleUri {
    return @"https://static.zooniverse.org/www.galaxyzoo.org/images/examples/";
}

+ (NSString *)forgotPasswordUri {
    return @"https://zooniverse.org/password/reset";
}

+ (NSString *)registerUri {
    return @"https://zooniverse.org/signup";

}

+ (NSString *)talkUri {
    return @"https://talk.galaxyzoo.org/#/subjects/";
}

+ (NSString *)examineUri {
    return @"https://www.galaxyzoo.org/#/examine/";
}



@end
