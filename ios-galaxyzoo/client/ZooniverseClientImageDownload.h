//
//  ZooniverseClientImageDownload.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 16/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZooniverseSubject.h"

@interface ZooniverseClientImageDownload : NSObject

typedef NS_ENUM(NSInteger, ImageLocation) {
    ImageLocationStandard,
    ImageLocationInverted,
    ImageLocationThumbnail
};

@property (nonatomic, strong) ZooniverseSubject *subject;
@property (nonatomic) ImageLocation imageLocation;
@property (nonatomic, strong) NSString *remoteUrl;

- (instancetype) init NS_DESIGNATED_INITIALIZER;


@end
