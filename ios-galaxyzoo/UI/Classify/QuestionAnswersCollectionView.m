//
//  QuestionsCollectionView.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 11/06/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "QuestionAnswersCollectionView.h"
#import "QuestionAnswersCollectionViewCell.h"
#import "QuestionAnswerButton.h"


@interface QuestionAnswersCollectionView () {
    ZooniverseQuestionAnswersCollectionViewAnswerClickedBlock _callbackBlockAnswerClicked;
    ZooniverseQuestionAnswersCollectionViewCheckboxClickedBlock _callbackBlockCheckboxClicked;

    CGSize _buttonSize;
    UIFont *_buttonFont;
    CGFloat _cachedFrameWidth;
}
@end

@implementation QuestionAnswersCollectionView

static const NSInteger MAX_BUTTONS_PER_ROW = 4;
static NSString *CELL_IDENTIFIER = @"answerCell";
static const NSInteger ICON_HEIGHT = 50;



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

- (void)setQuestion:(DecisionTreeQuestion *)question {
    _question = question;

    //Invalidate the button size so we recalculate it based on the new answers and checkboxes:
    _buttonSize.height = 0;
    _buttonSize.width = 0;
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

        DecisionTreeQuestionCheckbox *checkbox = [_question.checkboxes objectAtIndex:i];
        _callbackBlockCheckboxClicked(checkbox, button.selected);
    } else {
        NSInteger answerIndex = i - _question.checkboxes.count;
        DecisionTreeQuestionAnswer *answer = [_question.answers objectAtIndex:answerIndex];

        _callbackBlockAnswerClicked(answer);
    }
}


#pragma mark - UICollectionViewDelegate


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _question.answers.count + _question.checkboxes.count;
}

-(DecisionTreeQuestionBaseButton *)answerForIndex:(NSInteger)index {
    DecisionTreeQuestionBaseButton *answer;

    if (index < _question.checkboxes.count) {
        answer = [_question.checkboxes objectAtIndex:index];
    } else {
        NSInteger answerIndex = index - _question.checkboxes.count;
        answer = [_question.answers objectAtIndex:answerIndex];
    }

    return answer;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cellBase = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
cellBase.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    QuestionAnswersCollectionViewCell *cell = (QuestionAnswersCollectionViewCell *)cellBase;

    //Note that this is really our custom QuestionAnswerButton,
    //which arranges the title text below the image.
    UIButton *button = cell.button;

    //Reset selected, which we use for checkboxes:
    //TODO: We see the selection briefly before it is unselected.
    button.selected = NO;

    NSInteger i = [indexPath indexAtPosition:1];
    DecisionTreeQuestionBaseButton *answer = [self answerForIndex:i];
    [button setTitle:answer.text
            forState:UIControlStateNormal];
    button.titleLabel.font = [self buttonFont];

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

- (UIFont *)buttonFont {
    if (_buttonFont != nil) {
        return _buttonFont;
    }

    //It's apparently OK to use a UIFont for the "name", instead of a string.
    //TODO: I would still prefer to explicitly get an appropriate string for the UIFont.
    _buttonFont = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    return _buttonFont;
}

- (CGSize)cellSize:(UICollectionViewFlowLayout*)flowLayout {
    CGFloat frame_width = self.frame.size.width;

    //Return the cached size if it has already been calculated:
    if (_buttonSize.height != 0 && _buttonSize.width != 0
        && frame_width == _cachedFrameWidth) {
        return _buttonSize;
    }

    CGFloat heightMax = 0;

    NSInteger count = self.question.answers.count + self.question.checkboxes.count;

    //If there is only one row, let the buttons take up all the available width.
    //Otherwise, always divide the width by 4 so that buttons in the next row line up too.
    NSInteger itemsPerRow = MAX_BUTTONS_PER_ROW;
    if (count < MAX_BUTTONS_PER_ROW) {
        itemsPerRow = count;
    }

    //Calculate the width available for each item
    //by getting the full width, subtracting the space between items,
    //and dividing.
    CGFloat spacing = flowLayout.minimumInteritemSpacing;
    CGFloat totalSpacing = spacing * (itemsPerRow - 1);
    CGFloat buttonWidth = (frame_width - totalSpacing) / itemsPerRow;


    //Calculate the height of the highest item, based on that width:

    //TODO: Find a way to instead use the insets specified in the .xib file,
    //so we can remove realTitleInset and realImageInset.
    UIEdgeInsets titleInsets = [QuestionAnswerButton realTitleInset];
    UIEdgeInsets imageInsets = [QuestionAnswerButton realImageInset];

    //This is just to get the font used by the button:
    //However, this seems to fail.
    //UICollectionViewCell *cellBase = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    //QuestionAnswersCollectionViewCell *cell = (QuestionAnswersCollectionViewCell *)cellBase;
    NSDictionary *attributes = @{NSFontAttributeName: [self buttonFont]};

    for (NSInteger i = 0; i < count; ++i) {
        DecisionTreeQuestionBaseButton *answer = [self answerForIndex:i];

        CGRect textSize = [answer.text boundingRectWithSize:CGSizeMake(buttonWidth - titleInsets.left + titleInsets.right, CGFLOAT_MAX)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:attributes
                                                    context:nil];
        //NSLog(@"text=%@, buttonWidth=%f, textSize.width =%f", answer.text, buttonWidth, textSize.size.width);
        CGFloat buttonHeight = textSize.size.height + ICON_HEIGHT + imageInsets.top + imageInsets.bottom + titleInsets.top + titleInsets.bottom;
        if (buttonHeight > heightMax) {
            heightMax = buttonHeight;
        }
    }

    _buttonSize = CGSizeMake(buttonWidth, heightMax);
    return _buttonSize;
}

#pragma mark - UICollectionViewDelegateFlowLayout


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)collectionViewLayout;
    return [self cellSize:flowLayout];
}

@end
