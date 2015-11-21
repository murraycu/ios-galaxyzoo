//
//  QuestionAnswerButton.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 13/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "QuestionAnswerButton.h"

@implementation QuestionAnswerButton


- (instancetype) initWithCoder:(NSCoder *)decoder
{
    if (!(self = [super initWithCoder:decoder]))
        return nil;

    return self;
}

//Calculate the left x position to arrange the item in the center of the parent's width.
+ (CGFloat)calcLeft:(CGFloat)width
parentWidth:(CGFloat)parentWidth
insets:(UIEdgeInsets)insets {
    return (parentWidth - width) / 2 + insets.left;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    //We wouldn't have access to the insets from the .xib file
    //later in sizeForItemAtIndexPath, so we use hard-coded values:
    //See QuestionAnswersCollectionView's sizeForItemAtIndexPath.
    //UIEdgeInsets titleInsets = self.titleEdgeInsets;
    //UIEdgeInsets imageInsets = self.imageEdgeInsets;
    UIEdgeInsets titleInsets = [QuestionAnswerButton realTitleInset];
    UIEdgeInsets imageInsets = [QuestionAnswerButton realImageInset];

    //CGRect parentFrame = self.frame;
    CGRect parentBounds = self.bounds;
    //NSLog(@"parentFrame.origin.x=%f", parentFrame.origin.x);

    CGSize parentSize = parentBounds.size;
    CGSize imageSize = self.imageView.image.size;
    imageSize.width = imageSize.width / 2; //TODO: Avoid this manual 50% scaling.
    imageSize.height = imageSize.height / 2;

    CGFloat width = parentSize.width - titleInsets.left - titleInsets.right;
    CGFloat heightLeftForTitle = parentSize.height - (imageSize.height + imageInsets.top + imageInsets.bottom + titleInsets.top + titleInsets.bottom);
    CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake(width, heightLeftForTitle)];

    CGRect imageNewBounds = CGRectMake(imageInsets.left,
                                      imageInsets.top,
                                      imageSize.width,
                                      imageSize.height);

    CGRect titleNewBounds = CGRectMake(titleInsets.left,
                                       titleInsets.top,
                                      titleSize.width,
                                      titleSize.height);

    //titleNewFrame.origin.x += 5;
    self.imageView.bounds = imageNewBounds;
    self.imageView.center = CGPointMake(imageInsets.left + parentBounds.size.width / 2,
                                        CGRectGetMidY(imageNewBounds));

    self.titleLabel.bounds = titleNewBounds;
    self.titleLabel.center = CGPointMake(titleInsets.left + parentBounds.size.width / 2,CGRectGetMaxY(imageNewBounds) + CGRectGetMidY(titleNewBounds));
}

+ (UIEdgeInsets) realImageInset {
    return UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0);
}

+ (UIEdgeInsets) realTitleInset {
    return UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0);
}

@end
