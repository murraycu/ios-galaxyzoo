//
//  ZooniverseClassification.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 07/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "ZooniverseClassificationAnswer.h"
#import <Foundation/Foundation.h>

@interface ZooniverseClassification : NSObject

@property (nonatomic, copy) NSMutableArray *answers; //Of ZooniverseClassificationAnswer
@property (nonatomic) BOOL favorite;

- (ZooniverseClassification *)init;

@end
