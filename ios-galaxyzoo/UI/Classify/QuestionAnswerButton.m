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
spacing:(CGFloat)spacing {
    return (parentWidth - width - (2 * spacing)) / 2  + spacing;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat spacing = 2.0;
    CGRect parentFrame = self.frame;
    CGSize parentSize = parentFrame.size;
    CGSize imageSize = self.imageView.image.size;
    imageSize.width = imageSize.width / 2; //TODO: Avoid this manual 50% scaling.
    imageSize.height = imageSize.height / 2;

    CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake(parentSize.width,
                                                                parentSize.height - (imageSize.height + spacing))];

    CGRect imageNewFrame = CGRectMake(/* parentFrame.origin.x + */ [QuestionAnswerButton calcLeft:imageSize.width
                                                                                      parentWidth:parentSize.width
                                                                                          spacing:spacing],
                                      /* parentFrame.origin.y + */ spacing,
                                      imageSize.width,
                                      imageSize.height);

    CGRect titleNewFrame = CGRectMake(/* parentFrame.origin.x + */ [QuestionAnswerButton calcLeft:titleSize.width
                                                         parentWidth:parentSize.width
                                                             spacing:spacing],
                                      parentSize.height - titleSize.height - spacing,
                                      titleSize.width,
                                      titleSize.height);



    self.imageView.frame = imageNewFrame;
    self.titleLabel.frame = titleNewFrame;
}


@end
