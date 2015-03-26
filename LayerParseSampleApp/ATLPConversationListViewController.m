//
//  ConversationListViewController.m
//  LayerParseTest
//
//  Created by Abir Majumdar on 2/28/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


#import "ATLPConversationListViewController.h"
#import "ATLPConversationViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "ATLPDataSource.h"

@interface ATLPConversationListViewController () <ATLConversationListViewControllerDelegate, ATLConversationListViewControllerDataSource>
@property (nonatomic) NSArray *usersArray;
@end

@implementation ATLPConversationListViewController

#pragma mark - Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    
    UIBarButtonItem *logoutItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonTapped:)];
    [self.navigationItem setLeftBarButtonItem:logoutItem];

    UIBarButtonItem *composeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeButtonTapped:)];
    [self.navigationItem setRightBarButtonItem:composeItem];
}

#pragma mark - ATLConversationListViewControllerDelegate Methods

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didSelectConversation:(LYRConversation *)conversation
{
    ATLPConversationViewController *controller = [ATLPConversationViewController conversationViewControllerWithLayerClient:self.layerClient];
    controller.conversation = conversation;
    controller.displaysAddressBar = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didDeleteConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode
{
    NSLog(@"Conversation deleted");
}

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didFailDeletingConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode error:(NSError *)error
{
    NSLog(@"Failed to delete conversation with error: %@", error);
}

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didSearchForText:(NSString *)searchText completion:(void (^)(NSSet *filteredParticipants))completion
{
    [[ATLPDataSource sharedManager] localQueryForUserWithName:searchText completion:^(NSArray *participants) {
        if (completion) completion([NSSet setWithArray:participants]);
    }];
}

#pragma mark - ATLConversationListViewControllerDataSource Methods

- (NSString *)conversationListViewController:(ATLConversationListViewController *)conversationListViewController titleForConversation:(LYRConversation *)conversation
{
    if ([conversation.metadata valueForKey:@"title"]){
        return [conversation.metadata valueForKey:@"title"];
    } else {
        return [[ATLPDataSource sharedManager] titleForConversation:conversation];
    }
}

// optional
- (id<ATLAvatarItem>)conversationListViewController:(ATLConversationListViewController *)conversationListViewController avatarItemForConversation:(LYRConversation *)conversation
{
    return nil;
}

#pragma mark - Actions

- (void)composeButtonTapped:(id)sender
{
    ATLPConversationViewController *controller = [ATLPConversationViewController conversationViewControllerWithLayerClient:self.layerClient];
    controller.displaysAddressBar = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)logoutButtonTapped:(id)sender
{
    NSLog(@"logOutButtonTapAction");
    
    [self.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
        if (!error) {
            [PFUser logOut];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            NSLog(@"Failed to deauthenticate: %@", error);
        }
    }];
}
 
@end
