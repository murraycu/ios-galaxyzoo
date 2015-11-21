//
//  SubjectViewerViewController.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 15/06/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "SubjectViewerViewController.h"
#import "SubjectViewController.h"
#import "../Config/Config.h"
#import "Utils.h"

@interface SubjectViewerViewController () {
    SubjectViewController *_subjectViewController;
}

@property (weak, nonatomic) IBOutlet UILabel *labelZooniverseId;

@end

@implementation SubjectViewerViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSubject:(ZooniverseSubject *)subject {
    _subject = subject;
    _subjectViewController.subject = subject;

    [self updateUI];
}

- (void)updateUI {
    _subjectViewController.subject = self.subject;
    self.labelZooniverseId.text = self.subject.zooniverseId;
}

- (IBAction)onButtonExamineClicked:(UIButton *)sender {
    NSString *strUrl = [NSString stringWithFormat:@"%@%@",
                        [Config examineUri],
                        self.subject.zooniverseId,
                        nil];
    [Utils openUrlInBrowser:strUrl];
}

- (IBAction)onButtonDiscussClicked:(UIButton *)sender {
    [Utils openDiscussionPage:self.subject.zooniverseId];
}

#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueName = segue.identifier;
    if ([segueName isEqualToString:@"subjectViewerViewEmbed"]) {
        _subjectViewController = segue.destinationViewController;
    }
}


@end
