//
//  ATLPDataSource.m
//  LayerParseTest
//
//  Created by Kabir Mahal on 3/25/15.
//  Copyright (c) 2015 Abir Majumdar. All rights reserved.
//

#import "ATLPDataSource.h"
#import <Parse/Parse.h>
#import "PFUser+ATLParticipant.h"

@implementation ATLPDataSource

#pragma mark - Public Methods

+ (instancetype)sharedManager {
    static ATLPDataSource *sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[ATLPDataSource alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark Query Methods

- (void)localQueryForUserWithName:(NSString*)searchText completion:(void (^)(NSArray *participants))completion
{
    PFQuery *query = [PFUser query];
    [query fromLocalDatastore];
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableArray *contacts = [NSMutableArray new];
        for (PFUser *user in objects){
            if ([user.fullName rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [contacts addObject:user];
            }
        }
        if (completion) completion([NSArray arrayWithArray:contacts]);
    }];
}

- (void)localQueryForAllUsersWithCompletion:(void (^)(NSArray *users))completion
{
    PFQuery *query = [PFUser query];
    [query fromLocalDatastore];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (completion) completion(objects);
    }];
}

- (PFUser *)localQueryForUserID:(NSString *)userID
{
    PFQuery *query = [PFUser query];
    [query fromLocalDatastore];
    PFUser *user = (PFUser*)[query getObjectWithId:userID];
    return user;
}

#pragma mark Data Creation Methods

- (void)createLocalParseUsersIfNeeded
{
    PFQuery *localQuery = [PFUser query];
    [localQuery fromLocalDatastore];
    [localQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count <= 1){
            [self createUserWithUsername:@"Bob"];
            [self createUserWithUsername:@"Jane"];
        }
    }];
}

- (void)createUserWithUsername:(NSString *)username
{
    PFUser *user = [PFUser new];
    user.username = username;
    user.objectId = [NSString stringWithFormat:@"ATLP%@", user.avatarInitials];
    [user pinInBackground];
}

- (void)queryAndLocallyStoreCloudUsers
{
    PFQuery *localQuery = [PFUser query];
    [localQuery fromLocalDatastore];
    [localQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        NSMutableArray *userIDS = [NSMutableArray new];
        
        for (PFUser *user in objects) {
            [userIDS addObject:user.objectId];
        }
        
        PFQuery *query = [PFUser query];
        [query whereKey:@"objectId" notContainedIn:userIDS];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (PFUser *user in objects) {
                [user pinInBackground];
            }
        }];
    }];
}

- (NSString *)titleForConversation:(LYRConversation *)conversation
{
    NSMutableSet *participants = conversation.participants.mutableCopy;
    if ([participants containsObject:[PFUser currentUser].objectId]) {
        [participants removeObject:[PFUser currentUser].objectId];
    }
    
    NSString *title = @"";
    NSArray *titleParticipants = [participants allObjects];
    
    for (int i = 0; i <titleParticipants.count; i++) {
        PFUser *user = [[ATLPDataSource sharedManager] localQueryForUserID:[titleParticipants objectAtIndex:i]];
        if (i < titleParticipants.count-1) {
            title = [title stringByAppendingString:[NSString stringWithFormat:@"%@, ", user.firstName]];
        } else {
            title = [title stringByAppendingString:user.firstName];
        }
    }
    
    return title;
}

@end
