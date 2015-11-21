//
//  DecisionTreeParser.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 05/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "DecisionTree.h"
#import <Foundation/Foundation.h>

@interface DecisionTreeParser : NSXMLParser <NSXMLParserDelegate>

- (instancetype)initWithUrlIntoTree:(NSURL *)url intoTree:(DecisionTree *)intoTree;


@end
