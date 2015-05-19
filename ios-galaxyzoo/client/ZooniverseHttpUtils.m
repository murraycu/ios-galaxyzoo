//
//  ZooniverseHttpUtils.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 19/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "ZooniverseHttpUtils.h"

@implementation ZooniverseHttpUtils

+ (NSString *)urlEncodeValue:(NSString *)str
{
    return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (void)addNameValuePairToArray:(NSMutableArray *)array
                    name:(NSString *)name
                   value:(NSString *)value {
    ZooniverseNameValuePair *pair = [[ZooniverseNameValuePair alloc] init:name
                                                                    value:value];
    [array addObject:pair];
}

+ (NSString *)generateAuthorizationHeader:(NSString *)authName
                               authApiKey:(NSString *)authApiKey {
    NSString *str = [NSString stringWithFormat:@"%@:%@", authName, authApiKey];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];

    NSString *encoded = [data base64EncodedStringWithOptions:0];
    return [NSString stringWithFormat:@"Basic %@", encoded];
}

@end
