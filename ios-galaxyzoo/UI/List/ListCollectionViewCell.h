//
//  ListCollectionViewCell.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 11/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListCollectionViewCellButton.h"

@interface ListCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet ListCollectionViewCellButton *button;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageStatusDone;
@property (weak, nonatomic) IBOutlet UIImageView *imagestatusUploaded;
@property (weak, nonatomic) IBOutlet UIImageView *imageStatusFavorite;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end
