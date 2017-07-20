//
//  Utils.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 12/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface Utils : NSObject

+ (void)fetchRequestSortByDateTimeRetrieved:(NSFetchRequest *)fetchRequest;
+ (void)fetchRequestSortByDoneAndDateTimeRetrieved:(NSFetchRequest *)fetchRequest;

+ (void)openDiscussionPage:(UIViewController *)viewController
              zooniverseId:(NSString *)zooniverseId;

+ (void)openUrlInBrowser:(UIViewController *)viewController
                     url:(NSString *)strUrl;

+ (NSString *)filenameForIconName:(NSString *)iconName;

@end
