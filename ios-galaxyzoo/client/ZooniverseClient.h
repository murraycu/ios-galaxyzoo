//
//  ZooniverseClient.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 01/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZooniverseClient : NSObject {
    NSArray *_subjects;
}

- (ZooniverseClient *) init;
- (void)querySubjects;

@end


