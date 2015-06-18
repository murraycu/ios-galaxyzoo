//
//  ListCollectionViewCellButton.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 15/06/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../../ZooniverseModel/ZooniverseSubject.h"

@interface ListCollectionViewCellButton : UIButton

@property (nonatomic, strong) ZooniverseSubject *subject;

@end
