//
//  ZooniverseHttpUtils.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 19/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "ZooniverseHttpUtils.h"
#import "AppDelegate.h"
#import "Config.h"

@implementation ZooniverseHttpUtils

+ (NSString *)urlEncodeValue:(NSString *)str
{
    return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

+ (void)addNameValuePairToArray:(NSMutableArray *)array
                    name:(NSString *)name
                   value:(NSString *)value {
    ZooniverseNameValuePair *pair = [[ZooniverseNameValuePair alloc] initWithNameAndValue:name
                                                                                    value:value];
    [array addObject:pair];
}

+ (NSString *) generateContentForNameValuePairs:(NSArray *)nameValuePairs {
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

+ (NSMutableURLRequest *)createURLRequest:(NSURL *)uri {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setValue:[Config userAgent] forHTTPHeaderField:@"User-Agent"];

    BOOL wifiOnly = [AppDelegate preferenceWiFiOnly];
    request.allowsCellularAccess = !wifiOnly;

    return request;
}

+ (void)setRequestContent:(NSString *)content forRequest:(NSMutableURLRequest *)request {
    NSData* postData= [content dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = postData;
    NSString *contentLength = [NSString stringWithFormat:@"%lu", (unsigned long)postData.length];
    [request setValue:contentLength forHTTPHeaderField:@"Content-Length"];
}


@end
