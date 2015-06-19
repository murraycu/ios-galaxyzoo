//
//  QuestionAnswerButton.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 13/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "QuestionAnswerButton.h"

@implementation QuestionAnswerButton


- (id) initWithCoder:(NSCoder *)decoder
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

    CGRect parentFrame = self.frame;
    CGSize parentSize = parentFrame.size;
    CGSize imageSize = self.imageView.image.size;
    imageSize.width = imageSize.width / 2; //TODO: Avoid this manual 50% scaling.
    imageSize.height = imageSize.height / 2;

    CGFloat width = parentSize.width - titleInsets.left - titleInsets.right;
    CGFloat heightLeftForTitle = parentSize.height - (imageSize.height + imageInsets.top + imageInsets.bottom + titleInsets.top + titleInsets.bottom);
    CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake(width, heightLeftForTitle)];

    CGRect imageNewFrame = CGRectMake(/* parentFrame.origin.x + */ [QuestionAnswerButton calcLeft:imageSize.width
                                                                                      parentWidth:width
                                                                                          insets:imageInsets],
                                      /* parentFrame.origin.y + */ imageInsets.top,
                                      imageSize.width,
                                      imageSize.height);

    CGRect titleNewFrame = CGRectMake(/* parentFrame.origin.x + */ [QuestionAnswerButton calcLeft:titleSize.width
                                                         parentWidth:width
                                                             insets:titleInsets],
                                      parentSize.height - titleSize.height - titleInsets.bottom,
                                      titleSize.width,
                                      titleSize.height);



    //titleNewFrame.origin.x += 5;
    self.imageView.frame = imageNewFrame;
    self.titleLabel.frame = titleNewFrame;
}

+ (UIEdgeInsets) realImageInset {
    return UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0);
}

+ (UIEdgeInsets) realTitleInset {
    return UIEdgeInsetsMake(2.0, 2.0, 2.0, 2.0);
}

@end
