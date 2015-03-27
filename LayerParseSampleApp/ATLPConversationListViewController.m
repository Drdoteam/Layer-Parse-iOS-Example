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
        //return [[ATLPDataSource sharedManager] titleForConversation:conversation];
        
        NSLog(@"hit");
        
        static NSCache *userCache = nil;
        if (!userCache) {
            userCache = [NSCache new];
        }
        
        // Find the set of the users that we do and do not know about
        NSMutableSet *unresolvedParticipants = [conversation.participants mutableCopy];
        
        if ([unresolvedParticipants containsObject:[PFUser currentUser].objectId]) {
            [unresolvedParticipants removeObject:[PFUser currentUser].objectId];
        }
        
        NSMutableArray *resolvedNames = [NSMutableArray new];
        for (NSString *userID in conversation.participants) {
            PFUser *user = [userCache objectForKey:userID];
            if (user) {
                [unresolvedParticipants removeObject:userID];
                [resolvedNames addObject:user.firstName];
            }
        }
        
        if ([unresolvedParticipants count]) {
            // We need to look these guys up in Parse
            PFQuery *query = [PFUser query];
            [query whereKey:@"objectId" containedIn:[conversation.participants allObjects]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (objects) {
                    // Cache them and reload the cell
                    for (PFUser *user in objects) {
                        [userCache setObject:user forKey:user.objectId];
                    }
                    [self.tableView reloadData];
                }
            }];
        }
        
        // Return the title based on whatever we have available
        if ([resolvedNames count] && [unresolvedParticipants count]) {
            return [NSString stringWithFormat:@"%@ and %lu others", [resolvedNames componentsJoinedByString:@", "], (unsigned long)[unresolvedParticipants count]];
        } else if ([resolvedNames count] && [unresolvedParticipants count] == 0) {
            return [NSString stringWithFormat:@"%@", [resolvedNames componentsJoinedByString:@", "]];
        } else {
            return [NSString stringWithFormat:@"Conversation with %lu users...", (unsigned long)conversation.participants.count];
        }
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
