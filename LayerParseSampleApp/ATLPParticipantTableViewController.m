//
//  ParticipantTableViewController.m
//  LayerParseTest
//
//  Created by Abir Majumdar on 2/28/15.
//
//

#import "ATLPParticipantTableViewController.h"

@interface ATLPParticipantTableViewController ()

@end

@implementation ATLPParticipantTableViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(handleCancelTap)];
    self.navigationItem.leftBarButtonItem = cancelItem;
}

#pragma mark - Actions

- (void)handleCancelTap
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
