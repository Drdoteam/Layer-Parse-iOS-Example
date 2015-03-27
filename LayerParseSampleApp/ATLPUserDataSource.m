//
//  ATLPDataSource.m
//  LayerParseTest
//
//  Created by Kabir Mahal on 3/25/15.
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

#import "ATLPUserDataSource.h"
#import <Parse/Parse.h>
#import "PFUser+ATLParticipant.h"
#import <Bolts/Bolts.h>

@interface ATLPUserDataSource ()

@property (nonatomic) NSCache *userCache;

@end

@implementation ATLPUserDataSource

#pragma mark - Public Methods

+ (instancetype)sharedManager {
    static ATLPUserDataSource *sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[ATLPUserDataSource alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.userCache = [NSCache new];
    }
    return self;
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

- (void)queryForUserWithName:(NSString *)searchText completion:(void (^)(NSArray *))completion
{
    PFQuery *query = [PFUser query];
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
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (completion) completion(objects);
    }];
}

- (void)queryForAllUsersWithCompletion:(void (^)(NSArray *))completion
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (completion) completion(objects);
    }];
}

- (void)queryAndCacheUsersWithIDs:(NSArray *)userIDs completion:(void (^)(NSArray *))completion
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" containedIn:userIDs];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (completion) completion(objects);
        
        for (PFUser *user in objects) {
            [self cacheUserIfNeeded:user];
        }
    }];
}

- (void)cacheUserIfNeeded:(PFUser *)user
{
    if (![self.userCache objectForKey:user.objectId]) {
        [self.userCache setObject:user forKey:user.objectId];
    }
}

- (NSArray *)unCachedUserIDsFromParticipants:(NSArray *)participants
{
    NSMutableArray *array = [NSMutableArray new];
    
    for (NSString *userID in participants) {
        if ([userID isEqualToString:[PFUser currentUser].objectId]) continue;
        if (![self.userCache objectForKey:userID]) {
            [array addObject:userID];
        }
    }
    
    return [NSArray arrayWithArray:array];
}

- (NSArray *)resolvedNamesForParticipants:(NSArray *)participants
{
    NSMutableArray *array = [NSMutableArray new];
    for (NSString *userID in participants) {
        if ([self.userCache objectForKey:userID]) {
            PFUser *user = [self.userCache objectForKey:userID];
            [array addObject:user.firstName];
        }
    }
    return [NSArray arrayWithArray:array];
}

- (PFUser *)cachedUserForUserID:(NSString *)userID
{
    if ([self.userCache objectForKey:userID]) {
        return [self.userCache objectForKey:userID];
    }
    return nil;
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
    
    [self cacheUserIfNeeded:user];
    
}

@end
