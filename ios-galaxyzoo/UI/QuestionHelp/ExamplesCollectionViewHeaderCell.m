//
//  ExamplesCollectionViewHeaderCell.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 11/06/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "ExamplesCollectionViewHeaderCell.h"

@implementation ExamplesCollectionViewHeaderCell

- (void)layoutSubviews
{
    //TODO: Remove this when we can support iOS 8 only.
    //Then we can just use the "automatic" (not explicit) Preferred Width
    //on labels in the storyboard.
    [super layoutSubviews];
    self.labelHeaderTitle.preferredMaxLayoutWidth = self.labelHeaderTitle.frame.size.width;
    [super layoutSubviews];
}

@end
