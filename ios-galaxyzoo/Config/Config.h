//
//  Config.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Config : NSObject

@property (nonatomic, copy) NSDictionary *subjectGroups; //Of Group ID to ConfigSubjectGroup.

- (Config *) init;

@end
