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

+ (NSString *) generateContentForNameValuePairs:(NSArray *)nameValuePairs {

    //TODO: Put this somewhere reusable so LoginViewController can use it too.
    NSMutableString *content;
    for (ZooniverseNameValuePair *pair in nameValuePairs) {
        NSString *str = [NSString stringWithFormat:@"%@=%@",
                         pair.name, pair.value];
        if (!content) {
            content = [[ZooniverseHttpUtils urlEncodeValue:str] mutableCopy];
        } else {
            [content appendString:@"&"];
            [content appendString:[ZooniverseHttpUtils urlEncodeValue:str]];
        }
    }

    return content;
}

+ (NSString *)generateAuthorizationHeader:(NSString *)authName
                               authApiKey:(NSString *)authApiKey {
    NSString *str = [NSString stringWithFormat:@"%@:%@", authName, authApiKey];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];

    NSString *encoded = [data base64EncodedStringWithOptions:0];
    return [NSString stringWithFormat:@"Basic %@", encoded];
}


+ (void)setRequestContent:(NSString *)content forRequest:(NSMutableURLRequest *)request {
    NSData* postData= [content dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:postData];
    NSString *contentLength = [NSString stringWithFormat:@"%lu", (unsigned long)postData.length];
    [request setValue:contentLength forHTTPHeaderField:@"Content-Length"];
}


@end