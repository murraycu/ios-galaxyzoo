//
//  Utils.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 12/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "Utils.h"
#import "Config.h"
#import <UIKit/UIKit.h>

@implementation Utils

+ (void)fetchRequestSortByDateTimeRetrieved:(NSFetchRequest *)fetchRequest {
    //TODO: Move this to somewhere reusable for ClassifyViewController?
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"datetimeRetrieved" ascending:YES]];
}

+ (void)openDiscussionPage:(NSString *)zooniverseId {
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", [Config talkUri], zooniverseId];
    NSURL *url = [NSURL URLWithString:strUrl];

    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"Failed to open url: %@", [url description]);
    }
}

@end
