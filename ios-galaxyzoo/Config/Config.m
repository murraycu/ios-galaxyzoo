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

    _subjectGroups = [[NSDictionary alloc] initWithObjectsAndKeys:
                      /*
                      [[ConfigSubjectGroup alloc] init:@"candels_tree.xml"
                                      useForNewQueries:NO
                                       discussQuestion:[[DecisionTreeDiscussQuestion alloc] init:@"candels-17"
                                                                                     yesAnswerId:@"a-0"
                                                                                      noAnswerId:@"a-1"]], @"551456e02f0eef2535000001",
                      [[ConfigSubjectGroup alloc] init:@"goods_full_tree.xml"
                                      useForNewQueries:NO
                                       discussQuestion:[[DecisionTreeDiscussQuestion alloc] init:@"goods_full-16"
                                                                                     yesAnswerId:@"a-0"
                                                                                      noAnswerId:@"a-1"]], @"551453e12f0eef21f2000001",
                       */

                      [[ConfigSubjectGroup alloc] init:@"decals_tree.xml"
                                      useForNewQueries:YES
                                       discussQuestion:[[DecisionTreeDiscussQuestion alloc] init:@"decals-11"
                                                                                     yesAnswerId:@"a-0"
                                                                                      noAnswerId:@"a-1"]], @"55db7cf01766276e7b000001",
                      [[ConfigSubjectGroup alloc] init:@"illustris_tree.xml"
                                      useForNewQueries:YES
                                       discussQuestion:[[DecisionTreeDiscussQuestion alloc] init:@"illustris-11"
                                                                                     yesAnswerId:@"a-0"
                                                                                      noAnswerId:@"a-1"]], @"55db71251766276613000001",


                      //We don't request items for all these groups any more, but we still want to load the
                      //trees so we can ask questions about items that have already been downloaded and stored in
                      //the cache.
                      //At some point we can remove some when we are sure they are unnecessary.
                      [[ConfigSubjectGroup alloc] init:@"sloan_singleband_tree.xml"
                                      useForNewQueries:NO
                                       discussQuestion:[[DecisionTreeDiscussQuestion alloc] init:@"sloan_singleband-11"
                                                                                     yesAnswerId:@"a-0"
                                                                                      noAnswerId:@"a-1"]], @"5514521e2f0eef2012000001",
                      [[ConfigSubjectGroup alloc] init:@"sloan_tree.xml"
                                      useForNewQueries:NO
                                       discussQuestion:[[DecisionTreeDiscussQuestion alloc] init:@"sloan-11"
                                                                                     yesAnswerId:@"a-0"
                                                                                      noAnswerId:@"a-1"]], @"50251c3b516bcb6ecb000002",

                      nil];
    
}

- (Config *)init {
    self = [super init];

    return self;
}

+ (NSDictionary *)subjectGroups {
    return _subjectGroups;
}

+ (NSString *)userAgent {
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    NSString *version = infoDictionary[(NSString*)@"CFBundleShortVersionString"]; //kCFBundleVersionKey is the build version.

    return [NSString stringWithFormat:@"%@/%@", USER_AGENT, version];
}

+ (NSString *)baseUrl {
    return @"https://api.zooniverse.org/projects/galaxy_zoo/";
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
    return @"http://talk.galaxyzoo.org/#/subjects/";
}

+ (NSString *)examineUri {
    return @"http://www.galaxyzoo.org/#/examine/";
}



@end
