//
//  DecisionTreeDiscussQuestion.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 04/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DecisionTreeDiscussQuestion : NSObject <NSCopying>

@property (nonatomic, copy) NSString *questionId;
@property (nonatomic, copy) NSString *yesAnswerId;
@property (nonatomic, copy) NSString *noAnswerId;

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithIDs:(NSString *)questionId yesAnswerId:(NSString *)yesAnswerId noAnswerId:(NSString *)noAnswerId;

@end
