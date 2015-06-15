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
                      [[ConfigSubjectGroup alloc] init:@"sloan_singleband_tree.xml"
                                      useForNewQueries:YES
                                       discussQuestion:[[DecisionTreeDiscussQuestion alloc] init:@"sloan_singleband-11"
                                                                                     yesAnswerId:@"a-0"
                                                                                      noAnswerId:@"a-1"]], @"5514521e2f0eef2012000001",
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
    return USER_AGENT;
}

+ (NSString *)baseUrl {
    return @"https://api.zooniverse.org/projects/galaxy_zoo/";
}

+ (NSString *)fullExampleUri {
    return @"http://static.zooniverse.org/www.galaxyzoo.org/images/examples/";
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



@end
