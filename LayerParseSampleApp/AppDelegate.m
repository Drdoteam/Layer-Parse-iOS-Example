//
//  AppDelegate.m
//  LayerParseSampleApp
//
//  Created by Kabir Mahal on 3/25/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

static NSString *const ATLPLayerAppIDString = @"44a270b6-7c58-11e4-bbba-fcf307000352";
static NSString *const ParseAppIDString = @"hQvFXx927IAtRepgc8qL9riePQozaYgGXzSpxyNd";
static NSString *const ParseClientKeyString = @"hHnDw8qFmZuDtvasWrbo3id2RUya4q5nHbgnF2fA";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //enable Parse local data store for user persistence
    [Parse enableLocalDatastore];
    // Set up Parse
    [Parse setApplicationId:ParseAppIDString
                  clientKey:ParseClientKeyString];
    
    // Set default ACLs
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    // Initializes a LYRClient object
    NSUUID *appID = [[NSUUID alloc] initWithUUIDString:ATLPLayerAppIDString];
    LYRClient *layerClient = [LYRClient clientWithAppID:appID];
    
    // Show View Controller
    ViewController *controller = [[ViewController alloc] init];
    controller.layerClient = layerClient;
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:controller];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
