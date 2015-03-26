//
//  ATLPDataSource.h
//  LayerParseTest
//
//  Created by Kabir Mahal on 3/25/15.
//  Copyright (c) 2015 Abir Majumdar. All rights reserved.
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

#import <Foundation/Foundation.h>
@class PFUser;
@class LYRConversation;

@interface ATLPDataSource : NSObject

+ (instancetype)sharedManager;

// Query Methods
- (void)localQueryForUserWithName:(NSString *)searchText completion:(void (^)(NSArray *participants))completion;

- (void)localQueryForAllUsersWithCompletion:(void (^)(NSArray *users))completion;

- (PFUser *)localQueryForUserID:(NSString *)userID;

//Data Creation Methods
- (void)createLocalParseUsersIfNeeded;

- (void)queryAndLocallyStoreCloudUsers;

- (NSString *)titleForConversation:(LYRConversation *)conversation;

@end
