//
//  ZooniverseNameValuePair.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 17/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "ZooniverseNameValuePair.h"

@implementation ZooniverseNameValuePair


- (ZooniverseNameValuePair *) init:name
                             value:(NSString*)value
{
    self = [super init];

    self.name = name;
    self.value = value;

    return self;
}

@end
