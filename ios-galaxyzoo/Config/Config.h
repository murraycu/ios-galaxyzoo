//
//  Config.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Config : NSObject

+ (void)initialize;

- (Config *) init;

+ (NSDictionary *)subjectGroups; //Of Group ID to ConfigSubjectGroup.

+ (NSString *)baseUrl;
+ (NSString *)userAgent;

+ (NSString *)forgotPasswordUri;
+ (NSString *)registerUri;




@end
