//
//  QuestionAnswerButton.h
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 13/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionAnswerButton : UIButton

//We can't get the insets from the .xib file,
//because we don't have access to that in sizeForItemAtIndexPath
//so we hard-code them in these methods.
+ (UIEdgeInsets) realImageInset;
+ (UIEdgeInsets) realTitleInset;

@end
