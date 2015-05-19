//
//  ZooniverseHttpUtils.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 19/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZooniverseNameValuePair.h"

@interface ZooniverseHttpUtils : NSObject

+ (NSString *)urlEncodeValue:(NSString *)str;

+ (void)addNameValuePairToArray:(NSMutableArray *)array
                           name:(NSString *)name
                          value:(NSString *)value;

+ (NSString *) generateContentForNameValuePairs:(NSArray *)nameValuePairs;

+ (NSString *)generateAuthorizationHeader:(NSString *)authName
                               authApiKey:(NSString *)authApiKey;


+ (void)setRequestContent:(NSString *)content
               forRequest:(NSMutableURLRequest *)request;

@end
