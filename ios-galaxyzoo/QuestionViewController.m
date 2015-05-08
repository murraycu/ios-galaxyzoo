//
//  QuestionViewController.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 07/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "QuestionViewController.h"
#import "DecisionTreeQuestionAnswer.h"

const NSInteger MAX_BUTTONS_PER_ROW = 4;

@interface QuestionViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewAnswers;

@end

@implementation QuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UINib *cellNib = [UINib nibWithNibName:@"AnswerCellView" bundle:nil];
    [self.collectionViewAnswers registerNib:cellNib forCellWithReuseIdentifier:@"answerCell"];
    self.collectionViewAnswers.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUI {
    self.labelTitle.text = _question.title;
    self.textView.text = _question.text;
    self.collectionViewAnswers.dataSource = self;
    [self.collectionViewAnswers reloadData];
}

- (void)setQuestion:(DecisionTreeQuestion *)question {
    _question = question;
    
    [self updateUI];
}

#pragma mark - UICollectionView

/*
- (NSInteger)numberOfSectionsForItems:(NSInteger)itemsCount
                   forItemsPerSection:(NSInteger)itemsPerSection {
    return (itemsCount + itemsPerSection + 1) / itemsPerSection;
}
*/

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //return MAX_BUTTONS_PER_ROW;
    NSInteger index = section * MAX_BUTTONS_PER_ROW;
    NSInteger remaining = _question.answers.count - index;
    if (remaining > MAX_BUTTONS_PER_ROW) {
        return MAX_BUTTONS_PER_ROW;
    } else {
        return remaining;
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"answerCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;

    
    UIButton *button = (UIButton *)[cell viewWithTag:100];
    
    NSInteger i = [indexPath indexAtPosition:0] * MAX_BUTTONS_PER_ROW + [indexPath indexAtPosition:1];
    DecisionTreeQuestionAnswer *answer = [_question.answers objectAtIndex:i];
    [button setTitle:answer.text
     forState:UIControlStateNormal];

    //TODO: Move the adding of the icon_ prefix into a reusable method.
    NSString *filenameIcon = [NSString stringWithFormat:@"icon_%@", answer.icon, nil];
    UIImage *image = [UIImage imageNamed:filenameIcon];
    //[button setImage:image
    //        forState:UIControlStateNormal];
    [button setBackgroundImage:image
            forState:UIControlStateNormal];
    
    //Respond to button touches:
    button.tag = i; //So we know which button was clicked.
    [button addTarget:self
               action:@selector(onAnswerButtonClick:)
     forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

-(void)onAnswerButtonClick:(UIView*)clickedButton
{
    NSInteger i = clickedButton.tag;
    DecisionTreeQuestionAnswer *answer = [_question.answers objectAtIndex:i];

    NSLog(@"Answer clicked:%@", answer.text);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
