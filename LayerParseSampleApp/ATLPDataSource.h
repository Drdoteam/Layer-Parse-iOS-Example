//
//  ATLPDataSource.h
//  LayerParseTest
//
//  Created by Kabir Mahal on 3/25/15.
//  Copyright (c) 2015 Abir Majumdar. All rights reserved.
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
