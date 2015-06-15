//
//  HelpViewController.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 12/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "QuestionHelpViewController.h"
#import "ExamplesCollectionView.h"
#import "ExampleViewerViewController.h"
#import "Config.h"

@interface QuestionHelpViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelText;
@property (weak, nonatomic) IBOutlet ExamplesCollectionView *collectionViewExamples;

@property (strong, nonatomic) NSString *exampleUrlToShow;

@end

@implementation QuestionHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.labelText.text = self.question.help;

    self.collectionViewExamples.question = self.question;
    [self.collectionViewExamples reloadData];

    [self.collectionViewExamples setExampleClickedCallback:^(DecisionTreeQuestionAnswer *answer, NSInteger exampleIndex) {
        NSString *iconName = [ExamplesCollectionView getExampleIconName:self.question.questionId
                                                            forAnswerId:answer.answerId
                                                        forExampleIndex:exampleIndex];
        self.exampleUrlToShow = [self getExampleImageUri:iconName];

        [self performSegueWithIdentifier:@"exampleViewEmbed"
                                  sender:self];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)getExampleImageUri:(NSString *)iconName {
    return [NSString stringWithFormat:@"%@%@.jpg",
     [Config fullExampleUri], iconName, nil];
}

#pragma mark - Navigation

 - (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     NSString *segueName = segue.identifier;
     if ([segueName isEqualToString:@"exampleViewEmbed"]) {
         ExampleViewerViewController *viewController = [segue destinationViewController];
         viewController.url = self.exampleUrlToShow;
     }
 }

@end
