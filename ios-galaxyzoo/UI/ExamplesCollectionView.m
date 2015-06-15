//
//  ExamplesCollectionView.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 11/06/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "ExamplesCollectionView.h"
#import "../DecisionTree/DecisionTreeQuestionAnswer.h"
#import "../DecisionTree/DecisionTreeQuestionCheckbox.h"
#import "ExamplesCollectionViewCell.h"
#import "ExamplesCollectionViewCellButton.h"
#import "ExamplesCollectionViewHeaderCell.h"

@interface ExamplesCollectionView() {
    ZooniverseExamplesCollectionViewClickedBlock _callbackBlockExampleClicked;
}
@end

@implementation ExamplesCollectionView

//static const NSInteger MAX_BUTTONS_PER_ROW = 4;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (ExamplesCollectionView *)initWithFrame:(CGRect)aRect {
    self = [super initWithFrame:aRect];

    [self setupCollectionView];

    return self;
}

- (ExamplesCollectionView *)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];

    [self setupCollectionView];

    return self;
}

- (void)setupCollectionView {
    UINib *cellNib = [UINib nibWithNibName:@"ExamplesCollectionViewCellView" bundle:nil];
    [self registerNib:cellNib forCellWithReuseIdentifier:@"exampleCell"];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.delegate = self;
    self.dataSource = self;
}

- (void)setExampleClickedCallback:(ZooniverseExamplesCollectionViewClickedBlock)callbackBlockExampleClicked {
    _callbackBlockExampleClicked = callbackBlockExampleClicked;

}

#pragma mark - UICollectionViewDelegate

-(DecisionTreeQuestionBaseButton *)getAnswerForSection:(NSInteger)section {
    DecisionTreeQuestionBaseButton *answer = nil;
    if (section < _question.checkboxes.count) {
        answer = [_question.checkboxes objectAtIndex:section];
    } else {
        NSInteger answerIndex = section - _question.checkboxes.count;
        answer = [_question.answers objectAtIndex:answerIndex];
    }

    return answer;
}

-(DecisionTreeQuestionBaseButton *)getAnswerForIndexPath:(NSIndexPath *)indexPath {
    NSInteger i = [indexPath indexAtPosition:0];
    return [self getAnswerForSection:i];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSLog(@"debug");
    return self.question.checkboxes.count + self.question.answers.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    DecisionTreeQuestionBaseButton *answer = [self getAnswerForSection:section];
    return answer.examplesCount + 1; //+1 for the answer button's icon too.
}

+(NSString *) getExampleIconName:(NSString *)questionId
                     forAnswerId:(NSString *)answerId
                 forExampleIndex:(NSInteger)exampleIndex {
    return [NSString stringWithFormat:@"%@_%@_%ld",
            questionId, answerId, (long)exampleIndex];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *result = nil;

    if (kind == UICollectionElementKindSectionHeader) {
        static NSString *cellIdentifier = @"headerCell";
        result = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                    withReuseIdentifier:cellIdentifier
                                                           forIndexPath:indexPath];
        ExamplesCollectionViewHeaderCell *cell = (ExamplesCollectionViewHeaderCell *)result;

        DecisionTreeQuestionBaseButton *answer = [self getAnswerForIndexPath:indexPath];
        cell.labelHeaderTitle.text = answer.text;
    }

    return result;
}

-(void)onExampleImageButtonClick:(UIView *)clickedButton
{
    ExamplesCollectionViewCellButton *button = (ExamplesCollectionViewCellButton *)clickedButton;
    _callbackBlockExampleClicked(button.answer,
                                 button.exampleIndex);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"exampleCell";

    UICollectionViewCell *cellBase = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cellBase.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    ExamplesCollectionViewCell *cell = (ExamplesCollectionViewCell *)cellBase;
    UIImage *image = nil;

    ExamplesCollectionViewCellButton *button = cell.button;
    UIImageView *imageView = cell.imageView;

    DecisionTreeQuestionBaseButton *answer = [self getAnswerForIndexPath:indexPath];
    NSInteger index = [indexPath indexAtPosition:1];
    if (index == 0) {
        //TODO: Move the adding of the icon_ prefix into a reusable method.
        NSString *filenameIcon = [NSString stringWithFormat:@"icon_%@", answer.icon, nil];
        image = [UIImage imageNamed:filenameIcon];

        button.hidden = YES;
    } else {
        NSInteger exampleIndex = index - 1;
        NSString *iconName = [ExamplesCollectionView getExampleIconName:self.question.questionId
                                          forAnswerId:answer.answerId
                                      forExampleIndex:exampleIndex];

        //TODO: Move the adding of the icon_ prefix into a reusable method.
        NSString *filenameIcon = [NSString stringWithFormat:@"icon_%@", iconName, nil];
        image = [UIImage imageNamed:filenameIcon];

        //Respond to clicks, to show the full image:
        button.hidden = NO;
        button.answer = (DecisionTreeQuestionAnswer*)answer;
        button.exampleIndex = exampleIndex;
        [button addTarget:self
                   action:@selector(onExampleImageButtonClick:)
         forControlEvents:UIControlEventTouchUpInside];
    }

    imageView.image = image;

    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

/*
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    //If there is only one row, let the buttons take up all the available width.
    //Otherwise, always divide the width by 4 so that buttons in the next row line up too.
    NSInteger itemsPerRow = MAX_BUTTONS_PER_ROW;
    NSInteger count = _question.checkboxes.count + _question.answers.count;
    if (count < MAX_BUTTONS_PER_ROW) {
        itemsPerRow = count;
    }

    //Calculate the width available for each item
    //by getting the full width, subtracting the space between items,
    //and dividing.
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)collectionViewLayout;
    CGFloat spacing = flowLayout.minimumInteritemSpacing;
    CGFloat totalSpacing = spacing * (itemsPerRow - 1);
    return CGSizeMake((collectionView.frame.size.width - totalSpacing) / itemsPerRow,
                      100);
}
*/

@end
