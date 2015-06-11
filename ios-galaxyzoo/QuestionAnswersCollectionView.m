//
//  QuestionsCollectionView.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 11/06/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "QuestionAnswersCollectionView.h"
#import "QuestionAnswersCollectionViewCell.h"


@interface QuestionAnswersCollectionView () {

    ZooniverseQuestionAnswersCollectionViewAnswerClickedBlock _callbackBlockAnswerClicked;
    ZooniverseQuestionAnswersCollectionViewCheckboxClickedBlock _callbackBlockCheckboxClicked;
}
@end

@implementation QuestionAnswersCollectionView

const NSInteger MAX_BUTTONS_PER_ROW = 4;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (QuestionAnswersCollectionView *)initWithFrame:(CGRect)aRect {
    self = [super initWithFrame:aRect];

    [self setupCollectionView];

    return self;
}

- (QuestionAnswersCollectionView *)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];

    [self setupCollectionView];

    return self;
}

- (void)setupCollectionView {
    UINib *cellNib = [UINib nibWithNibName:@"QuestionAnswersCollectionViewCellView" bundle:nil];
    [self registerNib:cellNib forCellWithReuseIdentifier:@"answerCell"];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.delegate = self;

    self.dataSource = self;
}

- (void)setAnswerClickedCallback:(ZooniverseQuestionAnswersCollectionViewAnswerClickedBlock)callbackBlockAnswerClicked
     withCheckBoxClickedCallback:(ZooniverseQuestionAnswersCollectionViewCheckboxClickedBlock)callbackBlockCheckboxClicked {
    _callbackBlockAnswerClicked = callbackBlockAnswerClicked;
    _callbackBlockCheckboxClicked = callbackBlockCheckboxClicked;
}

-(void)onAnswerButtonClick:(UIView*)clickedButton
{
    NSInteger i = clickedButton.tag;

    if (i < _question.checkboxes.count) {
        UIButton *button = (UIButton *)clickedButton;
        button.selected = !(button.selected);

        //TODO: Check if it is active:
        DecisionTreeQuestionCheckbox *checkbox = [_question.checkboxes objectAtIndex:i];
        _callbackBlockCheckboxClicked(checkbox, button.selected);
    } else {
        NSInteger answerIndex = i - _question.checkboxes.count;
        DecisionTreeQuestionAnswer *answer = [_question.answers objectAtIndex:answerIndex];

        _callbackBlockAnswerClicked(answer);
    }
}


#pragma mark - UICollectionViewDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfSectionsInCollectionView:(NSInteger)section {
return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
return _question.answers.count + _question.checkboxes.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
static NSString *cellIdentifier = @"answerCell";

    UICollectionViewCell *cellBase = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
cellBase.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
QuestionAnswersCollectionViewCell *cell = (QuestionAnswersCollectionViewCell *)cellBase;

    UIButton *button = cell.button;

    //Reset selected, which we use for checkboxes:
    //TODO: We see the selection briefly before it is unselected.
    button.selected = NO;

    DecisionTreeQuestionBaseButton *answer = nil;
    NSInteger i = [indexPath indexAtPosition:1];
    if (i < _question.checkboxes.count) {
        answer = [_question.checkboxes objectAtIndex:i];
    } else {
        NSInteger answerIndex = i - _question.checkboxes.count;
        answer = [_question.answers objectAtIndex:answerIndex];
    }

    [button setTitle:answer.text
            forState:UIControlStateNormal];

    //TODO: Move the adding of the icon_ prefix into a reusable method.
    NSString *filenameIcon = [NSString stringWithFormat:@"icon_%@", answer.icon, nil];
    UIImage *image = [UIImage imageNamed:filenameIcon];
    [button setImage:image
            forState:UIControlStateNormal];
    //[button setBackgroundImage:image
    //        forState:UIControlStateNormal];

    //Respond to button touches:
    button.tag = i; //So we know which button was clicked.
    [button addTarget:self
               action:@selector(onAnswerButtonClick:)
     forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

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

@end
