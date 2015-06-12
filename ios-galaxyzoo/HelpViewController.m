//
//  HelpViewController.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 12/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "HelpViewController.h"
#import "ExamplesCollectionView.h"

@interface HelpViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelText;
@property (weak, nonatomic) IBOutlet ExamplesCollectionView *collectionViewExamples;

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    self.labelText.text = self.question.help;

    self.collectionViewExamples.question = self.question;
    [self.collectionViewExamples reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
