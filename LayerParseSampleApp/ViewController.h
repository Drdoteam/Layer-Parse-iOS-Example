//
//  ViewController.h
//  LayerParseSampleApp
//
//  Created by Kabir Mahal on 3/25/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//

#import <LayerKit/LayerKit.h>
#import <Parse/Parse.h>
#import <ParseUI.h>
#import <UIKit/UIKit.h>
#import "ATLPConversationListViewController.h"

@interface ViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (nonatomic) LYRClient *layerClient;
@property (nonatomic) PFLogInViewController *logInViewController;

@end
